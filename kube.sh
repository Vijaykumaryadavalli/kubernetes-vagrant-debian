#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
sudo apt-get update
sudo apt-get upgrade -y

## Specify versions you want

# Kubernetes cluster version
KUBEVER=v1.15.2
# usually matches Kubernetes version, see https://kubernetes.io/docs/reference/kubectl/kubectl/
# and curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt
KUBECTLVER=v1.15.2
# https://github.com/kubernetes/minikube/releases
MINIKUBEVER=v1.2.0
# apt-cache policy docker-ce
DOCKERVER=5:18.09.8
# apt-cache policy containerd.io
CONTAINERDVER=1.2.2-3

if [ ! -f /usr/local/bin/kubectl ]; then
    echo "💡 Downloading kubectl ${KUBECTLVER}"
    curl -sLO https://storage.googleapis.com/kubernetes-release/release/${KUBECTLVER}/bin/linux/amd64/kubectl
    sudo mv ./kubectl /usr/local/bin
    sudo chmod a+x /usr/local/bin/kubectl
fi

kubectl version --client=true

if [ ! -f /usr/local/bin/minikube ]; then
    echo "💡 Downloading minikube ${MINIKUBEVER}"
    curl -sLo minikube https://storage.googleapis.com/minikube/releases/${MINIKUBEVER}/minikube-linux-amd64
    sudo mv ./minikube /usr/local/bin
    chmod a+x /usr/local/bin/minikube
fi

minikube version

if [ ! -d /etc/docker ]; then
    echo "💡 Installing Docker CE ${DOCKERVER} with containerd ${CONTAINERDVER}"
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        gnupg2 \
        software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/debian \
$(lsb_release -cs) \
stable"

    sudo apt-get update
    sudo apt-get install -y docker-ce=${DOCKERVER}* docker-ce-cli=${DOCKERVER}* containerd.io=${CONTAINERDVER}*
fi

if [ ! -d /etc/kubernetes ]; then
    echo "💡 Starting kubernetes via Docker driver"
    #  echo "💡 Starting kubernetes via virtualbox driver"
    sudo minikube start --vm-driver=none --kubernetes-version=${KUBEVER}
    sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml
    # sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
    # sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/mandatory.yaml
    sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/130af33510882ae62c89277f2ad0baca50e0fafe/deploy/static/mandatory.yaml
    sudo minikube addons enable ingress
    # sudo minikube start
fi

if [ ! -d .minukube ]; then
    echo "💡 Copying credentials for Vagrant user"
    sudo cp -r /root/.minikube .
    sudo chown -R vagrant .minikube
fi

if [ ! -d .kube ]; then
    mkdir -p .kube
    echo "💡 Enabling access for Vagrant user"
    sudo cat /root/.kube/config | sed -re "s/\/root/\/home\/vagrant/g" > .kube/config
fi

if [ ! -f ./dashboard-adminuser.yaml ]; then
    echo "💡 Creating admin user"
    cat <<EOM >./dashboard-adminuser.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
EOM
    kubectl apply -f ./dashboard-adminuser.yaml
fi

TOKEN_NAME=`sudo kubectl -n kube-system get secret | grep default-token | awk '{print $1}'`
echo "Token name: ${TOKEN_NAME}"

if [ ! -d welcome2 ]; then
    mkdir -p welcome
    cat <<EOM >welcome/index.html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
<title>Kubernetes test</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
</head>
<body>
<div class="container">
<h1>Kubernetes test</h1>
<p>
Congratulations! You installed local test Kubernetes environment.
</p>
<p>
To learn more about kubernetes go to: <a href="https://kubernetes.io">kubernetes.io</a>.
</p>
<p>
To open a <a href="https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/">WebUI</a> locally, first run:
<code>
vagrant ssh -c ./kube-proxy.sh
</code>
</p>
<p>
After that, click here:
<a href="/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/">WebUI</a>
</p>

<p>
You will need a token to login (select [x] Token auth). 
You can see a token in the last lines of <code>vagrant up command</code>.
</p>
<p>
If you miss a token, stop <code>vagrant ssh ...</code> and run <code>vagrant provision</code> again to show the token.
</p>
</div>
</body>
</html>
EOM
fi

if [ ! -f ./kube-proxy.sh ]; then
    cat <<EOM >./kube-proxy.sh
sudo kubectl proxy --address='0.0.0.0' --www=welcome --www-prefix=/welcome/
EOM
    sudo chmod a+x ./kube-proxy.sh
fi

echo "Use this token to auth in dashboard:"
sudo kubectl -n kube-system describe secret ${TOKEN_NAME} | grep token: | awk '{print $2}'

echo "Run now vagrant ssh -c ./kube-proxy.sh"
echo "And open in browser http://localhost:8001/welcome/"
