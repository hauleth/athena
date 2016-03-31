class cron-puppet ($minute = '*/5') {
  ensure_packages(['git'])

  file { 'post-hook':
    ensure => file,
    path   => '/etc/puppet/.git/hooks/post-merge',
    source => 'puppet:///modules/cron-puppet/post-merge',
    mode   => 0755,
    owner  => root,
    group  => root,
  }

  cron { 'puppet-apply':
    ensure  => present,
    command => '/usr/bin/git --git-dir=/etc/puppet/.git --work-tree=/etc/puppet pull',
    user    => root,
    minute  => $minute,
    require => File['post-hook']
  }
}
