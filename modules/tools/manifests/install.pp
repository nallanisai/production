class tools::install (
  $package_name=$tools::params::package_name
) {
  package { 'monitoring_linux':
    name   => $package_name,
    ensure => present,
  }
}
