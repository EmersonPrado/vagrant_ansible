require 'yaml'
BOXES = YAML.load_file('etc/boxes.yaml')
VMS = YAML.load_file('etc/vms.yaml')

Vagrant.configure("2") do |config|

  config.vbguest.auto_update = false if Vagrant.has_plugin?("vagrant-vbguest")

  VMS.each do |name, confs|
    config.vm.define name do |vm|
      vm.vm.box = BOXES[confs[:box]]
      config.vm.provider "virtualbox" do |vb|
        vb.memory = confs[:ram] if confs.has_key?(:ram)
        vb.cpus = confs[:cpu] if confs.has_key?(:cpu)
      end
      vm.vm.hostname = name
      vm.vm.network :private_network, ip: confs[:ip] if confs.has_key?(:ip)
    end
  end
end
