# frozen_string_literal: true

module Highlighter
  module Client
    class File
      attr_accessor :id, :original_source_url, :data_source_id, :mime_type, :content_type
      def initialize(id:, original_source_url:, data_source_id:, mime_type:, content_type:)
        @id = id
        @original_source_url = original_source_url
        @data_source_id = data_source_id
        @mime_type = mime_type
        @content_type = content_type
      end

      def self.get_presigned_url(filename:)
        query_string = <<-GRAPHQL
            query {
              presignedUrl(
                filename: "#{filename}"
              ) {
                  fields {
                    key,
                    policy,
                    xAmzCredential,
                    xAmzDate,
                    xAmzAlgorithm,
                    xAmzSignature,
                  },
                  key,
                  storage,
                  url
                }
              }
        GRAPHQL

        # request_url = "https://art-processors.highlighter.ai/graphql"
        result = HTTParty.post("#{Highlighter::Client.host_and_port}/graphql",
                               body: { query: query_string, variables: nil }.to_json,
                               timeout: Highlighter::Client.http_timeout,
                               headers: { 'content-type': 'application/json',
                                          'Authorization': "Token #{Highlighter::Client.api_token}" })
      end

      def self.upload_to_s3(file:, filename:, content_type:)
        presigned_url = get_presigned_url(filename: filename)
        raise "Error getting presigned url from Highlighter - #{presigned_url.code}" unless presigned_url.success?

        fields = presigned_url['data']['presignedUrl']['fields']
        fields = fields.transform_keys { |key| key.underscore.dasherize }
        fields['file'] = file

        url = presigned_url['data']['presignedUrl']['url']

        response = HTTParty.post(url, body: fields,
                                 timeout: Highlighter::Client.http_timeout,
                                      headers: { 'content-type': content_type })
        if response.success?
          {
            id: presigned_url['data']['presignedUrl']['key'],
            storage: presigned_url['data']['presignedUrl']['storage']
          }
        else
          raise "Error uploading file to Highlighter - #{reponse.code}"
        end
      end

      def self.upload_and_create(data_source_id:, file:, filename:, content_type:, metadata: {})
        store = upload_to_s3(file: file, filename: filename, content_type: content_type)

        result = create(data_source_id: data_source_id, original_source_url: filename,
                        file_data_id: store[:id],
                        file_data_storage: store[:storage],
                        file_size: file.length,
                        mime_type: content_type,
                        metadata: metadata)

        if result.success?
          return new(id: result['data']['createImage'].dig('image','id'),
                     original_source_url: result['data']['createImage'].dig('image','originalSourceUrl'),
                     data_source_id: result['data']['createImage'].dig('image','dataSourceId'),
                     mime_type: result['data']['createImage'].dig('image','mimeType'),
                     content_type: result['data']['createImage'].dig('image','contentType'))
        else
          raise "Error registering file in Highlighter - #{result.code}"
        end
      end

      def self.create(data_source_id:, original_source_url:, file_data_id:, file_data_storage:, file_size:, mime_type:, metadata: {})

        metadata_mutation = metadata.map{|k,v| "#{k}: \"#{v}\""}.join(",")

        query_string = <<-GRAPHQL
            mutation {
              createImage(
                dataSourceId: #{data_source_id},
                originalSourceUrl: "#{original_source_url}",
                metadata: { #{metadata_mutation} },
                fileData: {
                  id: "#{file_data_id}",
                  storage: "#{file_data_storage}",
                  metadata: {
                    size: #{file_size},
                    filename: "#{original_source_url}",
                    mimeType: "#{mime_type}",
                  }
                }
              ) {
                  image {
                    id,
                    originalSourceUrl,
                    dataSourceId,
                    mimeType,
                    contentType,
                  },
                  errors
                }
              }
        GRAPHQL

        HTTParty.post("#{Highlighter::Client.host_and_port}/graphql",
                      body: { query: query_string, variables: nil }.to_json,
                      timeout: Highlighter::Client.http_timeout,
                      headers: { 'content-type': 'application/json',
                                 'Authorization': "Token #{Highlighter::Client.api_token}" })
      end
    end
  end
end
