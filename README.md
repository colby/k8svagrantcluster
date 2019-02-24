# Kubernetes Vagrant Cluster

This project builds a multi-master Kubernetes cluster on a Vagrant network. 

There are four nodes, two masters and two slaves. The masters share the virtual
ip address `10.10.3.5` using `keepalived`. The `keepalived` service issues
health checks to each master node on the local interface for port `6443` to
test if Kubernetes is up and running. 

Kubernetes is used to host two services. A simple Ruby web application and
Redis. The application is available at `LINK:80`, using
[Flannel](https://github.com/coreos/flannel) and
[Metallb](https://github.com/google/metallb).

## Dependencies 

* Docker
* Vagrant
* Virtualbox
* 8GB of RAM

## Steps
1. [Prep the host machine](docs/host.md)
1. [Boot and provision the Vagrant cluster](docs/vagrant.md)
1. [Initialize the Kubernetes cluster](docs/kubernetes.md)
1. [Add additional nodes](docs/kubernetes.md)
1. [Deploy application](docs/application.md)
1. [Take down primary master](docs/master-failover.md)
