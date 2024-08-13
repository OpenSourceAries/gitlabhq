=begin
#OpenBao API

#HTTP API that gives you full access to OpenBao. All API routes are prefixed with `/v1/`.

The version of the OpenAPI document: 2.0.0

Generated by: https://openapi-generator.tech
Generator version: 7.7.0

=end

require 'date'
require 'time'

module OpenbaoClient
  class MountsReadConfigurationResponse
    attr_accessor :accessor

    # Configuration for this mount, such as default_lease_ttl and max_lease_ttl.
    attr_accessor :config

    attr_accessor :deprecation_status

    # User-friendly description for this mount.
    attr_accessor :description

    attr_accessor :external_entropy_access

    # Mark the mount as a local mount, which is not replicated and is unaffected by replication.
    attr_accessor :local

    # The options to pass into the backend. Should be a json object with string keys and values.
    attr_accessor :options

    # The semantic version of the plugin to use.
    attr_accessor :plugin_version

    attr_accessor :running_plugin_version

    attr_accessor :running_sha256

    # Whether to turn on seal wrapping for the mount.
    attr_accessor :seal_wrap

    # The type of the backend. Example: \"passthrough\"
    attr_accessor :type

    attr_accessor :uuid

    # Attribute mapping from ruby-style variable name to JSON key.
    def self.attribute_map
      {
        :'accessor' => :'accessor',
        :'config' => :'config',
        :'deprecation_status' => :'deprecation_status',
        :'description' => :'description',
        :'external_entropy_access' => :'external_entropy_access',
        :'local' => :'local',
        :'options' => :'options',
        :'plugin_version' => :'plugin_version',
        :'running_plugin_version' => :'running_plugin_version',
        :'running_sha256' => :'running_sha256',
        :'seal_wrap' => :'seal_wrap',
        :'type' => :'type',
        :'uuid' => :'uuid'
      }
    end

    # Returns all the JSON keys this model knows about
    def self.acceptable_attributes
      attribute_map.values
    end

    # Attribute type mapping.
    def self.openapi_types
      {
        :'accessor' => :'String',
        :'config' => :'Object',
        :'deprecation_status' => :'String',
        :'description' => :'String',
        :'external_entropy_access' => :'Boolean',
        :'local' => :'Boolean',
        :'options' => :'Object',
        :'plugin_version' => :'String',
        :'running_plugin_version' => :'String',
        :'running_sha256' => :'String',
        :'seal_wrap' => :'Boolean',
        :'type' => :'String',
        :'uuid' => :'String'
      }
    end

    # List of attributes with nullable: true
    def self.openapi_nullable
      Set.new([
      ])
    end

    # Initializes the object
    # @param [Hash] attributes Model attributes in the form of hash
    def initialize(attributes = {})
      if (!attributes.is_a?(Hash))
        fail ArgumentError, "The input argument (attributes) must be a hash in `OpenbaoClient::MountsReadConfigurationResponse` initialize method"
      end

      # check to see if the attribute exists and convert string to symbol for hash key
      attributes = attributes.each_with_object({}) { |(k, v), h|
        if (!self.class.attribute_map.key?(k.to_sym))
          fail ArgumentError, "`#{k}` is not a valid attribute in `OpenbaoClient::MountsReadConfigurationResponse`. Please check the name to make sure it's valid. List of attributes: " + self.class.attribute_map.keys.inspect
        end
        h[k.to_sym] = v
      }

      if attributes.key?(:'accessor')
        self.accessor = attributes[:'accessor']
      end

      if attributes.key?(:'config')
        self.config = attributes[:'config']
      end

      if attributes.key?(:'deprecation_status')
        self.deprecation_status = attributes[:'deprecation_status']
      end

      if attributes.key?(:'description')
        self.description = attributes[:'description']
      end

      if attributes.key?(:'external_entropy_access')
        self.external_entropy_access = attributes[:'external_entropy_access']
      end

      if attributes.key?(:'local')
        self.local = attributes[:'local']
      else
        self.local = false
      end

      if attributes.key?(:'options')
        self.options = attributes[:'options']
      end

      if attributes.key?(:'plugin_version')
        self.plugin_version = attributes[:'plugin_version']
      end

      if attributes.key?(:'running_plugin_version')
        self.running_plugin_version = attributes[:'running_plugin_version']
      end

      if attributes.key?(:'running_sha256')
        self.running_sha256 = attributes[:'running_sha256']
      end

      if attributes.key?(:'seal_wrap')
        self.seal_wrap = attributes[:'seal_wrap']
      else
        self.seal_wrap = false
      end

      if attributes.key?(:'type')
        self.type = attributes[:'type']
      end

      if attributes.key?(:'uuid')
        self.uuid = attributes[:'uuid']
      end
    end

    # Show invalid properties with the reasons. Usually used together with valid?
    # @return Array for valid properties with the reasons
    def list_invalid_properties
      warn '[DEPRECATED] the `list_invalid_properties` method is obsolete'
      invalid_properties = Array.new
      invalid_properties
    end

    # Check to see if the all the properties in the model are valid
    # @return true if the model is valid
    def valid?
      warn '[DEPRECATED] the `valid?` method is obsolete'
      true
    end

    # Checks equality by comparing each attribute.
    # @param [Object] Object to be compared
    def ==(o)
      return true if self.equal?(o)
      self.class == o.class &&
          accessor == o.accessor &&
          config == o.config &&
          deprecation_status == o.deprecation_status &&
          description == o.description &&
          external_entropy_access == o.external_entropy_access &&
          local == o.local &&
          options == o.options &&
          plugin_version == o.plugin_version &&
          running_plugin_version == o.running_plugin_version &&
          running_sha256 == o.running_sha256 &&
          seal_wrap == o.seal_wrap &&
          type == o.type &&
          uuid == o.uuid
    end

    # @see the `==` method
    # @param [Object] Object to be compared
    def eql?(o)
      self == o
    end

    # Calculates hash code according to all attributes.
    # @return [Integer] Hash code
    def hash
      [accessor, config, deprecation_status, description, external_entropy_access, local, options, plugin_version, running_plugin_version, running_sha256, seal_wrap, type, uuid].hash
    end

    # Builds the object from hash
    # @param [Hash] attributes Model attributes in the form of hash
    # @return [Object] Returns the model itself
    def self.build_from_hash(attributes)
      return nil unless attributes.is_a?(Hash)
      attributes = attributes.transform_keys(&:to_sym)
      transformed_hash = {}
      openapi_types.each_pair do |key, type|
        if attributes.key?(attribute_map[key]) && attributes[attribute_map[key]].nil?
          transformed_hash["#{key}"] = nil
        elsif type =~ /\AArray<(.*)>/i
          # check to ensure the input is an array given that the attribute
          # is documented as an array but the input is not
          if attributes[attribute_map[key]].is_a?(Array)
            transformed_hash["#{key}"] = attributes[attribute_map[key]].map { |v| _deserialize($1, v) }
          end
        elsif !attributes[attribute_map[key]].nil?
          transformed_hash["#{key}"] = _deserialize(type, attributes[attribute_map[key]])
        end
      end
      new(transformed_hash)
    end

    # Deserializes the data based on type
    # @param string type Data type
    # @param string value Value to be deserialized
    # @return [Object] Deserialized data
    def self._deserialize(type, value)
      case type.to_sym
      when :Time
        Time.parse(value)
      when :Date
        Date.parse(value)
      when :String
        value.to_s
      when :Integer
        value.to_i
      when :Float
        value.to_f
      when :Boolean
        if value.to_s =~ /\A(true|t|yes|y|1)\z/i
          true
        else
          false
        end
      when :Object
        # generic object (usually a Hash), return directly
        value
      when /\AArray<(?<inner_type>.+)>\z/
        inner_type = Regexp.last_match[:inner_type]
        value.map { |v| _deserialize(inner_type, v) }
      when /\AHash<(?<k_type>.+?), (?<v_type>.+)>\z/
        k_type = Regexp.last_match[:k_type]
        v_type = Regexp.last_match[:v_type]
        {}.tap do |hash|
          value.each do |k, v|
            hash[_deserialize(k_type, k)] = _deserialize(v_type, v)
          end
        end
      else # model
        # models (e.g. Pet) or oneOf
        klass = OpenbaoClient.const_get(type)
        klass.respond_to?(:openapi_any_of) || klass.respond_to?(:openapi_one_of) ? klass.build(value) : klass.build_from_hash(value)
      end
    end

    # Returns the string representation of the object
    # @return [String] String presentation of the object
    def to_s
      to_hash.to_s
    end

    # to_body is an alias to to_hash (backward compatibility)
    # @return [Hash] Returns the object in the form of hash
    def to_body
      to_hash
    end

    # Returns the object in the form of hash
    # @return [Hash] Returns the object in the form of hash
    def to_hash
      hash = {}
      self.class.attribute_map.each_pair do |attr, param|
        value = self.send(attr)
        if value.nil?
          is_nullable = self.class.openapi_nullable.include?(attr)
          next if !is_nullable || (is_nullable && !instance_variable_defined?(:"@#{attr}"))
        end

        hash[param] = _to_hash(value)
      end
      hash
    end

    # Outputs non-array value in the form of hash
    # For object, use to_hash. Otherwise, just return the value
    # @param [Object] value Any valid value
    # @return [Hash] Returns the value in the form of hash
    def _to_hash(value)
      if value.is_a?(Array)
        value.compact.map { |v| _to_hash(v) }
      elsif value.is_a?(Hash)
        {}.tap do |hash|
          value.each { |k, v| hash[k] = _to_hash(v) }
        end
      elsif value.respond_to? :to_hash
        value.to_hash
      else
        value
      end
    end

  end

end
