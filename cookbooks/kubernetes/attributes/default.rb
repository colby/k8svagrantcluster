node.default['kubernetes']['user'] = 'kube'
node.default['kubernetes']['group'] = 'kube'
node.default['kubernetes']['packages'] = %w(
  kubeadm
  kubectl
  kubelet
)
