# coding: utf-8

# Arquivo de configuração do Vagrant para teste de provisionamento via Ansible

# Autor: Emerson Prado

DOMAIN = 'prevnet'
REDE = '192.168.20'
BOXES = {
  :debian_8 => {
    :name    => 'ARTACK/debian-jessie',
    :version => '8.1.0',
    :custom  => [
      ['modifyvm', :id, '--usb', 'off'],
    ],
  },
}

# Cria par de chaves para autenticação do host de controle com os gerenciados
# caso hosts estejam sendo criados ou provisionados
unless (ARGF.argv() & ['up', 'provision', 'reload']).empty?
  require "fileutils"
  FileUtils.cd(File.dirname(__FILE__))
  unless File.file?('.ssh/id_rsa')
    FileUtils.mkdir('.ssh') unless File.directory?('.ssh')
    system('ssh-keygen -N "" -t rsa -f .ssh/id_rsa')
  end
end

Vagrant.configure("2") do |config|
  {
    'managed' => {
      :box => :debian_8,
      :ram => 512,
      :cpu => 1,
      :ips => ["#{REDE}.3"],
    },
    'control' => {
      :box => :debian_8,
      :ram => 512,
      :cpu => 1,
      :ips => ["#{REDE}.2"],
    },
  }.each do |name, settings|
    config.vm.define name do |mv|
      box = BOXES[settings[:box]]
      mv.vm.box = box[:name]
      mv.vm.box_version = box[:version] if box.has_key?(:version)
      mv.vm.host_name = "#{name}.#{DOMAIN}"
      mv.vm.provider 'virtualbox' do |virtualbox|
        virtualbox.name = "vagrant-ansible-#{name}"
        virtualbox.memory = settings[:ram]
        virtualbox.cpus = settings[:cpu]
        box[:custom].each do |custom|
          virtualbox.customize custom
        end if box.has_key?(:custom)
      end
      settings[:ips].each do |ip|
        mv.vm.network 'private_network', ip: ip
      end if settings.has_key?(:ips)
      mv.vm.provision :shell do |shell|
        shell.name = 'Configura proxy do APT'
        shell.inline = "if ! diff -q $1 $2 2> $3 ; then cp $1 $2 ; $4 ; fi"
        shell.args = [
          '/vagrant/files/proxy',
          '/etc/apt/apt.conf.d/proxy',
          '/dev/null',
          'apt-get update',
        ]
      end
    end
  end
end
