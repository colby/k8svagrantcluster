## Miscellaneous commands

Run containers on master node (remove taints): `kubectl taint nodes --all node-role.kubernetes.io/master-`

Remove all stopped or unused containers and images: `docker system prune -a`

Attach a shell to a running pod: `kubectl exec -it ruby-app-58db4bdc5b-sqpz2 -- /bin/sh`
