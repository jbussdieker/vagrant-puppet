# Class puppet
class puppet(
  $version = '3.7.3-1puppetlabs1',
  $agent   = true,
  $master  = false,

  #[main]
  $logdir     = '/var/log/puppet',
  $vardir     = '/var/lib/puppet',
  $ssldir     = '/var/lib/puppet/ssl',
  $rundir     = '/var/run/puppet',
  $factpath   = '$vardir/lib/facter',
  $templatedir= '$confdir/templates',

  $environmentpath  = '$confdir/environments',
  $default_manifest = '$confdir/manifests',
  $basemodulepath   = '$confdir/modules:/opt/puppet/share/puppet/modules',

  #[master]
  # These are needed when the puppetmaster is run by passenger
  # and can safely be removed if webrick is used.
  $ssl_client_header        = 'SSL_CLIENT_S_DN',
  $ssl_client_verify_header = 'SSL_CLIENT_VERIFY',
) {

  include apt

  apt::source { 'puppetlabs':
    release     => 'stable',
    repos       => 'main',
    location    => 'http://apt.puppetlabs.com',
    key         => '1054B7A24BD6EC30',
    key_source  => 'https://apt.puppetlabs.com/pubkey.gpg',
    include_src => false,
  }

  package { 'puppet-common':
    ensure  => $version,
    require => Apt::Source['puppetlabs'],
  }

  if $agent {
    package { 'puppet':
      ensure  => $version,
      require => Package['puppet-common'],
    }
  }

  if $master {
    package { 'puppetmaster':
      ensure  => $version,
      require => Package['puppet-common'],
    }
  }

  file { '/etc/puppet/puppet.conf':
    content => template('puppet/puppet.conf.erb'),
  }

}
