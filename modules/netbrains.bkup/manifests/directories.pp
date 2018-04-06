# @api private
# Please consult NetBrain install manual before changing anything

class netbrains::directories {
  file { '/etc/netbrain' :
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
 
  file { [ '/opt/elasticsearch',
           '/opt/elasticsearch/logs' ]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  file { ['/elasticsearch',
          '/elasticsearch/index',
          '/elasticsearch/index/data' ]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
}
