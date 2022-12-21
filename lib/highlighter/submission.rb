# frozen_string_literal: true

module Highlighter
  module Client
    class Submission
      attr_accessor :id, :image_id, :started_at, :created_at, :updated_at, :user_id, :status,
                    :annotations, :entity_attribute_values, :entities
      def initialize(id:, image_id:, started_at:, created_at:, updated_at:, user_id:, status:,
                     annotations:, entity_attribute_values:)
        @id = id
        @image_id = image_id
        @started_at = started_at
        @created_at = created_at
        @updated_at = updated_at
        @user_id = user_id
        @status = status
        @annotations = annotations
        @entity_attribute_values = entity_attribute_values
        @entities = {}
        load_entities
      end

      def load_entities
        @annotations.each do |annotation|
          entity = @entities[annotation.entity_id]
          if entity.nil?
            @entities[annotation.entity_id] = Entity.new(
              id: annotation.entity_id,
              name: annotation.entity_name,
              object_class_name: annotation.object_class_name,
              external_id: annotation.entity_external_id,
              external_id_type: annotation.entity_external_id_type,
            )
          end
        end
        @entity_attribute_values.sort_by{|eav| eav.occurred_at}.each do |eavt|
          entity = @entities[eavt.entity_id]
          case eavt.entity_attribute_value_type
          when 'entity'
            if @entities[eavt.related_entity_id].nil?
              entity.fields[eavt.entity_attribute_name] = eavt.related_entity_id
            else
              entity.fields[eavt.entity_attribute_name] = @entities[eavt.related_entity_id]
            end
          when 'enum'
            entity.fields[eavt.entity_attribute_name] = eavt.entity_attribute_enum_value
          else
            entity.fields[eavt.entity_attribute_name] = eavt.value
          end
        end
      end

      def self.from_json(data:)
        return nil if data.nil?

        annotations = []
        if !data['annotations'].nil?
          data['annotations'].each do |d|
            annotations << Annotation.new(id: d.dig('id'),
                              location: d.dig('location'),
                              frame_id: d.dig( 'frameId'),
                              track_id: d.dig( 'trackId'),
                              entity_id: d.dig('entityId'),
                              entity_name: d.dig('entity', 'name'),
                              entity_external_id: d.dig('entity', 'externalId'),
                              entity_external_id_type: d.dig('entity', 'externalIdType'),
                              object_class_id: d.dig('objectClassId'),
                              object_class_name: d.dig('objectClass', 'name'))

          end
        end

        eavs = []
        if !data['entityAttributeValues'].nil?
          data['entityAttributeValues'].each do |d|
            eavs << EntityAttributeValue.new(id: d.dig('id'),
                      occurred_at: d.dig('occurredAt'),
                      entity_id: d.dig('entityId'),
                      entity_name: d.dig('entity', 'name'),
                      entity_external_id: d.dig('entity', 'externalId'),
                      entity_external_id_type: d.dig('entity', 'externalIdType'),
                      entity_attribute_id: d.dig('entityAttribute', 'id'),
                      entity_attribute_name: d.dig('entityAttribute', 'name'),
                      entity_attribute_value_type: d.dig('entityAttribute', 'valueType'),
                      entity_attribute_enum_id: d.dig('entityAttributeEnum', 'id'),
                      entity_attribute_enum_value: d.dig('entityAttributeEnum', 'value'),
                      entity_attribute_enum_title: d.dig('entityAttributeEnum', 'title'),
                      related_entity_id: d.dig('relatedEntityId'),
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
                      annotations: annotations,
                      entity_attribute_values: eavs)
      end
    end

    class Annotation
      attr_accessor :id, :location, :frame_id, :track_id,
        :entity_id, :entity_name, :entity_external_id, :entity_external_id_type,
        :object_class_id, :object_class_name

      def initialize(id:, location:, frame_id:, track_id:,
                    entity_id:, entity_name:, entity_external_id:, entity_external_id_type:,
                    object_class_id:, object_class_name:)
        @id = id
        @location = location
        @frame_id = frame_id
        @track_id = track_id
        @entity_id = entity_id
        @entity_name = entity_name
        @entity_external_id = entity_external_id
        @entity_external_id_type = entity_external_id_type
        @object_class_id = object_class_id
        @object_class_name = object_class_name
      end
    end

    class EntityAttributeValue
      attr_accessor :id, :occurred_at, :entity_id, :entity_name, :entity_external_id, :entity_external_id_type,
        :entity_attribute_id, :entity_attribute_name, :entity_attribute_value_type,
        :entity_attribute_enum_id, :entity_attribute_enum_value, :entity_attribute_enum_title,
        :related_entity_id, :value

      def initialize(id:, occurred_at:, entity_id:, entity_name:, entity_external_id:, entity_external_id_type:,
                    entity_attribute_id:, entity_attribute_name:, entity_attribute_value_type:,
                    entity_attribute_enum_id:, entity_attribute_enum_value:, entity_attribute_enum_title:,
                    related_entity_id:, value:)
        @id = id
        @occurred_at = Time.parse(occurred_at) if !occurred_at.nil?
        @entity_id = entity_id
        @entity_name = entity_name
        @entity_external_id = entity_external_id
        @entity_external_id_type = entity_external_id_type
        @entity_attribute_id = entity_attribute_id
        @entity_attribute_name = entity_attribute_name
        @entity_attribute_value_type = entity_attribute_value_type
        @entity_attribute_enum_id = entity_attribute_enum_id
        @entity_attribute_enum_value = entity_attribute_enum_value
        @entity_attribute_enum_title = entity_attribute_enum_title
        @related_entity_id = related_entity_id
        @value = value
      end

    end
    class Entity
      attr_accessor :id, :name, :object_class_name, :external_id, :external_id_type, :fields

      def initialize(id:, name:, object_class_name:, external_id:, external_id_type:)
        @id = id
        @name = name
        @object_class_name = object_class_name
        @external_id = external_id
        @external_id_type = external_id_type
        @fields = {}
      end
    end

  end
end


