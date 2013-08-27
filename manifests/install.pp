class daemontools::install (
    $pkg_url = 'http://cr.yp.to/daemontools/daemontools-0.76.tar.gz'
  ){

  if $pkg_url =~ /^.*\/([^\/]*)$/ { $pkg_tarball_name = $1 }
  if $pkg_tarball_name =~ /^(.*)\.tar\.gz$/ { $pkg_name = $1 }

  ## Sure, we'd like an rpm.  But there isn't one in the main distro's repo.
  ## If you have an rpm (or deb, I guess) of daemontools, just uncomment this
  ## and comment out the manual installation below.

  ## Simple package installation:
  #  package{'daemontools':
  #    ensure => installed,
  #  }

  ## Manual installation of daemontools

  File {
      owner  => root,
      group  => root,
      mode   => 1755,
    }

  file {
    '/package':
      ensure => directory;

    '/service':
      ensure => directory;

    "daemontools conf-cc":
      mode    => 644,
      path    => "/package/admin/$pkg_name/src/conf-cc",
      source  => "puppet:///modules/daemontools/conf-cc",
      require => Exec['get daemontools'];

    "/usr/bin/svc":
      ensure => link,
      target => "/usr/local/bin/svc",
      require => Exec['get daemontools'];

    "/usr/bin/svstat":
      ensure => link,
      target => "/usr/local/bin/svstat",
      require => Exec['get daemontools'];
  }

  exec {
    'get daemontools':
      cwd     => '/package',
      command => "/usr/bin/wget -q ${pkg_url} && tar xpfz ${pkg_tarball_name} && rm /package/${pkg_tarball_name}",
      creates => "/package/admin/${pkg_name}",
      require => File['/package'];

    'install daemontools':
      cwd     => "/package/admin/${pkg_name}",
      command => "/package/admin/${pkg_name}/package/compile && /package/admin/${pkg_name}/package/upgrade",
      creates => '/command/supervise',
      require => [
          File['daemontools conf-cc'],
          Exec['get daemontools'],
          ];

    'setup inittab':
      cwd     => "/package/admin/${pkg_name}",
      command => "/command/setlock /etc/inittab package/run.inittab",
      unless  => 'grep svscanboot /etc/inittab',
      require => [
          Exec['install daemontools'],
          File['/service'],
          ];
  }

  ## End manual installation

  exec{'/usr/local/bin/svscanboot &':
    unless  => 'pgrep svscan',
    require => Exec['install daemontools'],
  }
}
