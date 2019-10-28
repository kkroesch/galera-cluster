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

  cluster = {
    "galera-210" => { :ip => "192.168.33.210", :cpus => 1, :mem => 1024 },
    "galera-220" => { :ip => "192.168.33.220", :cpus => 1, :mem => 1024 },
#    "galera-230" => { :ip => "192.168.33.230", :cpus => 1, :mem => 1024 }
  }
  cluster.each_with_index do |(hostname, info), index|
    config.vm.define hostname do |cfg|
      cfg.vm.provider :virtualbox do |vb, override|
        config.vm.box = "ubuntu/bionic64"
        override.vm.network :private_network, ip: "#{info[:ip]}"
        override.vm.hostname = hostname
        vb.name = hostname
        vb.customize ["modifyvm", :id, "--memory", info[:mem], "--cpus", info[:cpus], "--hwvirtex", "on"]
      end
    end
  end

  config.vm.provision "shell", inline: <<-SHELL
    # For Ubuntu, see https://www.digitalocean.com/community/tutorials/how-to-configure-a-galera-cluster-with-mariadb-on-ubuntu-18-04-servers
    # For Centos, see https://www.digitalocean.com/community/tutorials/how-to-configure-a-galera-cluster-with-mariadb-on-centos-7-servers
    apt-key adv --recv-keys \
      --keyserver-options http-proxy=http://clientproxy.corproot.net:8079 \
      --keyserver hkp://keyserver.ubuntu.com:80 \
      0xF1656F24C74CD1D8
      add-apt-repository 'deb [arch=amd64] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.4/ubuntu bionic main'
    apt-get update
    apt-get install -y mariadb-server rsync pwgen
    #cd /tmp
    #wget https://github.com/sysown/proxysql/releases/download/v2.0.6/proxysql_2.0.6-dbg-ubuntu18_amd64.deb
    #dpkgi -i  proxysql_2.0.6-dbg-ubuntu18_amd64.deb

    MYSQL_ROOT_PASSWORD=$(pwgen -1 24)
    mysqladmin password ${MYSQL_ROOT_PASSWORD}
    
    # OPTIONAL: Configure firewall for production
    # ufw allow 3306,4567,4568,4444/tcp
    # ufw allow 4567/udp

    ip=$(ifconfig enp0s8 | awk '/inet / { print $2; }')
    cp /vagrant/galera.cnf /etc/mysql/conf.d/
    echo wsrep_node_address=\"${ip}\" | tee -a /etc/mysql/conf.d/galera.cnf
    echo wsrep_node_name=\"$(hostname)\" | tee -a /etc/mysql/conf.d/galera.cnf
    systemctl stop mysql

    echo MySQL root password is set to "$(tput setaf 6)${MYSQL_ROOT_PASSWORD}$(tput sgr0)"
    echo On primary node, start "$(tput setaf 6)galera_new_cluster$(tput sgr0)"
  SHELL
end
