require 'yaml'
BOXES = YAML.load_file('etc/boxes.yaml')
VMS = YAML.load_file('etc/vms.yaml')
destinies = []
VMS.each do |name, confs|
  destinies << confs[:ip]
end

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
      vm.vm.provision :shell do |shell|
        shell.name = "Configure SSH origins"
        shell.path = "bin/ssh_origin.sh"
        shell.args = [name] + destinies
      end if confs.has_key?(:ssh_origin)
    end
  end
end
