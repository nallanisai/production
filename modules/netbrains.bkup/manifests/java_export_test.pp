class netbrains::test_java_export {
  file { '/tmp/java_test' :
    ensure => present,
    line   => "JAVA_HOME=/usr/local/jdk1.8.0_121;CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar;PATH=$PATH:$JAVA_HOME/bin;export PATH USER LOGNAME MAIL HOSTN    AME HISTSIZE HISTCONTROL;",
    match  => 'JAVA_HOME=',
  }
}
