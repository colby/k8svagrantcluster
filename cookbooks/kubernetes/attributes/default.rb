node.default['docker']['packages'] = %w(docker.io)
node.default['kubernetes']['user'] = 'kube'
node.default['kubernetes']['group'] = 'kube'
node.default['kubernetes']['packages'] = %w(
  kubeadm
  kubectl
  kubelet
)
