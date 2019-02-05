# Kubernetes Sandbox

## Docker

### Registry

Run a private Docker Image registry on the host machine. 

```sh
$ docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v registry:/var/lib/registry \
  registry:2
```

### Test Image

Build a small ruby container on the host machine and push to private registry.

Our ruby application:
* listens for http on `*:8080`
* expects to connect and ping a Redis server at: `redis:6379`

```sh
$ docker build -t ruby-app .
$ docker image tag ruby-app localhost:5000/ruby-app
$ docker push localhost:5000/ruby-app
```

```
$ docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
ruby-app                  latest              7f263fec447a        18 minutes ago      222MB
localhost:5000/ruby-app   latest              7f263fec447a        18 minutes ago      222MB
ruby                      alpine              04a129682918        45 hours ago        40MB
registry                  2                   d0eed8dad114        2 days ago          25.8MB
```

## Kubernetes

### Standup master

```sh
$ vagrant up --provision
$ vagrant ssh
vagrant@m1:~$ sudo kubeadm config images pull
vagrant@m1:~$ sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.10.3.10
...
Your Kubernetes master has initialized successfully!
...
You can now join any number of machines by running the following on each node as root:

  kubeadm join 10.10.3.10:6443 --token foobar --discovery-token-ca-cert-hash sha256:HASH

vagrant@m1:~$ sudo mkdir -p /home/kube/.kube
vagrant@m1:~$ sudo cp -i /etc/kubernetes/admin.conf /home/kube/.kube/config
vagrant@m1:~$ sudo chown -R kube:kube /home/kube/.kube/config
vagrant@m1:~$ sudo su kube
kube@m1:~$ kubectl cluster-info
Kubernetes master is running at https://10.10.3.10:6443
KubeDNS is running at https://10.10.3.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

### Create intra-pod networking

```sh
$ vagrant ssh
vagrant@m1:~$ sudo su kube
kube@m1:~$ kubectl apply -f \
 https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
```

### Join slaves
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

### Create application deployment

```sh
$ vagrant ssh m1
vagrant@m1:~$ sudo su kube
kube@m1:~$ kubectl create -f /manifests --recursive
deployment.apps/ruby-app-deployment created
```

## Misc commands
Run containers on master node (remove taints): `kubectl taint nodes --all node-role.kubernetes.io/master-`
Remove all stopped or unused containers and images: `docker system prune -a`
