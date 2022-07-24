# Kubernetes box

This project is cloned from https://github.com/huksley/kubernetes-vagrant-debian.git

I have modified some code in kube.sh and Vagrantfile related to my application.

The instructions are below

Switch to the git project folder as below:

```bash
cd kubernetes-vagrant-debian
```

Initializes test Kubernetes environment using Vagrant and VirtualBox.
To run locally, clone this repo and execute:

```bash
vagrant up
vagrant ssh -c ./kube-proxy.sh
```

After that, open in your browser http://localhost:8001/welcome/
and follow instructions there.

## Useful commands

See cheatsheet for kubectl commands: https://kubernetes.io/docs/reference/kubectl/cheatsheet/

### Accessing kubernetes outside of VM

1. Download kubectl to local environment
2. Copy kube-config to ~/.kube/config (`mkdir -p ~/.kube && cp ./kube-config ~/.kube/config`)
3. Copy certs using provided script (`./copycerts`)
4. Verify connection by executing `kubectl version`

### Running pods

Execute following command to see list of pods running:

```
kubectl get pods -n kube-system
```

### Deploying apps

This example setup includes two apps able to be deployed to Kubernetes.

- nginx
- camunda

To deploy, go into the folder and execute `kubectl apply -f .`

After that, to access specified application, add entries to /etc/hosts file:

- 192.168.16.10 nginx.local
- 192.168.16.10 camunda.local

And open in browser http://nginx.local or http://camunda.local

To learn more how deployments, ingress and services work, consult pages on https://kubernetes.io

## Camunda

Camunda BPM is a Bussines Process Management engine with UI apps to get started easy.
This Kubernetes setup includes it with username: demo and password: 123

## Full setup

```bash
# Install Vagrant and VirtualBox
# Bring machine up
vagrant up
# Configure local kubectl
mkdir -p ~/.kube
./copycerts
cp kube-config ~/.kube/config
# Download kubectl binary
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl
chmod a+x kubectl
# Check it works
./kubectl version
# Deploy services
./kubectl apply -f nginx
./kubectl apply -f camunda
# Add hostnames so they can be accessed
echo "192.168.16.10 nginx.local" | sudo tee -a /etc/hosts
echo "192.168.16.10 camunda.local" | sudo tee -a /etc/hosts
# Check it out
curl http://nginx.local
```
