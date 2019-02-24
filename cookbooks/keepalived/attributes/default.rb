default['keepalived']['packages'] = %w(keepalived)
default['keepalived']['instance_name'] = 'kubernetes'
default['keepalived']['interface'] = 'enp0s8'
default['keepalived']['virtual_router_id'] = 1
default['keepalived']['priority'] = 100
# NOTE: password will be auto truncated to 8 characters by keepalived
default['keepalived']['authentication_password'] = 'uM99KRn4NTmBzQ=='
default['keepalived']['virtual_ipaddress'] = '10.10.3.5'
