# frozen_string_literal: true

module Highlighter
  ###
  # Setup access to higlighter.ai. Use the api_token created from your user profile page.
  #
  # eg.,
  #
  # Highlighter::Client.config do |c|
  #   c.api_token = 'abcd1234'
  #   c.host_and_port = 'https://silverpond.highlighter.ai'
  # end
  #
  #
  ###
  module Client
    class << self
      attr_accessor :host_and_port, :api_token, :timeout_in_seconds
      def config
        yield self
      end

      def http_timeout
        self.timeout_in_seconds || 30
      end
    end
  end
end

require_relative 'file'
require_relative 'project_file'
require_relative 'project_order'
require_relative 'task'
require_relative 'submission'
