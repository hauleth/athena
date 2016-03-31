class magda {
  user { 'pyskata':
    ensure     => present,
    managehome => true,
    shell      => '/bin/bash',
  }

  nginx::resource::vhost { 'matuszewska.photo':
    ensure           => present,
    www_root         => '/home/pyskata/www',
    ssl              => true,
    ssl_cert         => '/etc/letsencrypt/live/matuszewska.photo/fullchain.pem',
    ssl_key          => '/etc/letsencrypt/live/matuszewska.photo/privkey.pem',
    rewrite_to_https => true,
    require          => User['pyskata'],
  }

  letsencrypt::certonly { 'matuszewska.photo':
    plugin        => 'webroot',
    webroot_paths => ['/home/pyskata/www'],
    manage_cron   => true,
    require       => Nginx::Resource::Vhost['matuszewska.photo']
  }
}
