#!/bin/bash
set -e
echo -e ""
echo -e "We are setting up Kubernetes using kubeadm on Ubuntu:18.04"
echo ""
sudo su -
echo -e "Turning off swap"
swapoff -a
echo -e "Installing dependencies"
apt update -y
apt-get install ebtables ethtool apt-transport-https -y
echo -e "Adding Kubernetes repo"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
echo -e "Installing Docker, Kubelet, Kubeadm, kubectl"
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
echo -e "Adding Docker GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io
apt-get update && apt-get install -y kubelet kubeadm kubectl
echo ""
echo -e "Setting up cluster"
kubeadm init --pod-network-cidr=192.168.0.0/16
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
echo -e "Installing Flannel for K8s"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml
echo ""
echo -e "To join a node to the K8s cluster run below command with token being generated above..."
echo -e "kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash> to add node to your K8s cluster"
sleep 5
echo -e "In case if you want to run container on your master node, run this command"
kubectl taint nodes --all node-role.kubernetes.io/master-
echo -e "Displaying the nodes in your cluster"
echo ""
kubectl get no
echo ""
echo "#########################################"
echo -e "Deploying Nginx Ingress"
kubectl apply -f ingress-mandatory.yaml
echo ""
echo -e "Displaying all K8s objects running in ingress-nginx namespace"
kubectl get all -n ingress-nginx
echo ""
echo -e "Deploying OWASP juiceshop application"
kubectl apply -f juiceshop-namespace.yaml -f juiceshop-deployment.yaml -f juiceshop-service.yaml -f juiceshop-ingress.yaml
echo ""
echo -e "Displaying all K8s objects running in juiceshop namespace"
kubectl get all -n juiceshop
echo ""
echo -e "You can access your juiceshop application as http://<Any-K8s-NodeIP>:31000"
echo -e "You can access your juiceshop application with Ingres as http://juiceshop.example.com:32000"
echo -e "Make sure you add juiceshop.example.com entry in your /etc/hosts file"
echo ""
