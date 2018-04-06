## Please consult netbrain documentation before doing any changes.
class netbrains::mongodb {
  file { '/etc/netbrain' :
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }
  file { '/etc/netbrain/install_mongodb.conf' :
    ensure  => present,
    content => epp('netbrains/install_mongodb.conf.epp'),
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  }
  file { '/etc/netbrain/mongodbconfig.sh' :
    ensure => present,
    source => "puppet:///modules/netbrains/mongodbconfig.sh",
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
  package { [
    'libcgroup',
    'libcgroup-tools',
    'lsof',
    'numactl',
    'mongodbconfig',
  ]:
    ensure => installed,
  }

  exec { 'configure mongodb':
    path        => '/usr/local/bin:/usr/bin:/bin',
    cwd         => '/etc',
    command     => '/bin/bash -c /etc/mongodbconfig.sh',
    refreshonly => 'true',
  }
  service { 'mongodnetbrain':
    ensure     => 'running',
    name       => 'mongodnetbrain',
    enable     => 'true',
    hasstatus  => 'true',
    hasrestart => 'true',
    require    => Package['mongodbconfig'],
  }
}


