require 'pharos/config'
require 'pharos/host/ubuntu/ubuntu_xenial'

describe Pharos::Host::UbuntuXenial do
  let(:host) do
    host = Pharos::Configuration::Host.new(peer_address: '192.168.100')
    host.cpu_arch = Pharos::Configuration::CpuArch.new(id: 'amd64')
    host
  end
  let(:ssh) { instance_double(Pharos::Transport::SSH) }
  let(:cluster_config) { double(:cluster_config, image_repository: 'quay.io/kontena') }
  let(:subject) { described_class.new(host) }
  before do
    allow(host).to receive(:config).and_return(cluster_config)
    allow(host).to receive(:transport).and_return(ssh)
  end

  describe '#docker_version' do
    it 'returns correct version' do
      expect(subject.docker_version).to eq(Pharos::Host::UbuntuXenial::DOCKER_VERSION)
    end
  end

  describe '#configure_container_runtime' do
    context 'docker' do
      it 'configures docker' do
        allow(subject).to receive(:docker?).and_return(true)
        allow(subject).to receive(:insecure_registries)
        expect(subject).to receive(:exec_script).with('configure-docker.sh', anything)
        subject.configure_container_runtime
      end
    end

    context 'unknown' do
      it 'raises error' do
        allow(host).to receive(:container_runtime).and_return('moby')
        expect {
          subject.configure_container_runtime
        }.to raise_error(Pharos::Error)
      end
    end
  end
end
