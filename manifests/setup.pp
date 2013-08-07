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

  if (!defined(File["/etc/${name}"])){  ## Often, the base /etc/whatever is already defined.  No need to be bossy about it.
    file {
    "/etc/${name}":
      ensure  => $dir,
      owner   => $user;
    }
  }
      
  file {
    "/etc/${name}/log":
      ensure  => $dir,
      owner   => $user,
      mode    => 2755,
      require => File["/etc/${name}"];
      
    "/etc/${name}/env":
      ensure  => $dir,
      owner   => $user,
      mode    => 2755,
      require => File["/etc/${name}"];
      
    "/etc/${name}/supervise":
      ensure  => $dir,
      owner   => $user,
      mode    => 2755,
      require => File["/etc/${name}"];
      
    "/etc/${name}/run":
      content => $content,
      owner   => $user,
      mode    => 0755,
      require => File["/etc/${name}"];
      
    "/etc/${name}/log/run":
      content => $log_content,
      owner   => $user,
      mode    => 0755,
      require => File["/etc/${name}"];

  }

}
