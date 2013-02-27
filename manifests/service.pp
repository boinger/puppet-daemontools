# ensure can be running or stopped
define daemontools::service(
  $source,
  $ensure = 'running',
){
  
  $my_ensure = $ensure ? {
    'running' => $source,
    'stopped' => 'absent',
     default  => fail("ensure => 'running' or 'stopped' only"),
  }

  file {"/service/${name}":
    ensure  => $my_ensure,
    require => [File['/service'], Exec['install daemontools']],
  }

  exec {
    "restart ${name}":
    refreshonly => true,
    command     => "/usr/local/bin/svc -t /service/${name}";
  }
}
