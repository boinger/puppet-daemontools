# ensure can be running or stopped
define daemontools::setup(
  $run,
  $logrun,
  $user,
  $loguser = $user,
  $group = 'daemon',
  $ensure = 'running',
){

  $content = $ensure ? {  ## For the 'run' script
    'running' => $run,
    'stopped' => 'absent',
     default  => fail("ensure => 'running' or 'stopped' only"),
  }

  $log_content = $ensure ? {  ## For the 'run' script
    'running' => $logrun,
    'stopped' => 'absent',
     default  => fail("ensure => 'running' or 'stopped' only"),
  }

  $dir = $ensure ? { ## For the dir tree
    'running' => 'directory',
    'stopped' => 'absent',
  }

  Exec {
    path => ["/bin", "/usr/bin", "/usr/local/bin"],
  }

  if (!defined(File["/etc/${name}"])){  ## Often, the base /etc/whatever is already defined.  No need to be bossy about it.
    file {
    "/etc/${name}":
      ensure  => $dir,
      owner   => $user;
    }
  }

  if (!defined(Exec["restart ${name}"])){  ## This may already be defined via daemontools::service, but if that wasn't used to construct the service dir, do it here.
    exec {
      "restart ${name}":
        command     => "svc -t /etc/${name}",
        refreshonly => true;
    }
  }

  if (!defined(Exec["restart ${name} log"])){  ## This may already be defined via daemontools::service, but if that wasn't used to construct the service dir, do it here.
    exec {
      "restart ${name} log":
        command     => "svc -t /etc/${name}/log",
        refreshonly => true;
    }
  }

  file {
    [
    "/etc/${name}/log",
    "/etc/${name}/env",
    "/etc/${name}/supervise",
    ]:
      ensure  => $dir,
      owner   => $user,
      mode    => 2755;

    "/etc/${name}/run":
      content => $content,
      owner   => $user,
      mode    => 0755,
      notify  => Exec["restart ${name}"];

    "/etc/${name}/log/run":
      content => $log_content,
      owner   => $user,
      mode    => 0755,
      notify  => Exec["restart ${name} log"];

  }
}
