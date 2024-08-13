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

# Unit tests for OpenbaoClient::TotpValidateCodeRequest
# Automatically generated by openapi-generator (https://openapi-generator.tech)
# Please update as you see appropriate
describe OpenbaoClient::TotpValidateCodeRequest do
  let(:instance) { OpenbaoClient::TotpValidateCodeRequest.new }

  describe 'test an instance of TotpValidateCodeRequest' do
    it 'should create an instance of TotpValidateCodeRequest' do
      # uncomment below to test the instance creation
      #expect(instance).to be_instance_of(OpenbaoClient::TotpValidateCodeRequest)
    end
  end

  describe 'test attribute "code"' do
    it 'should work' do
      # assertion here. ref: https://rspec.info/features/3-12/rspec-expectations/built-in-matchers/
    end
  end

end
