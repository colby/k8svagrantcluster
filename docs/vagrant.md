## Vagrant

### Boot and Provision

Note, booting and provisioning all four nodes will take around 4ish minutes. 

```
$ vagrant up --provision
Bringing machine 'm1' up with 'virtualbox' provider...
Bringing machine 'm2' up with 'virtualbox' provider...
Bringing machine 's1' up with 'virtualbox' provider...
Bringing machine 's2' up with 'virtualbox' provider...
...
==> m1: Chef Client finished, 34/48 resources updated in 01 minutes 04 seconds
==> m2: Chef Client finished, 34/48 resources updated in 01 minutes 03 seconds
==> s1: Chef Client finished, 30/43 resources updated in 57 seconds
==> s2: Chef Client finished, 30/43 resources updated in 56 seconds
```
