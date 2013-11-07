# ensure can be running or stopped
define daemontools::setup(
  $run,
  $logrun,
  $user,
  $loguser = $user,
  $group = 'daemon',
  $basedir = "/etc"
){

  Exec {
    path => ["/bin", "/usr/bin", "/usr/local/bin"],
  }

  if (!defined(File["${basedir}/${name}"])){  ## Often, the base ${basedir}/whatever is already defined.  No need to be bossy about it.
    file {
    "${basedir}/${name}":
      ensure  => directory,
      owner   => $user,
      group   => $group;
    }
  }

  if (!defined(Exec["restart ${name}"])){  ## This may already be defined via daemontools::service, but if that wasn't used to construct the service dir, do it here.
    exec {
      "restart ${name}":
        command     => "svc -t ${basedir}/${name}",
        refreshonly => true,
        require => Class['daemontools::install'];
    }
  }

  if (!defined(Exec["restart ${name} log"])){  ## This may already be defined via daemontools::service, but if that wasn't used to construct the service dir, do it here.
    exec {
      "restart ${name} log":
        command     => "svc -t ${basedir}/${name}/log",
        refreshonly => true;
    }
  }

  file {
    [
    "${basedir}/${name}/env",
    "${basedir}/${name}/supervise",
    ]:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => 2755;

    "${basedir}/${name}/run":
      content => $run,
      owner   => $user,
      group   => $group,
      mode    => 0755,
      notify  => Exec["restart ${name}"];

    "${basedir}/${name}/log":
      ensure  => directory,
      owner   => $loguser,
      group   => $group,
      mode    => 2755,
      notify  => Exec["restart ${name} log"];
    
    "${basedir}/${name}/log/run":
      content => $logrun,
      owner   => $loguser,
      group   => $group,
      mode    => 0755,
      notify  => Exec["restart ${name} log"];

  }
}
