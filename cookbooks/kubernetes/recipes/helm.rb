#
# Cookbook Name:: kubernetes
# Recipe:: helm
#

execute 'snap install helm --classic' do
  creates '/snap/bin/helm'
end

# NOTE: will we need tiller?
files = %w(helm)

# NOTE: /usr/local/bin is always in PATH, /snap/bin may not
files.each do |file|
  link "/usr/local/bin/#{file}" do
    to "/snap/bin/#{file}"
  end
end
