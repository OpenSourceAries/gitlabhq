# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SidekiqMiddleware::PauseControl::Strategies::ClickHouseMigration, feature_category: :database do
  let(:worker_class) do
    Class.new do
      def self.name
        'TestPauseWorker'
      end

      include ::ApplicationWorker
      include ::ClickHouseWorker

      def perform(*); end
    end
  end

  before do
    stub_const('TestPauseWorker', worker_class)
  end

  describe '#call' do
    include Gitlab::ExclusiveLeaseHelpers

    shared_examples 'a worker being executed' do
      it 'schedules the job' do
        expect(Gitlab::SidekiqMiddleware::PauseControl::PauseControlService).not_to receive(:add_to_waiting_queue!)

        worker_class.perform_async('args1')

        expect(worker_class.jobs.count).to eq(1)
      end
    end

    context 'when lock is not taken' do
      it_behaves_like 'a worker being executed'
    end

    context 'when lock is taken' do
      include ExclusiveLeaseHelpers

      around do |example|
        ClickHouse::MigrationSupport::ExclusiveLock.execute_migration do
          example.run
        end
      end

      it 'does not schedule the job' do
        expect(Gitlab::SidekiqMiddleware::PauseControl::PauseControlService).to receive(:add_to_waiting_queue!).once

        worker_class.perform_async('args1')

        expect(worker_class.jobs.count).to eq(0)
      end

      context 'when pause_clickhouse_workers_during_migration FF is disabled' do
        before do
          stub_feature_flags(pause_clickhouse_workers_during_migration: false)
        end

        it_behaves_like 'a worker being executed'
      end
    end
  end
end
