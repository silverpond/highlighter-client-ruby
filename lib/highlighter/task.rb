# frozen_string_literal: true

module Highlighter
  module Client
    class Task
      attr_accessor :id, :image_id, :pipeline_id, :parameters, :status, :name, :description, :message, :task_submission_json, :submission
      def initialize(id:, image_id:, pipeline_id:, parameters:, status:, name:, description:, message:, task_submission_json:, submission:)
        @id = id
        @image_id = image_id
        @pipeline_id = pipeline_id
        @parameters = parameters
        @status = status
        @name = name
        @description = description
        @message = message
        @task_submission_json = task_submission_json
        @submission = submission
      end

      def self.create(pipeline_id:, image_id:, name:, parameters: {})
        parameters_string = parameters.to_json

        query_string = <<-GRAPHQL
        mutation {
          createTask(
            pipelineId: "#{pipeline_id}",
            imageId: #{image_id},
            name: "#{name}",
            parameters: #{parameters_string},
          ) {
              task {
                id,
                image {
                  id
                },
                pipelineId,
                parameters,
                status,
                name,
                description,
                message,
              },
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
        if result.success?
          return new(id: result['data']['createTask'].dig('task','id'),
                     image_id: result['data']['createTask'].dig('task','image','id'),
                     pipeline_id: result['data']['createTask'].dig('task','pipelineId'),
                     parameters: result['data']['createTask'].dig('task','parameters'),
                     status: result['data']['createTask'].dig('task', 'status'),
                     name: result['data']['createTask'].dig('task', 'name'),
                     description: result['data']['createTask'].dig('task', 'description'),
                     message: result['data']['createTask'].dig('task', 'message'),
                     task_submission_json: nil,
                     submission: nil)
        else
          raise "Error registering file in Highlighter - #{result.code}"
        end
      end

      def self.find(id:)
        query_string = <<-GRAPHQL
        query {
          task(
            id: "#{id}",
          ) {
              id,
              image {
                id
              },
              pipelineId,
              parameters,
              status,
              name,
              description,
              message,
              submission {
                id
                imageId
                startedAt
                createdAt
                updatedAt
                userId
                status
                entityAttributeValues {
                  id
                  occurredAt
                  entityId
                  entityAttribute {
                    id
                    name
                    valueType
                  }
                  entityAttributeEnum {
                    id
                    value
                  }
                  value
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
          submission = Highlighter::Client::Submission.from_json(data: result['data'].dig('task', 'submission'))
          return new(id: result['data'].dig('task', 'id'),
                     image_id: result['data'].dig('task','image','id'),
                     pipeline_id: result['data'].dig('task','pipelineId'),
                     parameters: result['data'].dig('task','parameters'),
                     status: result['data'].dig('task','status'),
                     name: result['data'].dig('task','name'),
                     description: result['data'].dig('task','description'),
                     message: result['data'].dig('task','message'),
                     task_submission_json: result['data'].dig('task','submission'),
                     submission: submission)
        else
          raise "Error registering file in Highlighter - #{result.code}"
        end
      end
    end
  end
end
