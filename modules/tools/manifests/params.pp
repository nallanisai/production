class tools::params {
  case $::operatingsystem {
    'RedHat': {
      $package_name='htop'
    }
    'CentOS': {
      $package_name='tree'
    }
    default: {
      fail("${::operatingsystem} is not supported")
    }
  }
}
