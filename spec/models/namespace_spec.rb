require 'spec_helper'

describe Namespace, models: true do
  let!(:namespace) { create(:namespace) }

  it { is_expected.to have_many :projects }
  it { is_expected.to have_one(:namespace_metrics).dependent(:destroy) }
  it { is_expected.to have_many :project_statistics }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:parent_id) }
  it { is_expected.to validate_length_of(:name).is_at_most(255) }

  it { is_expected.to validate_length_of(:description).is_at_most(255) }

  it { is_expected.to validate_presence_of(:path) }
  it { is_expected.to validate_length_of(:path).is_at_most(255) }

  it { is_expected.to validate_presence_of(:owner) }

  it { is_expected.to delegate_method(:shared_runners_minutes).to(:namespace_metrics) }
  it { is_expected.to delegate_method(:shared_runners_minutes_last_reset).to(:namespace_metrics) }

  describe "Respond to" do
    it { is_expected.to respond_to(:human_name) }
    it { is_expected.to respond_to(:to_param) }
  end

  describe '#to_param' do
    it { expect(namespace.to_param).to eq(namespace.path) }
  end

  describe '#human_name' do
    it { expect(namespace.human_name).to eq(namespace.owner_name) }
  end

  describe '.search' do
    let(:namespace) { create(:namespace) }

    it 'returns namespaces with a matching name' do
      expect(described_class.search(namespace.name)).to eq([namespace])
    end

    it 'returns namespaces with a partially matching name' do
      expect(described_class.search(namespace.name[0..2])).to eq([namespace])
    end

    it 'returns namespaces with a matching name regardless of the casing' do
      expect(described_class.search(namespace.name.upcase)).to eq([namespace])
    end

    it 'returns namespaces with a matching path' do
      expect(described_class.search(namespace.path)).to eq([namespace])
    end

    it 'returns namespaces with a partially matching path' do
      expect(described_class.search(namespace.path[0..2])).to eq([namespace])
    end

    it 'returns namespaces with a matching path regardless of the casing' do
      expect(described_class.search(namespace.path.upcase)).to eq([namespace])
    end
  end

  describe '.with_statistics' do
    let(:namespace) { create :namespace }

    let(:project1) do
      create(:empty_project,
             namespace: namespace,
             statistics: build(:project_statistics,
                               storage_size:         606,
                               repository_size:      101,
                               lfs_objects_size:     202,
                               build_artifacts_size: 303))
    end

    let(:project2) do
      create(:empty_project,
             namespace: namespace,
             statistics: build(:project_statistics,
                               storage_size:         60,
                               repository_size:      10,
                               lfs_objects_size:     20,
                               build_artifacts_size: 30))
    end

    it "sums all project storage counters in the namespace" do
      project1
      project2
      statistics = Namespace.with_statistics.find(namespace.id)

      expect(statistics.storage_size).to eq 666
      expect(statistics.repository_size).to eq 111
      expect(statistics.lfs_objects_size).to eq 222
      expect(statistics.build_artifacts_size).to eq 333
    end

    it "correctly handles namespaces without projects" do
      statistics = Namespace.with_statistics.find(namespace.id)

      expect(statistics.storage_size).to eq 0
      expect(statistics.repository_size).to eq 0
      expect(statistics.lfs_objects_size).to eq 0
      expect(statistics.build_artifacts_size).to eq 0
    end
  end

  describe '#move_dir' do
    before do
      @namespace = create :namespace
      @project = create :project, namespace: @namespace
      allow(@namespace).to receive(:path_changed?).and_return(true)
    end

    it "raises error when directory exists" do
      expect { @namespace.move_dir }.to raise_error("namespace directory cannot be moved")
    end

    it "moves dir if path changed" do
      new_path = @namespace.path + "_new"
      allow(@namespace).to receive(:path_was).and_return(@namespace.path)
      allow(@namespace).to receive(:path).and_return(new_path)
      expect(@namespace.move_dir).to be_truthy
    end

    context "when any project has container tags" do
      before do
        stub_container_registry_config(enabled: true)
        stub_container_registry_tags('tag')

        create(:empty_project, namespace: @namespace)

        allow(@namespace).to receive(:path_was).and_return(@namespace.path)
        allow(@namespace).to receive(:path).and_return('new_path')
      end

      it { expect { @namespace.move_dir }.to raise_error('Namespace cannot be moved, because at least one project has tags in container registry') }
    end
  end

  describe '#actual_size_limit' do
    let(:namespace) { build(:namespace) }

    before do
      allow_any_instance_of(ApplicationSetting).to receive(:repository_size_limit).and_return(50)
    end

    it 'returns the correct size limit' do
      expect(namespace.actual_size_limit).to eq(50)
    end
  end

  describe :rm_dir do
    let!(:project) { create(:project, namespace: namespace) }
    let!(:path) { File.join(Gitlab.config.repositories.storages.default, namespace.path) }

    before { namespace.destroy }

    it "removes its dirs when deleted" do
      expect(File.exist?(path)).to be(false)
    end
  end

  describe '.find_by_path_or_name' do
    before do
      @namespace = create(:namespace, name: 'WoW', path: 'woW')
    end

    it { expect(Namespace.find_by_path_or_name('wow')).to eq(@namespace) }
    it { expect(Namespace.find_by_path_or_name('WOW')).to eq(@namespace) }
    it { expect(Namespace.find_by_path_or_name('unknown')).to eq(nil) }
  end

  describe ".clean_path" do
    let!(:user)       { create(:user, username: "johngitlab-etc") }
    let!(:namespace)  { create(:namespace, path: "JohnGitLab-etc1") }

    it "cleans the path and makes sure it's available" do
      expect(Namespace.clean_path("-john+gitlab-ETC%.git@gmail.com")).to eq("johngitlab-ETC2")
      expect(Namespace.clean_path("--%+--valid_*&%name=.git.%.atom.atom.@email.com")).to eq("valid_name")
    end
  end

  describe '#full_path' do
    let(:group) { create(:group) }
    let(:nested_group) { create(:group, parent: group) }

    it { expect(group.full_path).to eq(group.path) }
    it { expect(nested_group.full_path).to eq("#{group.path}/#{nested_group.path}") }
  end

  describe '#shared_runners_enabled?' do
    subject { namespace.shared_runners_enabled? }

    context 'without projects' do
      it { is_expected.to be_falsey }
    end

    context 'with project' do
      context 'and disabled shared runners' do
        let!(:project) do
          create(:empty_project,
            namespace: namespace,
            shared_runners_enabled: false)
        end

        it { is_expected.to be_falsey }
      end

      context 'and enabled shared runners' do
        let!(:project) do
          create(:empty_project,
            namespace: namespace,
            shared_runners_enabled: true)
        end

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#actual_shared_runners_minutes_limit' do
    subject { namespace.actual_shared_runners_minutes_limit }

    context 'when no limit defined' do
      it { is_expected.to be_zero }
    end

    context 'when application settings limit is set' do
      before do
        stub_application_setting(shared_runners_minutes: 1000)
      end

      it 'returns global limit' do
        is_expected.to eq(1000)
      end

      context 'when namespace limit is set' do
        before do
          namespace.shared_runners_minutes_limit = 500
        end

        it 'returns namespace limit' do
          is_expected.to eq(500)
        end
      end
    end
  end

  describe '#shared_runners_minutes_limit_enabled?' do
    subject { namespace.shared_runners_minutes_limit_enabled? }

    context 'with project' do
      let!(:project) do
        create(:empty_project,
          namespace: namespace,
          shared_runners_enabled: true)
      end

      context 'when no limit defined' do
        it { is_expected.to be_falsey }
      end

      context 'when limit is defined' do
        before do
          namespace.shared_runners_minutes_limit = 500
        end

        it { is_expected.to be_truthy }
      end
    end

    context 'without project' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#shared_runners_minutes_used?' do
    subject { namespace.shared_runners_minutes_used? }

    context 'with project' do
      let!(:project) do
        create(:empty_project,
          namespace: namespace,
          shared_runners_enabled: true)
      end

      context 'when limit is defined' do
        context 'when limit is used' do
          let(:namespace) { create(:namespace, :with_used_build_minutes_limit) }

          it { is_expected.to be_truthy }
        end

        context 'when limit not yet used' do
          let(:namespace) { create(:namespace, :with_not_used_build_minutes_limit) }

          it { is_expected.to be_falsey }
        end

        context 'when minutes are not yet set' do
          it { is_expected.to be_falsey }
        end
      end

      context 'without limit' do
        let(:namespace) { create(:namespace, :with_build_minutes_limit) }

        it { is_expected.to be_falsey }
      end
    end

    context 'without project' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#full_name' do
    let(:group) { create(:group) }
    let(:nested_group) { create(:group, parent: group) }

    it { expect(group.full_name).to eq(group.name) }
    it { expect(nested_group.full_name).to eq("#{group.name} / #{nested_group.name}") }
  end

  describe '#parents' do
    let(:group) { create(:group) }
    let(:nested_group) { create(:group, parent: group) }
    let(:deep_nested_group) { create(:group, parent: nested_group) }
    let(:very_deep_nested_group) { create(:group, parent: deep_nested_group) }

    it 'returns the correct parents' do
      expect(very_deep_nested_group.parents).to eq([group, nested_group, deep_nested_group])
      expect(deep_nested_group.parents).to eq([group, nested_group])
      expect(nested_group.parents).to eq([group])
      expect(group.parents).to eq([])
    end
  end
end
