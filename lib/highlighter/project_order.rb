# frozen_string_literal: true

module Highlighter
  module Client
    class ProjectOrder
      attr_accessor :id, :name, :filterOriginalSourceUrl, :locked, :projectId, :requestedById, :state
      def initialize(id:, name:, filterOriginalSourceUrl:, locked:, projectId:, requestedById:, state:)
        @id = id
        @name = name
        @filterOriginalSourceUrl = filterOriginalSourceUrl
        @locked = locked
        @projectId = projectId
        @requestedById = requestedById
        @state = state
      end

      def self.add_files(project_order_id:, file_ids: [])
        query_string = <<-GRAPHQL
        mutation {
          addFilesToProjectOrder(projectOrderId: "#{project_order_id}", fileIds: [#{file_ids.join(',')}]) {
            projectOrder {
              id
              name
              filterOriginalSourceUrl
              locked
              projectId
              requestedById
              state
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
          return new(id: data.dig('projectOrder','id'),
                     name: data.dig('projectOrder','name'),
                     filterOriginalSourceUrl: data.dig('projectOrder','filterOriginalSourceUrl'),
                     locked: data.dig('projectOrder','locked'),
                     projectId: data.dig('projectOrder', 'projectId'),
                     requestedById: data.dig('projectOrder', 'requestedById'),
                     state: data.dig('projectOrder', 'state'),
                     )
        elsif result.success? && result['errors'].present?
          raise "Error adding files to project order #{project_order_id} in Highlighter - #{result['errors']}"
        else
          raise "Error adding files to project order #{project_order_id} in Highlighter - #{result.code} - #{data}"
        end
      end
    end
  end
end
