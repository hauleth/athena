node default {
  User {
    shell      => '/bin/bash',
    managehome => true,
  }
  Package {
    ensure => latest,
  }

  include cron-puppet

  user {
    'hauleth':
      ensure     => present,
      groups     => ['sudo'];
    'pyskata':
      ensure => present,
  }

  ssh_authorized_keys {
    'hauleth@athena':
      ensure => present,
      user   => 'hauleth',
      type   => 'ssh-rsa',
      key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDJvEGHPG3UUkTNszvyciolaCTJYrvFYNMlrJuyGw8V6c7gtKBSUj3tZwV52ykxAGwZlecACs8CgttUT/ERL2BiOMtNRDje8t3Y2h7OBLYIxKP3LI43n4luidS7Fr05cyvIp5/fF2HwSet4/nF6qWL5ij+fvE+9l3XBjhvYl3nJjdYRXkJUsIo5T4j5Gu5ssdjzliWbs7cK8odl2wCncsI5SNaD7G9BGpRnGrg/ZeQ/1ZZD65M/aniz2oHbHA0Cm573hGkPcidkMNfSQRKvpyvwj8lxFRB4kgHL8WEKxKqmqi7Su5WRrMCKbnccB7r4C3obqO1OaCfiuevDrc3etWBl';
  }

  class { 'nginx':
    manage_repo => true,
  }

  class { 'letsencrypt':
    email =>  'lukasz@niemier.pl',
  }

  nginx::resource::vhost {
    'matuszewska.photo':
      ensure           => present,
      www_root         => '/home/pyskata/www',
      ssl              => true,
      ssl_cert         => '/etc/letsencrypt/live/matuszewska.photo/fullchain.pem',
      ssl_key          => '/etc/letsencrypt/live/matuszewska.photo/privkey.pem',
      rewrite_to_https => true,
      require          => User['pyskata'],
  }

  letsencrypt::certonly {
    'matuszewska.photo':
      plugin        => 'webroot',
      webroot_paths => ['/home/pyskata/www'],
      manage_cron   => true,
      require       => Nginx::Resource::Vhost['matuszewska.photo']
  }
}
