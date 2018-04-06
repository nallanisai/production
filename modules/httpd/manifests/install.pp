class httpd::install (
  $package_name = $::httpd::package_name,
) inherits httpd::params {
  package { 'http_install':
    name   => $package_name,
    ensure => present,
  }
}

