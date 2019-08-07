#!/bin/bash
set -e

sudo apt update
sudo apt upgrade -y

if [ ! -f /usr/local/bin/kubectl ]; then
    KUBECTLVER=`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`
    echo "💡 Downloading kubectl ${KUBECTLVER}"
    curl -sLO https://storage.googleapis.com/kubernetes-release/release/${KUBECTLVER}/bin/linux/amd64/kubectl
    sudo mv ./kubectl /usr/local/bin
    sudo chmod a+x /usr/local/bin/kubectl
fi

kubectl version --client=true

if [ ! -f /usr/local/bin/minikube ]; then
    echo "💡 Downloading latest minikube"
    curl -sLo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo mv ./minikube /usr/local/bin
    chmod a+x /usr/local/bin/minikube
fi

minikube version

if [ ! -d /etc/docker ]; then
    echo "💡 Installing Docker CE"
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

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli
fi

if [ ! -d /etc/kubernetes ]; then
    echo "💡 Starting kubernetes via Docker driver"
    sudo minikube start --vm-driver=none
    sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml
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

if [ ! -d welcome ]; then
    mkdir -p welcome
    cat <<EOM >welcome/index.html
<html>
<title>Kubernetes test</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous"
<body>
<h1>Kubernetes test</h1>
<p>
Congratulations! You installed local test Kubernetes environment.
</p>
<p>
To learn more about kubernetes go to: <a href="https://kubernetes.io">kubernetes.io</a>.
</p>
<p>
To open a <a href="https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/">WebUI</a> locally, first run:
<pre>
vagrant ssh -c ./kube-proxy.sh
</pre>
After that, click here:
<a href="/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/">WebUI</a>
</p>

You will need a token to login (select [x] Token auth). 
You can see a token in the last lines of <code>vagrant up command</code>.
If you miss a token, stop <code>vagrant ssh ...</code> and run <code>vagrant provision</code> again to show the token.
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