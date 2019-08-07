# Kubernetes box

Initializes test Kubernetes environment using Vagrant and VirtualBox.
To run locally, clone this repo and execute:

```bash
vagrant up
vagrant ssh -c ./kube-proxy.sh
```

After that, open in your browser http://localhost:8001/welcome/
and follow instructions there.
