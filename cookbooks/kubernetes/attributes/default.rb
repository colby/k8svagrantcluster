default['kubernetes']['group'] = 'kube'
default['kubernetes']['helm'] = false
default['kubernetes']['packages'] = %w(
  kubeadm
  kubectl
  kubelet
)
default['kubernetes']['user'] = 'kube'

case node['lsb']['codename']
# NOTE: currently no distro folder for bionic on https://packages.cloud.google.com/apt/dists
when 'bionic'
  default['kubernetes']['distribution'] = 'kubernetes-xenial'
else
  default['kubernetes']['distribution'] = "kubernetes-#{node['lsb']['codename']}"
end
