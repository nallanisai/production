class ssh::install  (
  $package_name=$ssh::params::package_name,
  $service_name=$ssh::params::service_name,
) {
  package { 'sshpackage':
    name   => $package_name,
    ensure => running,
  }
  service { 'sshservice':
    name   => $service_name,
    ensure => running,
  }
}
