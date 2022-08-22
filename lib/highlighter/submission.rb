# frozen_string_literal: true

module Highlighter
  module Client
    class Submission
      attr_accessor :id, :image_id, :started_at, :created_at, :updated_at, :user_id, :status,
                    :entity_attribute_values
      def initialize(id:, image_id:, started_at:, created_at:, updated_at:, user_id:, status:,
                     entity_attribute_values:)
        @id = id
        @image_id = image_id
        @started_at = started_at
        @created_at = created_at
        @updated_at = updated_at
        @user_id = user_id
        @status = status
        @entity_attribute_values = entity_attribute_values
      end

      def self.from_json(data:)
        return nil if data.nil?

        eavs = []
        if !data['entity_attribute_values'].nil?
          data['entity_attribute_values'].each do |d|
            eavs << EntityAttributeValue.new(id: d.dig('id'),
                      occurred_at: d.dig('occurredAt'),
                      entity_id: d.dig('entityId'),
                      entity_attribute_id: d.dig('entityAttribute', 'id'),
                      entity_attribute_name: d.dig('entityAttribute', 'name'),
                      entity_attribute_value_type: d.dig('entityAttribute', 'valueType'),
                      entity_attribute_enum_id: d.dig('entityAttributeEnum', 'id'),
                      entity_attribute_enum_value: d.dig('entityAttributeEnum', 'value'),
                      value: d.dig('value'))

          end
        end
        Submission.new(id: data['id'],
                      image_id: data.dig('imageId'),
                      started_at: data.dig('startedAt'),
                      created_at: data.dig('createdAt'),
                      updated_at: data.dig('updatedAt'),
                      user_id: data.dig('userId'),
                      status: data.dig('status'),
                      entity_attribute_values: eavs)
      end
    end

    class EntityAttributeValue
      attr_accessor :id, :occurred_at, :entity_id,
        :entity_attribute_id, :entity_attribute_name, :entity_attribute_value_type,
        :entity_attribute_enum_id, :entity_attribute_enum_value,
        :value

      def initialize(id:, occurred_at:, entity_id:,
                    entity_attribute_id:, entity_attribute_name:, entity_attribute_value_type:,
                    entity_attribute_enum_id:, entity_attribute_enum_value:,
                    value:)
        @id = id
        @occurred_at = occurred_at
        @entity_id = entity_id
        @entity_attribute_id = entity_attribute_id
        @entity_attribute_name = entity_attribute_name
        @entity_attribute_value_type = entity_attribute_value_type
        @entity_attribute_enum_id = entity_attribute_enum_id
        @entity_attribute_enum_value = entity_attribute_enum_value
        @value = value
      end

    end
  end
end


