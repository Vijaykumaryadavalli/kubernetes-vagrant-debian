Vagrant.configure("2") do |config|
  config.vm.hostname = "kubetest"
  config.vm.define "kubetest"
  
  config.ssh.insert_key = true
  config.ssh.forward_agent = true

  # config.ssh.username = "vagrant"
  # config.ssh.private_key_path = "E:/All Virtual Boxes via Vagrant/Minikube/kubernetes-vagrant-debian/.vagrant/machines/kubetest/virtualbox/private_key"
  # config.ssh.password = "vagrant"
  
  # https://cloudavail.com/2014/07/08/vagrant-network-vbox-adapters/
  # WebUI https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
  config.vm.network :forwarded_port, guest: 8001, host: 8001
  # Cluster access via kubectl
  config.vm.network :forwarded_port, guest: 8443, host: 8443
  # SSH & SCP
  config.vm.network :forwarded_port, guest: 22, host: 2222
  # Host-only adapter
  config.vm.network "private_network", :ip => '192.168.16.10'

  config.vm.provider "virtualbox" do |vb|
    vb.name = "kubetest"
    vb.memory = 4096
  end

  # https://app.vagrantup.com/generic/boxes/debian9
  config.vm.box = "generic/debian9"
  config.vm.provision "shell", path: "kube.sh"
end
