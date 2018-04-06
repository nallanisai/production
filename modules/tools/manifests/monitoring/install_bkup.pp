class tools::install (
  $package_name=$tools::params::package_name
) {
  package { 'linux_packages':
    name   => $package_name,
    ensure => present,
  }
}

