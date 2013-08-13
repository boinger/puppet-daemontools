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

  if $my_ensure == absent {
    exec {
      "disable ${name}":
        path    => ["/bin", "/usr/bin", "/usr/local/bin"],
        command => "bash -c 'cd /service/${name} || true ; rm -f /service/${name} && svc -dx . ./log || true'";
    }
  } else {
    file {"/service/${name}":
      ensure  => $my_ensure,
      require => [File['/service'], Exec['install daemontools']],
    }
  }

  exec {
    "restart ${name}":
      refreshonly => true,
      command     => "/usr/local/bin/svc -t /service/${name}";
  }
}
