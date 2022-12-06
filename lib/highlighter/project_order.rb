# frozen_string_literal: true

module Highlighter
  module Client
    class ProjectOrder
      attr_accessor :id, :project_id, :project_order_id, :image_id, :state, :created_at, :updated_at, :completed_at
      def initialize(id:, project_id:, project_order_id:, image_id:, state:, created_at:, updated_at:, completed_at:)
        @id = id
        @project_id = project_id
        @project_order_id = project_order_id
        @image_id = image_id
        @state = state
        @created_at = created_at
        @updated_at = updated_at
        @completed_at = completed_at
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
                project_id: d.dig('projectId'),
                project_order_id: d.dig('projectOrderId'),
                image_id: d.dig('imageId'),
                state: d.dig('state'),
                created_at: d.dig('createdAt'),
                updated_at: d.dig('updatedAt'),
                completed_at: d.dig('completedAt'),
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
