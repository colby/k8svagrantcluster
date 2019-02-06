#
# Cookbook Name:: kubernetes
# Recipe:: helm
#

execute 'snap install helm --classic' do
  creates '/snap/bin/helm'
end

# NOTE: /usr/local/bin is always in PATH, /snap/bin may not
link '/usr/local/bin/helm' do
  to '/snap/bin/helm'
end
