# @api private
# Please consult Netbrains install manual before changing anything

class netbrains::files {

# This copies the Java jdk and untars it.
  file { '/etc/netbrain/jdk-8u121-linux-x64.tar.gz':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
    source => "puppet:///modules/netbrains/jdk-8u121-linux-x64.tar.gz",
    notify => Exec["unpack jdk"]
  }
  
  exec {"unpack jdk":
    path    => '/usr/local/bin:/usr/bin:/bin',
    cwd     => '/etc/netbrain',
    command => 'tar -xvzf /etc/netbrain/jdk-8u121-linux-x64.tar.gz -C /usr/local/',
  }
# This copies netbrain_license and untars it.
  file { '/etc/netbrain/NetBrain_License.tar' :
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
    source => "puppet:///modules/netbrains/NetBrain_License.tar",
    notify => Exec["unpack NetBrain"]
  }
  
  exec {"unpack NetBrain":
    path    => '/usr/local/bin:/usr/bin:/bin',
    cwd     => '/etc/netbrain',
    command => 'tar -xvf /etc/netbrain/NetBrain_License.tar',
  }

}


