## Kubernetes

### Initialize Kubernetes cluster

```sh
$ vagrant ssh m1
vagrant@m1:~$ sudo kubeadm init --config=/manifests/system/kubeadm-config.yaml | tee /tmp/kubeadm-init.output
...
Your Kubernetes master has initialized successfully!
...
You can now join any number of machines by running the following on each node as root:

  kubeadm join 10.10.3.5:6443 --token foobar --discovery-token-ca-cert-hash sha256:HASH

vagrant@m1:~$ sudo mkdir -p /home/kube/.kube
vagrant@m1:~$ sudo cp -i /etc/kubernetes/admin.conf /home/kube/.kube/config
vagrant@m1:~$ sudo chown -R kube:kube /home/kube/.kube/config
vagrant@m1:~$ sudo su kube
kube@m1:~$ kubectl cluster-info
Kubernetes master is running at https://10.10.3.5:6443
KubeDNS is running at https://10.10.3.5:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

#### Create L2 networking
Using [MetalLB](https://github.com/google/metallb) for Layer 2 networking for load balancers.

```sh
$ vagrant ssh m1
vagrant@m1:~$ sudo su kube
kube@m1:~$ cd /tmp
kube@m1:~$ wget --no-verbose https://raw.githubusercontent.com/google/metallb/v0.7.3/manifests/metallb.yaml
kube@m1:~$ kubectl apply -f metallb.yaml
kube@m1:~$ kubectl apply -f /manifests/system/metallb-configmap.yaml
```

#### Create L3 networking

Using [Flannel](https://github.com/coreos/flannel) for Layer 3 networking between Kubernetes pods.

```sh
$ vagrant ssh m1
vagrant@m1:~$ sudo su kube
kube@m1:~$ cd /tmp
kube@m1:~$ wget --no-verbose https://raw.githubusercontent.com/coreos/flannel/v0.11.0/Documentation/kube-flannel.yml
kube@m1:~$ sed -i '/- --ip-masq/a\        - --iface=enp0s8' kube-flannel.yml
kube@m1:~$ kubectl apply -f kube-flannel.yml
```

### Join slaves

```sh
$ vagrant ssh m1 -c "grep 'kubeadm join' /tmp/kubeadm-init.output"
  kubeadm join 10.10.3.5:6443  --token foobar --discovery-token-ca-cert-hash sha256:HASH
```

```sh
$ vagrant ssh s1
vagrant@s1:~$ sudo kubeadm join 10.10.3.5:6443 --token foobar --discovery-token-ca-cert-hash sha256:HASH
...
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.

$ vagrant ssh s2
vagrant@s2:~$ sudo kubeadm join 10.10.3.5:6443 --token foobar --discovery-token-ca-cert-hash sha256:HASH
...
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.
```
