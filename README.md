# Kubernetes Sandbox

To Do:
* Use namespaces
* Include host machine for DNS searches
* Override REDIS_ENV for a deployment
* Template out yamls for unique deployments
* Provide unique URL per deployments
* Fix `mesg: ttyname failed: Inappropriate ioctl for device` error in `./boot.sh`

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
Unable to find image 'registry:2' locally
2: Pulling from library/registry
169185f82c45: Pull complete
046e2d030894: Pull complete
188836fddeeb: Pull complete
832744537747: Pull complete
7ceea07e80be: Pull complete
Digest: sha256:870474507964d8e7d8c3b53bcfa738e3356d2747a42adad26d0d81ef4479eb1b
Status: Downloaded newer image for registry:2
01edbbd8b65abaedcf9308fb36bed275a3498d7265736ea505aca47f1b3d3518
```

### Test Image

Build a small ruby container on the host machine and push to private registry.

Our ruby application:
* listens for http on `*:8080`
* expects to connect and ping a Redis server at: `redis:6379`

```
$ docker build -t ruby-app .
Sending build context to Docker daemon  316.9kB
Step 1/7 : FROM ruby:alpine
alpine: Pulling from library/ruby
6c40cc604d8e: Pull complete
4e0e4ac8c025: Pull complete
9a13ad0cfe1d: Pull complete
16f42435de28: Pull complete
Digest: sha256:8b3dd24063423797b27407f5bd5f475796ff6e786cad00d8a0927cd472c2d3be
Status: Downloaded newer image for ruby:alpine
  ---> 708614d8fa07
Step 2/7 : ADD ./ruby /
  ---> 2441a57d28f5
Step 3/7 : WORKDIR /
  ---> Running in 47b86af133fe
Removing intermediate container 47b86af133fe
  ---> 113e9c61d115
Step 4/7 : RUN apk --no-cache add --virtual build-deps g++ musl-dev make
  ---> Running in 2afc04dc5295
...
Step 7/7 : CMD ["ruby", "server.rb"]
  ---> Running in 50a3444be29e
Removing intermediate container 50a3444be29e
  ---> 1035103b18c8
Successfully built 1035103b18c8
Successfully tagged ruby-app:latest

$ docker image tag ruby-app localhost:5000/ruby-app

$ docker push localhost:5000/ruby-app
The push refers to repository [localhost:5000/ruby-app]
0aef3311492d: Pushed
0471056ed6bc: Pushed
70c4009aa202: Layer already exists
6c6387f7f161: Pushed
d7cf4b2f58ee: Pushed
5261915d5644: Pushed
503e53e365f3: Pushed
latest: digest: sha256:b4193d078282ce44f300a659abe25317781e2ff20bc4b4576e9c4ddfb302354e size: 1785
```

```
$ docker images
REPOSITORY                TAG                 IMAGE ID            CREATED              SIZE
ruby-app                  latest              1035103b18c8        About a minute ago   239MB
localhost:5000/ruby-app   latest              1035103b18c8        About a minute ago   239MB
ruby                      alpine              708614d8fa07        3 days ago           47.4MB
registry                  2                   d0eed8dad114        5 days ago           25.8MB
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
deployment.apps/redis created
service/redis created
deployment.apps/ruby-app-deployment created
service/ruby-app-service created
```

### Validate

```sh
kube@m1:~$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
redis-59879f974f-lhkf5                 1/1     Running   0          8m2s
redis-59879f974f-vf2zw                 1/1     Running   0          8m2s
ruby-app-deployment-58db4bdc5b-lq55s   1/1     Running   0          8m2s
ruby-app-deployment-58db4bdc5b-qdpk9   1/1     Running   0          8m2s

kube@m1:~$ kubectl get services
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
kubernetes         ClusterIP   10.96.0.1       <none>        443/TCP    13m
redis              ClusterIP   10.97.226.237   <none>        6379/TCP   3m21s
ruby-app-service   ClusterIP   10.105.34.59    <none>        80/TCP     8m24s

kube@m1:~$ curl 10.105.34.59
PONG
```

## Misc commands

Run containers on master node (remove taints): `kubectl taint nodes --all node-role.kubernetes.io/master-`

Remove all stopped or unused containers and images: `docker system prune -a`

Attach a shell to a running pod: `kubectl exec -it ruby-app-deployment-58db4bdc5b-sqpz2 -- /bin/sh`
