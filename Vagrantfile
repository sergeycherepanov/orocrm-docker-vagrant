Vagrant.configure(2) do |config|
  BOX_NAME="orocrm"
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end
  config.vm.network "private_network", type: "dhcp"
  config.vm.hostname = "orocrm.loc"

  # Hosts file manager
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = false

  # Dinamic ip resolver for vagrant hostmanager plugin
  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
    begin
      buffer = '';
        vm.communicate.execute("/sbin/ifconfig") do |type, data|
        buffer += data if type == :stdout
      end

      ips = []
        ifconfigIPs = buffer.scan(/inet addr:(\d+\.\d+\.\d+\.\d+)/)
        ifconfigIPs[0..ifconfigIPs.size].each do |ip|
          ip = ip.first

          next if /^(10|127)\.\d+\.\d+\.\d+$/.match ip

          if Vagrant::Util::Platform.windows?
            next unless system "ping #{ip} -n 1 -w 100>nul 2>&1"
          else
            next unless system "ping -c1 -t1 #{ip} > /dev/null"
          end

          ips.push(ip) unless ips.include? ip
        end
        ips.first
      rescue StandardError => exc
        return
      end
  end

  # avoid possible request "vagrant@127.0.0.1's password:" when "up" and "ssh"
  config.ssh.password = "vagrant"

  config.vm.provision :shell, :path => "enable-swap.sh"
  config.vm.provision :shell, :path => "provision.sh", :args => ["vagrant"]
end
