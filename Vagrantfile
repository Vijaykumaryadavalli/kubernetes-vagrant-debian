Vagrant.configure("2") do |config|
  config.vm.hostname = "kubetest"
  config.vm.define "kubetest"
  
  config.ssh.insert_key = true
  config.ssh.forward_agent = true

  # WebUI https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
  config.vm.network :forwarded_port, guest: 8001, host: 8001
  # Cluster access via kubectl
  config.vm.network :forwarded_port, guest: 8443, host: 8443
  # SSH & SCP
  config.vm.network :forwarded_port, guest: 2222, host: 2222

  config.vm.provider "virtualbox" do |vb|
    vb.name = "kubetest"
    vb.memory = 4096
  end

  # https://app.vagrantup.com/generic/boxes/debian9
  config.vm.box = "generic/debian9"
  config.vm.provision "shell", path: "kube.sh"
end
