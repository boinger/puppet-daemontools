#puppet-daemontools#

* Install & manage daemontools
* Add or remove daemons from the service directory

* Notes:<ul><li>Defaults to pulling a specific version directly from http://cr.yp.to/daemontools/.
This isn't particularly ideal/best practice.
You should fork this project and make it install a package from your locally hosted binary repo.
<li> This module patches conf-cc (as required by Linux' errno.h bug: http://cr.yp.to/docs/unixport.html#errno)
</ul>

##Requirements##

* wget
* A daemontools-compliant daemon (not technically a *requirement*, but why would you pull this project otherwise?)

##Usage##

###Basic (defaults to ensure => running):
```puppet
class { 'daemontools::install': }
daemontools::service{
  "tinydns":
    source => '/etc/tinydns';
}
```

###Stop a service:
```puppet
class { 'daemontools::install': }
daemontools::service{ "tinydns":
  ensure => 'stopped';
}
```
##License##

 Copyright (C) 2013 Jeff Vier <jeff@jeffvier.com> (Author)<br />
 License: Apache 2.0