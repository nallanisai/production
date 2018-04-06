class netbrains::java_config {
  archive { 'jdk-8u121-linux-x64.tar.gz':
    path          => "/tmp/jdk-8u121-linux-x64.tar.gz",
    ensure        => present,
    extract       => true,
    extract_path  => '/usr/local',
    extract_flags => '-xzof',
    source        => 'puppet:///modules/netbrains/jdk-8u121-linux-x64.tar.gz',
    creates       => "/usr/bin/java",
    cleanup       => true,
    user          => 'root',
    group         => 'root'
  }
  file { '/etc/profile.d/jdk_home.sh':
    source => 'puppet:///modules/netbrains/jdk_home.sh',
    owner  => 'root',
    group  => 'root',
    mode   => '655',
  }
  exec { 'create-java-alternatives':
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    command => "alternatives --install /usr/bin/java java /usr/local/jdk1.8.0_121/bin/java 1",
    unless  => "alternatives --display java | grep -q /usr/local/jdk1.8.0_121/bin/java",
  }
  exec { 'create-javac-alternatives':
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    command => "alternatives --install /usr/bin/javac javac /usr/local/jdk1.8.0_121/bin/javac 1",
    unless  => "alternatives --display javac | grep -q /usr/local/jdk1.8.0_121/bin/javac",
  }
  exec { 'create-jar-alternatives':
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    command => "alternatives --install /usr/bin/jar jar /usr/local/jdk1.8.0_121/bin/jar 1",
    unless  => "alternatives --display jar | grep -q /usr/local/jdk1.8.0_121/bin/jar",
  }

}
