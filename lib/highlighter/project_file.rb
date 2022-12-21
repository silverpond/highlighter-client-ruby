# frozen_string_literal: true

module Highlighter
  module Client
    class ProjectFile
      attr_accessor :id, :image_id, :project_id, :project_order_id, :state, :completed_at, :created_at, :updated_at, :latest_submission, :latest_submission_json
      def initialize(id:, image_id:, project_id:, project_order_id:, state:, completed_at:, created_at:, updated_at:, latest_submission:, latest_submission_json:)
        @id = id
        @image_id = image_id
        @project_id = project_id
        @project_order_id = project_order_id
        @state = state
        @completed_at = completed_at
        @created_at = created_at
        @updated_at = updated_at
        @latest_submission_json = latest_submission_json
        @latest_submission = latest_submission
      end

      def self.find(id:)
        query_string = <<-GRAPHQL
        query {
          projectImage(
            id: "#{id}",
          ) {
              id,
              image {
                id
              },
              projectId,
              projectOrderId,
              state,
              completedAt,
              createdAt,
              updatedAt,
              latestSubmission {
                id
                imageId
                startedAt
                createdAt
                updatedAt
                userId
                status
                annotations {
                  id
                  location
                  frameId
                  trackId
                  entityId
                  entity {
                    name
                    externalId
                    externalIdType
                  }
                  objectClassId
                  objectClass {
                    name
                  }
                }
                entityAttributeValues {
                  id
                  occurredAt
                  entityId
                  entity {
                    name
                    externalId
                    externalIdType
                  }
                  entityAttribute {
                    id
                    name
                    valueType
                  }
                  entityAttributeEnum {
                    id
                    value
                    title
                  }
                  value
                  relatedEntityId
                }
              }
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
        if result.success?
          submission = Highlighter::Client::Submission.from_json(data: result['data'].dig('projectImage', 'latestSubmission'))
          return new(id: result['data'].dig('projectImage', 'id'),
                     image_id: result['data'].dig('projectImage','image','id'),
                     project_id: result['data'].dig('projectImage','projectId'),
                     project_order_id: result['data'].dig('projectImage','projectOrderId'),
                     state: result['data'].dig('projectImage','state'),
                     completed_at: result['data'].dig('projectImage','completedAt'),
                     created_at: result['data'].dig('projectImage','createdAt'),
                     updated_at: result['data'].dig('projectImage','updatedAt'),
                     latest_submission_json: result['data'].dig('projectImage','latestSubmission'),
                     latest_submission: submission)
        else
          raise "Error finding task in Highlighter - #{result.code}"
        end
      end
    end
  end
end