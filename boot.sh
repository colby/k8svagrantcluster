#!/bin/bash

vagrant up m1 s1 --provision

echo ">>> Starting to stand up Kubernetes cluster"

vagrant ssh m1 -- "
echo \">>> Becoming root and running kubeadm init\"

sudo su - root <<EOF
kubeadm config images pull
kubeadm init \
	--pod-network-cidr=10.244.0.0/16 \
       	--apiserver-advertise-address=10.10.3.10 \
	 | tee /root/kubeadm-init.output

echo \">>> Copying configs for kube user\"
mkdir -p /home/kube/.kube
cp -i /etc/kubernetes/admin.conf /home/kube/.kube/config
chown -R kube:kube /home/kube/.kube/config
EOF

echo \">>> Becoming kube and running kubectl to start networking\"

sudo su - kube <<EOF
kubectl apply -f \
	 https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
EOF
"

JOIN_CMD=$(vagrant ssh m1 -- "sudo tail -n2 /root/kubeadm-init.output")

echo ">>> Joining s1 into Kubernetes cluster"

vagrant ssh s1 -- "eval 'sudo $JOIN_CMD'"
# vagrant ssh s2 -- "eval 'sudo $JOIN_CMD'"

echo ">>> DONE"
