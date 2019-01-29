node.default['kubernetes']['user'] = 'kube'
node.default['kubernetes']['group'] = 'kube'
node.default['kubernetes']['packages'] = %w(
  docker.io
  kubeadm
  kubectl
  kubelet
)
