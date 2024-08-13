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
  class TotpCreateKeyRequest
    # The name of the account associated with the key. Required if generate is true.
    attr_accessor :account_name

    # The hashing algorithm used to generate the TOTP token. Options include SHA1, SHA256 and SHA512.
    attr_accessor :algorithm

    # The number of digits in the generated TOTP token. This value can either be 6 or 8.
    attr_accessor :digits

    # Determines if a QR code and url are returned upon generating a key. Only used if generate is true.
    attr_accessor :exported

    # Determines if a key should be generated by OpenBao or if a key is being passed from another service.
    attr_accessor :generate

    # The name of the key's issuing organization. Required if generate is true.
    attr_accessor :issuer

    # The shared master key used to generate a TOTP token. Only used if generate is false.
    attr_accessor :key

    # Determines the size in bytes of the generated key. Only used if generate is true.
    attr_accessor :key_size

    # The length of time used to generate a counter for the TOTP token calculation.
    attr_accessor :period

    # The pixel size of the generated square QR code. Only used if generate is true and exported is true. If this value is 0, a QR code will not be returned.
    attr_accessor :qr_size

    # The number of delay periods that are allowed when validating a TOTP token. This value can either be 0 or 1. Only used if generate is true.
    attr_accessor :skew

    # A TOTP url string containing all of the parameters for key setup. Only used if generate is false.
    attr_accessor :url

    # Attribute mapping from ruby-style variable name to JSON key.
    def self.attribute_map
      {
        :'account_name' => :'account_name',
        :'algorithm' => :'algorithm',
        :'digits' => :'digits',
        :'exported' => :'exported',
        :'generate' => :'generate',
        :'issuer' => :'issuer',
        :'key' => :'key',
        :'key_size' => :'key_size',
        :'period' => :'period',
        :'qr_size' => :'qr_size',
        :'skew' => :'skew',
        :'url' => :'url'
      }
    end

    # Returns all the JSON keys this model knows about
    def self.acceptable_attributes
      attribute_map.values
    end

    # Attribute type mapping.
    def self.openapi_types
      {
        :'account_name' => :'String',
        :'algorithm' => :'String',
        :'digits' => :'Integer',
        :'exported' => :'Boolean',
        :'generate' => :'Boolean',
        :'issuer' => :'String',
        :'key' => :'String',
        :'key_size' => :'Integer',
        :'period' => :'Integer',
        :'qr_size' => :'Integer',
        :'skew' => :'Integer',
        :'url' => :'String'
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
        fail ArgumentError, "The input argument (attributes) must be a hash in `OpenbaoClient::TotpCreateKeyRequest` initialize method"
      end

      # check to see if the attribute exists and convert string to symbol for hash key
      attributes = attributes.each_with_object({}) { |(k, v), h|
        if (!self.class.attribute_map.key?(k.to_sym))
          fail ArgumentError, "`#{k}` is not a valid attribute in `OpenbaoClient::TotpCreateKeyRequest`. Please check the name to make sure it's valid. List of attributes: " + self.class.attribute_map.keys.inspect
        end
        h[k.to_sym] = v
      }

      if attributes.key?(:'account_name')
        self.account_name = attributes[:'account_name']
      end

      if attributes.key?(:'algorithm')
        self.algorithm = attributes[:'algorithm']
      else
        self.algorithm = 'SHA1'
      end

      if attributes.key?(:'digits')
        self.digits = attributes[:'digits']
      else
        self.digits = 6
      end

      if attributes.key?(:'exported')
        self.exported = attributes[:'exported']
      else
        self.exported = true
      end

      if attributes.key?(:'generate')
        self.generate = attributes[:'generate']
      else
        self.generate = false
      end

      if attributes.key?(:'issuer')
        self.issuer = attributes[:'issuer']
      end

      if attributes.key?(:'key')
        self.key = attributes[:'key']
      end

      if attributes.key?(:'key_size')
        self.key_size = attributes[:'key_size']
      else
        self.key_size = 20
      end

      if attributes.key?(:'period')
        self.period = attributes[:'period']
      else
        self.period = 30
      end

      if attributes.key?(:'qr_size')
        self.qr_size = attributes[:'qr_size']
      else
        self.qr_size = 200
      end

      if attributes.key?(:'skew')
        self.skew = attributes[:'skew']
      else
        self.skew = 1
      end

      if attributes.key?(:'url')
        self.url = attributes[:'url']
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
          account_name == o.account_name &&
          algorithm == o.algorithm &&
          digits == o.digits &&
          exported == o.exported &&
          generate == o.generate &&
          issuer == o.issuer &&
          key == o.key &&
          key_size == o.key_size &&
          period == o.period &&
          qr_size == o.qr_size &&
          skew == o.skew &&
          url == o.url
    end

    # @see the `==` method
    # @param [Object] Object to be compared
    def eql?(o)
      self == o
    end

    # Calculates hash code according to all attributes.
    # @return [Integer] Hash code
    def hash
      [account_name, algorithm, digits, exported, generate, issuer, key, key_size, period, qr_size, skew, url].hash
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
