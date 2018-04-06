class lvm {
  lvm::volume { 'mylv':
    ensure => present,
    vg     => 'vg02',
    pv     => '/dev/sdb',
    fstype => 'ext4',
    size   => '100M'
  }
}
