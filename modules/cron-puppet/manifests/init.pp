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
    ensure      => present,
    environment => ['GIT_WORK_TREE=/etc/puppet', 'GIT_DIR=/etc/puppet/.git'],
    command     => '/usr/bin/git pull > /dev/null',
    user        => root,
    minute      => $minute,
    require     => File['post-hook']
  }
}
