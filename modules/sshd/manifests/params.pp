class sshd::params {
  case $::osfamily {
    'RedHat': {
      $package_name = 'sshpass'
    }
    'CentOS': {
      $package_name = 'sshpass'
    }
    default: {
      fail("${::operatingsystem} is not supported!")
    }
  }
}
