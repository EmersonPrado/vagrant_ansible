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

Vagrant.configure("2") do |config|
  {
    'control' => {
      :box => :debian_8,
      :ram => 512,
      :cpu => 1,
      :ips => ["#{REDE}.2"],
    },
    'managed' => {
      :box => :debian_8,
      :ram => 512,
      :cpu => 1,
      :ips => ["#{REDE}.3"],
    },
  }.each do |name, settings|
    config.vm.define name do |mv|
      box = BOXES[settings[:box]]
      mv.vm.box = box[:name]
      mv.vm.box_version = box[:version] unless box[:version].nil?
      mv.vm.host_name = "#{name}.#{DOMAIN}"
      mv.vm.provider 'virtualbox' do |virtualbox|
        virtualbox.name = "vagrant-ansible-#{name}"
        virtualbox.memory = settings[:ram]
        virtualbox.cpus = settings[:cpu]
        box[:custom].each do |custom|
          virtualbox.customize custom
        end unless box[:custom].nil?
      end
      settings[:ips].each do |ip|
        mv.vm.network 'private_network', ip: ip
      end unless settings[:ips].nil?
    end
  end
end
