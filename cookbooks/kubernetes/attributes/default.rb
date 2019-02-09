default['kubernetes']['group'] = 'kube'
default['kubernetes']['helm'] = false
default['kubernetes']['packages'] = %w(
  kubeadm
  kubectl
  kubelet
)
default['kubernetes']['user'] = 'kube'
