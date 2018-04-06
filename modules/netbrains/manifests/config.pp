# @api private
# Please consult netbrains install manual before changing anything
# Some files and directories are here because they need to be handled after install

class netbrains::config {
  file { '/etc/netbrain/install_elasticsearch.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '755',
    content => epp('netbrains/install.conf.epp'),
  }
}
