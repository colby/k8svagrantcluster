# Kubernetes Sandbox

## Standup master

```sh
$ vagrant up --provision
$ vagrant ssh
vagrant@m1:~$ sudo kubeadm config images pull
vagrant@m1:~$ sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.10.3.10
...
Your Kubernetes master has initialized successfully!
...
You can now join any number of machines by running the following on each node
as root:

  kubeadm join 10.10.3.10:6443 --token foobar --discovery-token-ca-cert-hash sha256:HASH

vagrant@m1:~$ sudo mkdir -p /home/kube/.kube
vagrant@m1:~$ sudo cp -i /etc/kubernetes/admin.conf /home/kube/.kube/config
vagrant@m1:~$ sudo chown -R kube:kube /home/kube/.kube/config
vagrant@m1:~$ sudo su kube
kube@m1:~$ kubectl cluster-info
Kubernetes master is running at https://10.10.3.10:6443
KubeDNS is running at https://10.10.3.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

## Join slaves
```sh
$ vagrant ssh s1
vagrant@s1:~$ sudo kubeadm join 10.10.3.10:6443 --token foobar --discovery-token-ca-cert-hash sha256:HASH
...
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.

$ vagrant ssh s2
vagrant@s2:~$ sudo kubeadm join 10.10.3.10:6443 --token foobar --discovery-token-ca-cert-hash sha256:HASH
...
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.
```

## Plugins
```sh
$ vagrant ssh
vagrant@m1:~$ sudo su kube
kube@m1:~$ kubectl apply -f \
  https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
```

## Docker

Build a small ruby container that expects to connect and ping a Redis server at: `redis:6379`

```sh
$ docker build -t ruby-app .
$ docker run -p 8080:8080 ruby-app
```
