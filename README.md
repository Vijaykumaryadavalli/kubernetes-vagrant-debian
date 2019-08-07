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
