# Install systemd service files to start Oracle listener and database
# server. 
# This class defaults to **not** enabling systemd managment of oracle
# services. So you can `include oradb_ext::systemd` and nothing will
# change. To enable, also set in hiera:
#   oradb_ext::systemd::enable: true
# This helps prevent accidental setup on production systems.
#
# The `oralsnr` service is a dependency of the `oradb` service
# so it is sufficient to manage `oradb`.
#   systemctl start|stop|status oradb
#
# Understand that `oradb` only starts databases marked to be autostarted
# in `/etc/oratab`. This class does not manage the oratab file.
#
class oradb_ext::systemd (
  $oracle_home  = lookup('oracle_home'),
  $user         = 'oracle',
  $enable       = false,
) {

  if $enable == true {
    $ensure_file = 'file'
    $ensure_service = 'running'
    $enable_service = true
    File['oradb.service'] -> File['oralsnr.service'] ->
    Exec['oradb_ext_systemctl_reload'] -> Service['oradb']
  } else {
    $ensure_file = absent
    $ensure_service = false
    $enable_service = false
    Service['oradb'] -> File['oradb.service'] ->
    File['oralsnr.service'] -> Exec['oradb_ext_systemctl_reload']
  }

  file { 'oradb.service':
    ensure  => $ensure_file,
    path    => '/usr/lib/systemd/system/oradb.service',
    content => template('oradb_ext/oradb.service.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { 'oralsnr.service':
    ensure  => $ensure_file,
    path    => '/usr/lib/systemd/system/oralsnr.service',
    content => template('oradb_ext/oralsnr.service.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  service { 'oradb':
    ensure => $ensure_service,
    enable => $enable_service,
  }

  exec { 'oradb_ext_systemctl_reload':
    path        => ['/usr/bin'],
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }
}