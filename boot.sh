#!/bin/bash

set -e

vagrant up --provision

echo ">>> Starting to stand up Kubernetes cluster"

vagrant ssh m1 -- "
echo \">>> Becoming root and running kubeadm init\"

sudo su - root <<EOF
kubeadm init --config=/manifests/kubeadm-config.yaml | tee /root/kubeadm-init.output

echo \">>> Copying configs for kube user\"
mkdir -p /home/kube/.kube
cp -i /etc/kubernetes/admin.conf /home/kube/.kube/config
chown -R kube:kube /home/kube/.kube
EOF

echo \">>> Becoming kube user\"

sudo su - kube <<EOF
cd /tmp
echo \">>> Installing MetalLB\"
wget --no-verbose https://raw.githubusercontent.com/google/metallb/v0.7.3/manifests/metallb.yaml
kubectl apply -f metallb.yaml
kubectl apply -f /manifests/metallb-configmap.yaml

echo \">>> Installing Flannel networking\"
wget --no-verbose https://raw.githubusercontent.com/coreos/flannel/v0.11.0/Documentation/kube-flannel.yml
sed -i '/- --ip-masq/a\        - --iface=enp0s8' kube-flannel.yml
kubectl apply -f kube-flannel.yml
EOF
"

JOIN_CMD=$(vagrant ssh m1 -- "sudo tail -n2 /root/kubeadm-init.output")

echo ">>> Joining slaves into Kubernetes cluster"

vagrant ssh s1 -- "eval 'sudo $JOIN_CMD'"
vagrant ssh s2 -- "eval 'sudo $JOIN_CMD'"

echo ">>> DONE"
