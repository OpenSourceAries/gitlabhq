=begin
#OpenBao API

#HTTP API that gives you full access to OpenBao. All API routes are prefixed with `/v1/`.

The version of the OpenAPI document: 2.0.0

Generated by: https://openapi-generator.tech
Generator version: 7.7.0

=end

require 'spec_helper'
require 'json'
require 'date'

# Unit tests for OpenbaoClient::GenerateRandomResponse
# Automatically generated by openapi-generator (https://openapi-generator.tech)
# Please update as you see appropriate
describe OpenbaoClient::GenerateRandomResponse do
  let(:instance) { OpenbaoClient::GenerateRandomResponse.new }

  describe 'test an instance of GenerateRandomResponse' do
    it 'should create an instance of GenerateRandomResponse' do
      # uncomment below to test the instance creation
      #expect(instance).to be_instance_of(OpenbaoClient::GenerateRandomResponse)
    end
  end

  describe 'test attribute "random_bytes"' do
    it 'should work' do
      # assertion here. ref: https://rspec.info/features/3-12/rspec-expectations/built-in-matchers/
    end
  end

end
