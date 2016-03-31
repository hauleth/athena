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

  user { 'pyskata':
    ensure     => present,
    managehome => true,
    shell      => '/bin/bash',
  }

  nginx::resource::vhost { 'matuszewska.photo':
    ensure   => present,
    www_root => '/home/pyskata/www',
    require  => User['pyskata'],
  }

  letsencrypt::certonly { 'matuszewska.photo':
    plugin        => 'webroot',
    webroot_paths => ['/home/pyskata/www'],
    manage_cron   => true,
    require       => Nginx::Resource::Vhost['matuszewska.photo']
  }
}
