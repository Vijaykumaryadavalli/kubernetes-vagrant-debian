# Kubernetes box

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
2. Copy kube-config to ~/.kube/config (`mkdir -p ~/.kube && copy ./kube-config ~/.kube/config`)
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

To deploy, go into the folder and execute `kubectl -f .`

After that, to access specified application, add entries to /etc/hosts file:

- 192.168.16.10 nginx
- 192.168.16.10 camunda

And open in browser http://nginx or http://camunda.

To learn more how deployments, ingress and services work, consult pages on https://kubernetes.io
