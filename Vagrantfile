VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box     = 'centos-6.5'
  config.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box'

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '1024']
  end

  config.vm.provision :puppet, :options => ['--debug', '--verbose', '--summarize', '--reports', 'store'] do |puppet|
    puppet.manifests_path = 'manifests'
    puppet.module_path    = 'modules'
    puppet.manifest_file  = 'base.pp'
  end

  config.vm.define :server do |conf|
    conf.vm.hostname = 'sensu-server'
    conf.vm.network :private_network, ip: '33.33.33.90'
    conf.vm.network :forwarded_port, guest: 8080, host: 8080
  end

  config.vm.define :client do |conf|
    conf.vm.hostname = 'sensu-client'
    conf.vm.network :private_network, ip: '33.33.33.91'
  end

end
