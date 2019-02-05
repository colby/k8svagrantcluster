#
# Cookbook Name:: kubernetes
# Recipe:: default
#

include_recipe 'kubernetes::install'
include_recipe 'kubernetes::configure'
include_recipe 'kubernetes::docker'
include_recipe 'kubernetes::helm'
