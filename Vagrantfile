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

MVS_CONTROLE = {
  'ansible' => {
    :box => :debian_8,
    :ram => 512,
    :cpu => 1,
    :ips => ["#{REDE}.2"],
    :ansible => {
      :playbook => 'ansible/playbook.yml',
      :groups   => {
        'tudo'  => ['nada'],
      },
    },
  },
}

MVS_GERENCIADAS = {
  'nada' => {
    :box => :debian_8,
    :ram => 512,
    :cpu => 1,
    :ips => ["#{REDE}.3"],
  },
}

# Caso hosts estejam sendo criados ou provisionados,
# revisa relações de confiança
unless (ARGF.argv() & ['up', 'provision', 'reload']).empty?

  # Vai para o diretório raiz do projeto para facilitar o trabalho com arquivos
  require "fileutils"
  FileUtils.cd(File.dirname(__FILE__))

  # Cria par de chaves para autenticação do host de controle com os gerenciados
  unless File.file?('.ssh/id_rsa')
    FileUtils.mkdir('.ssh') unless File.directory?('.ssh')
    system('ssh-keygen -N "" -t rsa -f .ssh/id_rsa')
  end

  # Cria arquivo com modelo das entradas para o /etc/hosts do nó de controle
  File.open(File.join('files', 'hosts'), 'w') do |arq_hosts|
    MVS_GERENCIADAS.each do |name, settings|
      settings[:ips].each do |ip|
        arq_hosts.write("#{ip}\t#{name}.#{DOMAIN}\t#{name}\n")
      end if settings.has_key?(:ips)
    end
  end

end

Vagrant.configure("2") do |config|
  (MVS_GERENCIADAS.merge(MVS_CONTROLE)).each do |name, settings|
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
      mv.vm.provision :shell do |shell|
        shell.name = 'Configura arquivo /etc/hosts'
        shell.path = 'scripts/configura_hosts.sh'
      end
      mv.vm.provision :shell do |shell|
        shell.name = 'Cria diretório de chaves'
        shell.inline = '[ -d ".ssh" ] || mkdir .ssh'
      end
      if settings.has_key?(:ansible)
        mv.vm.provision :shell do |shell|
          shell.name = 'Instala Ansible'
          shell.inline = "apt-get install $1 ansible"
          shell.args = ['-y -q --allow-unauthenticated']
        end
        mv.vm.provision :shell do |shell|
          shell.name = 'Inclui chave privada do Ansible'
          shell.inline = 'diff -q $1 $2 > $3 2>&1 || { cp $1 $2; chown $4 $2;}'
          shell.args = [
            '/vagrant/.ssh/id_rsa',
            '.ssh/id_rsa',
            '/dev/null',
            'vagrant:vagrant'
          ]
        end
      else
        mv.vm.provision :shell do |shell|
          shell.name = 'Inclui chave pública do Ansible nas chaves autorizadas'
          shell.inline = 'grep "`cat $1`" $2 > $3 2>&1 || cat $1 >> $2'
          shell.args = [
            '/vagrant/.ssh/id_rsa.pub',
            '.ssh/authorized_keys',
            '/dev/null'
          ]
        end
      end
    end
  end
end
