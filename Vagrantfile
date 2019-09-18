# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Use the same key for each machine 
  config.ssh.insert_key = false
  config.ssh.forward_agent = true

  # Proxy settings (first install `vagrant plugin install vagrant-proxyconf`)
  config.proxy.http     = "http://clientproxy.corproot.net:8079"
  config.proxy.https    = "http://clientproxy.corproot.net:8079"
  config.proxy.no_proxy = "localhost,127.0.0.1"

  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end

  config.vm.define "galera-210" do |vagrant1|
    vagrant1.vm.box = "ubuntu/bionic64"
    vagrant1.vm.network "private_network", ip: "192.168.33.210"
    vagrant1.vm.hostname = 'galera-210'
  end

  config.vm.define "galera-220" do |vagrant2|
    vagrant2.vm.box = "ubuntu/bionic64"
    vagrant2.vm.network "private_network", ip: "192.168.33.220"
    vagrant2.vm.hostname = 'galera-220'
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    # See https://www.digitalocean.com/community/tutorials/how-to-configure-a-galera-cluster-with-mariadb-on-ubuntu-18-04-servers
    # For Centos, see https://www.digitalocean.com/community/tutorials/how-to-configure-a-galera-cluster-with-mariadb-on-centos-7-servers
    apt-key adv --recv-keys \
      --keyserver-options http-proxy=http://clientproxy.corproot.net:8079 \
      --keyserver hkp://keyserver.ubuntu.com:80 \
      0xF1656F24C74CD1D8
      add-apt-repository 'deb [arch=amd64] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.4/ubuntu bionic main'
    apt-get update
    apt-get install -y mariadb-server rsync
    cd /tmp
    wget https://github.com/sysown/proxysql/releases/download/v2.0.6/proxysql_2.0.6-dbg-ubuntu18_amd64.deb
    dpkgi -i  proxysql_2.0.6-dbg-ubuntu18_amd64.deb
    mysql -e 'set password = password("Ohs7sikoThai");'

    # OPTIONAL: Configure firewall for production
    # ufw allow 3306,4567,4568,4444/tcp
    # ufw allow 4567/udp
    ip=$(ifconfig enp0s8 | awk '/inet / { print $2; }')
    cp /vagrant/galera.cnf /etc/mysql/conf.d/
    echo wsrep_node_address=\"${ip}\" >> /etc/mysql/conf.d/galera.cnf
    echo wsrep_node_name=\"$(hostname)\" >>  /etc/mysql/conf.d/galera.cnf
  SHELL
end
