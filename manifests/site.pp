include cron-puppet

user { 'hauleth':
  ensure     => present,
  groups     => ['sudo'],
  managehome => true,
  shell      => '/bin/bash',
}

user { 'pyskata':
  ensure     => present,
  managehome => true,
  shell      => '/bin/bash',
}

class { 'nginx':
  manage_repo => true,
}

nginx::resource::vhost { 'matuszewska.photo':
  ensure   => present,
  www_root => '/home/pyskata/www',
  require  => User['pyskata'],
}
