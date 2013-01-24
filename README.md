#puppet-daemontools#

* Install & manage daemontools
* Add or remove daemons from the service directory

* Note:
* Defaults to pulling a specific version directly from http://cr.yp.to/daemontools/.
This isn't particularly ideal/best practice.
You should fork this project and make it install a package from your locally hosted binary repo.

##Requirements##

* wget
* A daemontools-compliant daemon (not technically a *requirement*, but why would you pull this project otherwise?)

##Usage##

###Basic (defaults to ensure => running):
```puppet
class { 'daemontools': }
daemontools::service{ "tinydns":
  source => ''
}
```

###Stop a service:
```puppet
class { 'daemontools': }
daemontools::service{ "tinydns":
  ensure => 'stopped'
}
```
##License##

 Copyright (C) 2013 Jeff Vier <jeff@jeffvier.com> (Author)<br />
 License: Apache 2.0