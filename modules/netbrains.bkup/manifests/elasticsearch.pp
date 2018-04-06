class netbrains::elasticsearch {

  file { '/etc/install_elasticsearch.conf.epp':
    ensure  => 'present',
    content => epp('netbrains/install_mongodb.conf.epp'),
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  }
  group { 'elasticsearch':
    system => 'true',
  }
  user { 'elasticsearch':
    ensure     => 'present',
    home       => '/cust/home',
    groups     => 'elasticsearch',
    managehome => 'true',
  }
  file { [ '/opt/elasticsearch/logs',
           '/netbrains/elasticsearch/data',
           '/netbrains/elasticsearch',
    ensure => 'directory',
    owner  => 'elasticsearch',
    group  => 'elasticsearch',
    mode   => '0755',
  }
  file { '/netbrain/elasticsearch/els.sh':
    source => 'puppet:///modules/netbrains/els.sh',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
}


