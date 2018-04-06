# @api private
# Please consult NetBrain  install manual before changing anything

class netbrains::install {
  exec { 'install license agent':
    path    => '/usr/local/bin:/usr/bin:/bin',
    cwd     => '/etc/netbrain/NetBrain_License',
    command => 'sudo /bin/bash -c /etc/netbrain/NetBrain_License/install_license.sh',
  }
}
    
