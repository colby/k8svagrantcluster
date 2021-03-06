#!/bin/bash

set -e

vagrant up --provision

echo ">>> Starting to stand up Kubernetes cluster"

vagrant ssh m1 -- "
echo \">>> Becoming root and running kubeadm init\"
sudo su - root <<EOF
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.10.3.5 | tee /tmp/kubeadm-init.output
#kubeadm init --config=/manifests/system/kubeadm-config.yaml | tee /tmp/kubeadm-init.output

echo \">>> Copying configs for kube user\"
mkdir -p /home/kube/.kube
cp -i /etc/kubernetes/admin.conf /home/kube/.kube/config
chown -R kube:kube /home/kube/.kube
EOF

echo \">>> Becoming kube user\"

sudo su - kube <<EOF
cd /tmp
echo \">>> Installing Flannel networking\"
wget --no-verbose https://raw.githubusercontent.com/coreos/flannel/v0.11.0/Documentation/kube-flannel.yml
sed -i '/- --ip-masq/a\        - --iface=enp0s8' kube-flannel.yml
kubectl apply -f kube-flannel.yml

echo \">>> Installing MetalLB\"
wget --no-verbose https://raw.githubusercontent.com/google/metallb/v0.7.3/manifests/metallb.yaml
kubectl apply -f metallb.yaml
kubectl apply -f /manifests/system/metallb-configmap.yaml
EOF
"

JOIN_CMD=$(vagrant ssh m1 -- "tail -n2 /tmp/kubeadm-init.output")

#echo ">>> Joining addition master into Kubernetes cluster"
#vagrant ssh m2 -- "eval 'sudo $JOIN_CMD'"

echo ">>> Joining slaves into Kubernetes cluster"

vagrant ssh s1 -- "eval 'sudo $JOIN_CMD'"
vagrant ssh s2 -- "eval 'sudo $JOIN_CMD'"

echo ">>> DONE"
