Vagrant.configure(2) do |config|
  BOX_NAME="orocrm"
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
    v.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]
  end

  if Vagrant::Util::Platform.windows?
    config.vm.synced_folder ".", "/vagrant"
  else
    config.vm.synced_folder ".", "/vagrant", type: "nfs", mount_options: ['rw', 'vers=3', 'tcp', 'fsc']
    config.nfs.map_uid = Process.uid
    config.nfs.map_gid = Process.gid
  end

  config.vm.network :public_network, :use_dhcp_assigned_default_route => true
  config.vm.network :private_network, ip: "192.168.58.101", auto_config: false

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = false

  config.vm.define 'orocrm' do |node|
    node.vm.hostname = 'orocrm.loc'
    node.vm.network :private_network, ip: '192.168.58.101'
  end

  # avoid possible request "vagrant@127.0.0.1's password:" when "up" and "ssh"
  config.ssh.password = "vagrant"

  config.vm.provision :shell, :path => "enable-swap.sh"
  config.vm.provision :shell, :path => "provision.sh", :args => ["vagrant"]
end
