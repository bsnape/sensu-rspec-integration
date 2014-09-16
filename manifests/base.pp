node 'sensu-server' {

  class { '::erlang':
    epel_enable => true
  }

  class { '::redis':
    version => '2.8.13',
  }

  class { '::rabbitmq':
    require               => Class['::erlang'],
    environment_variables => {
    'RABBITMQ_NODENAME' => 'rabbit',
    'HOME'              => '/var/lib/rabbitmq',
    }
  }

  rabbitmq_vhost { '/sensu':
    ensure  => present,
    require => Class['::rabbitmq']
  }

  rabbitmq_user { 'sensu':
    password => 'password',
    admin    => true,
    require  => Class['::rabbitmq']
  }

  rabbitmq_user_permissions { 'sensu@/sensu':
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
    require              => Class['::rabbitmq']
  }

  class { 'sensu':
    version            => '0.11.0-1',
    rabbitmq_password  => 'password',
    rabbitmq_host      => 'sensu-server',
    rabbitmq_port      => '5672',
    client             => false,
    server             => true,
    dashboard          => true,
    api                => true,
    dashboard_user     => '',
    dashboard_password => '',
    require            => [Class['::rabbitmq'], Class['::redis'], Package['sensu-plugin']],
  }

  sensu::check { 'rspec_tests':
    command     => '/etc/sensu/plugins/check-rspec.rb -b ruby -i rspec -d /tmp/example-sensu-rspec-tests -s spec',
    handlers    => 'default',
    subscribers => 'sensu-test',
    interval    => 5,
    standalone  => false,
  }

  sensu::handler { 'default':
    type     => 'set',
    command  => 'true',
    handlers => 'log_event',
  }

  sensu::handler { 'log_event':
    type   => 'pipe',
    source => 'puppet:///modules/data/handlers/logevent.rb',
  }

  package { 'sensu-plugin':
    ensure   => 'installed',
    provider => 'gem',
  }

}


node 'sensu-client' {

  Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin" }

  class { 'sensu':
    rabbitmq_password => 'password',
    rabbitmq_host     => '33.33.33.90',
    rabbitmq_port     => '5672',
    subscriptions     => 'sensu-test',
    plugins           => ['puppet:///modules/data/plugins/check-rspec.rb'],
    require           => Package['sensu-plugin'],
  }

  package { 'ruby-devel':
    ensure   => 'installed',
    provider => 'yum',
  }

  package { 'sensu-plugin':
    ensure   => 'installed',
    provider => 'gem',
  }

  package { 'bundler':
    ensure   => 'installed',
    provider => 'gem',
  }

  vcsrepo { "/tmp/example-sensu-rspec-tests":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/bsnape/example-sensu-rspec-tests.git',
    revision => 'master',
  }

  exec { 'bundle install':
    command => 'bundle install',
    cwd     => '/tmp/example-sensu-rspec-tests',
    returns => 0,
    require => [Vcsrepo['/tmp/example-sensu-rspec-tests'], package['ruby-devel']]
  }

}
