# Sensu-RSpec Integration

This is an example of how to integrate RSpec tests with Sensu.

It uses the `check-rspec` Sensu check that I contributed to [Sensu Community Plugins](https://github.com/sensu/sensu-community-plugins/blob/master/plugins/rspec/check-rspec.rb).

The Sensu version here is currently pinned to `0.11.0-1` which was before the built-in dashboard was deprecated.

If you require a Sensu sandbox VM, check out my [vagrant-sensu](https://github.com/bsnape/vagrant-sensu) repository.

## Installation

Install Ruby, Vagrant and VirtualBox.

Install the gem dependencies:

```bash
$ bundle install
```

Install the Puppet modules:

```
$ librarian-puppet install
```

Bring up the VMs (will take a while):

```bash
$ vagrant up
```

## Usage

Once the 2 VMs are up and running, navigate to the (deprecated) [Sensu dashboard](http://33.33.33.90:8080/).

Here you can see the two separate warning alerts for failed tests and an overall critical alert
displaying the summary of how many tests have failed.

![Sensu Dashboard](sensu_dashboard.png)
