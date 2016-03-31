node default {
  include cron-puppet

  user { 'hauleth':
    ensure     => present,
    groups     => ['sudo'],
    managehome => true,
    shell      => '/bin/bash',
  }

  class { 'nginx':
    manage_repo => true,
  }

  class { 'letsencrypt':
    email =>  'lukasz@niemier.pl',
  }

  file { '/var/www':
    ensure => directory,
  }

  nginx::resource::vhost { 'athena.niemier.pl':
    ensure   => present,
    www_root => '/var/www',
    require  => File['/var/www'],
  }

  include magda
}
