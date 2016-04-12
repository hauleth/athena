node default {
  User {
    shell      => '/bin/bash',
    managehome => true,
  }
  Package {
    ensure => latest,
  }
  File {
    mode  => 0644,
    owner => root,
    group => root,
  }

  class { 'cron-puppet': minute  => '*/10' }
  class { 'docker': docker_users => ['hauleth'] }
  class { 'nginx': manage_repo   => true, }
  class { 'letsencrypt': email   => 'lukasz@niemier.pl', }

  user {
    'hauleth':
      ensure     => present,
      groups     => ['sudo'];
    'pyskata':
      ensure => present,
  }

  ssh_authorized_key {
    'hauleth@athena':
      ensure => present,
      user   => 'hauleth',
      type   => 'ssh-rsa',
      key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDJvEGHPG3UUkTNszvyciolaCTJYrvFYNMlrJuyGw8V6c7gtKBSUj3tZwV52ykxAGwZlecACs8CgttUT/ERL2BiOMtNRDje8t3Y2h7OBLYIxKP3LI43n4luidS7Fr05cyvIp5/fF2HwSet4/nF6qWL5ij+fvE+9l3XBjhvYl3nJjdYRXkJUsIo5T4j5Gu5ssdjzliWbs7cK8odl2wCncsI5SNaD7G9BGpRnGrg/ZeQ/1ZZD65M/aniz2oHbHA0Cm573hGkPcidkMNfSQRKvpyvwj8lxFRB4kgHL8WEKxKqmqi7Su5WRrMCKbnccB7r4C3obqO1OaCfiuevDrc3etWBl';
    'pyskata@athena':
      ensure => present,
      user   => 'pyskata',
      type   => 'ssh-rsa',
      key    => 'AAAAB3NzaC1yc2EAAAABJQAAAQEAj6JrQl3iFAMvOSsAOu9ExzeUaR11QQ7T0oWiNMbCzCJGUzectS+H/hwk/z9dEscahVnJocfMZLOGKax9+nZPp8nvs/vcfMbTFj5deU3BETVqmA6gJ3OWEWZz1TJ2p6qbkhS9s8lOIOGdQc5Qaa5/jK/lVUgBi1bbbae4Lmddjb4J+X0uTarDTHRGCAFFKmXmJPWkgwLoqXVnMPLdO6wnTmN+PBh+lhX2p5qnnWkqkKQZ/STxDXFk0ZEqyUif2YkeC36Q8Mp2ta7nLAGCMjDT8V/APf42hHbBGe9WPoLD2Ej6iBzb5z9UTvMr+v/mDx2dY/Tqq1w2EXwpxSq/3XvMxw==';
  }

  package {
    ['tmux', 'iptables', 'mosh', 'postfix', 'lnav', 'mailutils']:
  }

  file {
    '/etc/aliases':
      ensure => file,
      source => 'puppet:///files/postfix/aliases',
      notify =>  Exec['postfix_aliases'];
    '/etc/postfix/main.cf':
      ensure => file,
      source => 'puppet:///files/postfix/main.cf',
      notify => Service['postfix'];
    '/etc/ssh/sshd_config':
      ensure => file,
      source => 'puppet:///files/ssh/sshd.config',
      notify => Service['ssh'];
    '/sbin/iptables-rules':
      ensure => file,
      source => 'puppet:///files/iptables/rules',
      notify => Exec['update iptables'];
  }

  exec {
    'postfix_aliases':
      command     => '/usr/bin/newaliases',
      notify      => Service['postfix'],
      refreshonly => true;
    'securing_file_ownership':
      command => '/bin/chown -R root: /etc/puppet',
      before  => Exec['securing_file_permissions'];
    'securing_file_permissions':
      command => '/usr/bin/find /etc/puppet -type f -exec chmod 600 {} \;';
    'update iptables':
      command => '/bin/sh /sbin/iptables-rules',
      require => File['/sbin/iptables-rules'];
  }

  service {
    ['ssh', 'postfix']:
      ensure => running,
      enable => true;
  }

  nginx::resource::vhost {
    'matuszewska.photo':
      ensure           => present,
      www_root         => '/home/pyskata/www',
      ssl              => true,
      ssl_cert         => '/etc/letsencrypt/live/matuszewska.photo/fullchain.pem',
      ssl_key          => '/etc/letsencrypt/live/matuszewska.photo/privkey.pem',
      rewrite_to_https => true,
      require          => User['pyskata'];
    'athena.niemier.pl':
      ensure => present,
      proxy  => 'http://localhost:61208';
  }

  letsencrypt::certonly {
    'matuszewska.photo':
      plugin        => 'webroot',
      webroot_paths => ['/home/pyskata/www'],
      manage_cron   => true,
      require       => Nginx::Resource::Vhost['matuszewska.photo']
  }

  docker::image {
    'nicolargo/glances':
      ensure    => present,
      image_tag => latest;
  }

  docker::run {
    'glances':
      image            => 'nicolargo/glances',
      command          => 'python -m glances -w',
      ports            => ['61208:61208'],
      volumes          => ['/var/run/docker.sock:/var/run/docker.sock:ro'],
      extra_parameters => '--pid=host';
  }
}
