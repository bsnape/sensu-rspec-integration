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
    version            => 'latest',
    rabbitmq_password  => 'password',
    rabbitmq_host      => 'sensu-server',
    install_repo       => false,
    client             => false,
    server             => true,
    api                => true,
    require            => [Class['::rabbitmq'], Class['::redis']],
  }

  package { 'sensu-plugin':
    ensure   => 'installed',
    provider => 'gem',
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

  $uchiwa_api_config = [{
    host         => '127.0.0.1',
    install_repo => true,
    ssl          => false,
    insecure     => true,
    port         => 4567,
    user         => '',
    pass         => '',
    path         => '',
    timeout      => 5
  }]

  class { 'uchiwa':
    sensu_api_endpoints => $uchiwa_api_config,
  }
}


node 'sensu-client' {

  Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin" }

  class { 'sensu':
    rabbitmq_password => 'password',
    rabbitmq_host     => '33.33.33.90',
    subscriptions     => 'sensu-test',
    plugins           => ['puppet:///modules/data/plugins/check-rspec.rb'],
  }

  package { 'sensu-plugin':
    ensure   => 'installed',
    provider => 'gem',
  }

  package { 'rspec':
    ensure   => 'installed',
    provider => 'gem',
  }

  vcsrepo { "/tmp/example-sensu-rspec-tests":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/bsnape/example-sensu-rspec-tests.git',
    revision => 'master',
  }

}
