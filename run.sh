#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"

export DEBIAN_FRONTEND=noninteractive
export KUBELET_EXTRA_ARGS="--cgroup-driver=systemd"

install-basis() {
  sudo apt-get update
  sudo apt install -y \
       apt-transport-https \
       ca-certificates \
       curl \
       software-properties-common
  sudo apt-get upgrade
}

install-utils() {
  apt-get update
  apt-get install -yq \
          jq nmap iproute2  
}

add-docker-apt-list() {
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository \
    "deb [arch=amd64] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"

  apt-get update && \
    apt-cache policy docker-ce && \
    apt-get install -y docker-ce
}

setup-dockerd() {
  cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
}

add-k8s-apt-list() {
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  cat > /etc/apt/sources.list.d/kubernetes.list <<EOF
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

  swapoff -a
  apt-get update
  apt-get install -y kubelet kubeadm kubectl
  apt-mark hold kubelet kubeadm kubectl

  systemctl daemon-reload
  systemctl restart kubelet
}

kubeadm-init() {
  kubeadm init --pod-network-cidr=10.244.0.0/16
}

install-pod-network() {
  kubectl apply -f https://docs.projectcalico.org/v3.10/manifests/calico.yaml
}

k8s-admin-conf() {
  mkdir -p $HOME/.kube
  cp /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config
}

on-master() {
  install-basis
  install-utils
  add-docker-apt-list
  setup-dockerd
  add-k8s-apt-list
  kubeadm-init
  install-pod-network
  k8s-admin-conf
}


"$@"
