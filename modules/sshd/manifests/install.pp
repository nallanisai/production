class sshd::install (
  $package_name = $sshd::params::package_name
) {
  package {'ssh_package':
    name   => $package_name,
    ensure => 'present',
  }
}
