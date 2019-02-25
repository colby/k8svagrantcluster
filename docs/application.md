## Kubernetes Application

### Create application deployment

```sh
$ vagrant ssh m1
vagrant@m1:~$ sudo su kube
kube@m1:~$ kubectl create -f /manifests/application --recursive
deployment.apps/redis created
service/redis created
deployment.apps/ruby-app created
service/ruby-app created
```

### Validate

```sh
$ vagrant ssh m1
kube@m1:~$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
redis-59879f974f-lhkf5                 1/1     Running   0          8m2s
redis-59879f974f-vf2zw                 1/1     Running   0          8m2s
ruby-app-58db4bdc5b-lq55s              1/1     Running   0          8m2s
ruby-app-58db4bdc5b-qdpk9              1/1     Running   0          8m2s

kube@m1:~$ kubectl get services
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
kubernetes         ClusterIP   10.96.0.1        <none>        443/TCP    12m
redis              ClusterIP   10.108.230.57    <none>        6379/TCP   11m
ruby-app           ClusterIP   10.106.118.239   <none>        80/TCP     11m

kube@m1:~$ curl 10.106.118.239
PONG

kube@m1:~$ kubectl scale --replicas=0 deployment redis
deployment.extensions/redis scaled

kube@m1:~$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
ruby-app-58db4bdc5b-r6jrv              1/1     Running   0          14s
ruby-app-58db4bdc5b-xf947              1/1     Running   0          10m

kube@m1:~$ curl 10.106.118.239
error: Error connecting to Redis on redis:6379 (Errno::ECONNREFUSED)
```
