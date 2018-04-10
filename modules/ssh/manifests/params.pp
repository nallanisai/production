class ssh::params {
  case $::operatingsystem {
    'RedHat': {
      $package_name='openssh'
      $service_name='sshd'
    }
    'CentOS': {
      $package_name='openssh'
      $service_name='sshd'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
