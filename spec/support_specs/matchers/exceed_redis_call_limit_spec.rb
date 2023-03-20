# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'RedisCommand matchers', :use_clean_rails_redis_caching, feature_category: :source_code_management do
  let(:control) do
    RedisCommands::Recorder.new do
      Rails.cache.read('test')
      Rails.cache.read('test')
      Rails.cache.write('test', 1)
    end
  end

  before do
    Rails.cache.read('warmup')
  end

  it 'verifies maximum number of Redis calls' do
    expect(control).not_to exceed_redis_calls_limit(3)

    expect(control).not_to exceed_redis_command_calls_limit(:get, 2)
    expect(control).not_to exceed_redis_command_calls_limit(:set, 1)
  end

  it 'verifies minimum number of Redis calls' do
    expect(control).to exceed_redis_calls_limit(2)

    expect(control).to exceed_redis_command_calls_limit(:get, 1)
    expect(control).to exceed_redis_command_calls_limit(:set, 0)
  end

  context 'with Recorder matching only some Redis calls' do
    it 'counts only Redis calls captured by Recorder' do
      Rails.cache.write('ignored', 1)

      control = RedisCommands::Recorder.new do
        Rails.cache.read('recorded')
      end

      Rails.cache.write('also_ignored', 1)

      expect(control).not_to exceed_redis_calls_limit(1)
      expect(control).not_to exceed_redis_command_calls_limit(:set, 0)
      expect(control).not_to exceed_redis_command_calls_limit(:get, 1)
    end
  end

  context 'when expect part is a function' do
    it 'automatically enables RedisCommand::Recorder for it' do
      func = -> do
        Rails.cache.read('test')
        Rails.cache.read('test')
      end

      expect { func.call }.not_to exceed_redis_calls_limit(2)
      expect { func.call }.not_to exceed_redis_command_calls_limit(:get, 2)
    end
  end
end
