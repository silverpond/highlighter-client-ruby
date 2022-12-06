# frozen_string_literal: true

module Highlighter
  module Client
    class ProjectOrder
      attr_accessor :id, :projectId, :projectOrderId, :imageId, :state, :createdAt, :updatedAt, :completedAt
      def initialize(id:, projectId:, projectOrderId:, imageId:, state:, createdAt:, updatedAt:, completedAt:)
        @id = id
        @projectId = projectId
        @projectOrderId = projectOrderId
        @imageId = imageId
        @state = state
        @createdAt = createdAt
        @updatedAt = updatedAt
        @completedAt = completedAt
      end

      def self.add_files(project_order_id:, file_ids: [])
        query_string = <<-GRAPHQL
        mutation {
          addFilesToProjectOrder(projectOrderId: "#{project_order_id}", fileIds: [#{file_ids.join(',')}]) {
            projectImages {
              id
              projectId
              projectOrderId
              imageId
              state
              createdAt
              updatedAt
              completedAt
            }
            errors
          }
        }
        GRAPHQL

        # request_url = "https://art-processors.highlighter.ai/graphql"
        # request_url = "http://art-processors.localhost.ai:3000/graphql"
        result = HTTParty.post("#{Highlighter::Client.host_and_port}/graphql",
                     body: { query: query_string, variables: nil }.to_json,
                     timeout: Highlighter::Client.http_timeout,
                     headers: { 'content-type': 'application/json',
                                 'Authorization': "Token #{Highlighter::Client.api_token}" })
        data = result.dig('data', 'addFilesToProjectOrder')
        if result.success? && data.present?
          if data['projectImages'].present?
            return data['projectImages'].map do |d|
              new(
                id: d.dig('id'),
                projectId: d.dig('projectId'),
                projectOrderId: d.dig('projectOrderId'),
                imageId: d.dig('imageId'),
                state: d.dig('state'),
                createdAt: d.dig('createdAt'),
                updatedAt: d.dig('updatedAt'),
                completedAt: d.dig('completedAt'),
              )
            end
          else
            raise "Error adding files to project order #{project_order_id} in Highlighter - Missing Project Images - #{data}"
          end
        elsif result.success? && result['errors'].present?
          raise "Error adding files to project order #{project_order_id} in Highlighter - #{result['errors']}"
        else
          raise "Error adding files to project order #{project_order_id} in Highlighter - #{result.code} - #{data}"
        end
      end
    end
  end
end
