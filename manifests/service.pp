# ensure can be running or stopped
define daemontools::service(
  $source = null,
  $ensure = 'running',
){
  
  $my_ensure = $ensure ? {
    'running' => $source,
    'stopped' => 'absent',
     default  => fail("ensure => 'running' or 'stopped' only"),
  }

  Exec {
    path => ["/bin", "/usr/bin", "/usr/local/bin"],
  }

  if $my_ensure == absent {
    exec {
      "disable ${name}":
        command => "bash -c 'cd /service/${name} || true ; rm -f /service/${name} && svc -dx . ./log || true'";
    }
  } else {
    file {"/service/${name}":
      ensure  => $my_ensure,
      require => [File['/service'], Exec['install daemontools']],
    }
  }

  if (!defined(Exec["restart ${name}"])){  ## This may already be defined via daemontools::setup, but if that wasn't used to construct the service dir, do it here.
    exec {
      "restart ${name}":
        command     => "svc -t /etc/${name}",
        refreshonly => true;
    }
  }

  if (!defined(Exec["restart ${name} log"])){  ## This may already be defined via daemontools::setup, but if that wasn't used to construct the service dir, do it here.
    exec {
      "restart ${name} log":
        command     => "svc -t /etc/${name}/log",
        refreshonly => true;
    }
  }
}
