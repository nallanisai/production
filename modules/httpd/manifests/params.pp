class httpd::params {
  case $::operatingsystem {
    'RedHat': {
      $service_name = 'httpd'
      $package_name = 'httpd'
    }
    'CentOS': {
      $service_name = 'httpd'
      $package_name = 'httpd'
    }
    default: {
      fail("${::operatingsystem} is not supported!")
    }
  }
}

