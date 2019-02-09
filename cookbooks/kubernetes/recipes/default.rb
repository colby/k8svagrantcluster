#
# Cookbook Name:: kubernetes
# Recipe:: default
#

include_recipe 'kubernetes::install'
include_recipe 'kubernetes::configure'

if node['kubernetes']['helm']
  include_recipe 'kubernetes::helm'
end
