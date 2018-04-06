class httpd::start (
  $service_name = $::httpd::service_name,
) {
  service { 'httpd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
