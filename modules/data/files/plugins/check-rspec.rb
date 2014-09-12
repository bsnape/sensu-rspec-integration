#!/usr/bin/env ruby
#
# Check RSpec tests plugin
# ===
#
# Runs RSpec tests.
# Fails with a critical if tests are failing.
#
# Examples:
#
#   # Run entire suite of tests
#   check-rspec -d /tmp/my_tests/spec
#
#   # Run only one set of tests
#   check-rspec -d /tmp/my_tests/spec/test_one

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'json'
require 'socket'
require 'rspec'
require 'sensu-plugin/check/cli'

class CheckRspec < Sensu::Plugin::Check::CLI

  option :spec_dir,
         :short    => '-d /tmp/my_tests/spec',
         :long     => '--spec-dir /tmp/my_tests/spec',
         :required => true

  option :handler,
         :short   => '-l HANDLER',
         :long    => '--handler HANDLER',
         :default => 'default'

  def sensu_client_socket(msg)
    u = UDPSocket.new
    u.send(msg + "\n", 0, '127.0.0.1', 3030)
  end

  def send_ok(check_name, msg)
    d = { 'name' => check_name, 'status' => 0, 'output' => 'OK: ' + msg, 'handler' => config[:handler] }
    sensu_client_socket d.to_json
  end

  def send_warning(check_name, msg)
    d = { 'name' => check_name, 'status' => 1, 'output' => 'WARNING: ' + msg, 'handler' => config[:handler] }
    sensu_client_socket d.to_json
  end

  def send_critical(check_name, msg)
    d = { 'name' => check_name, 'status' => 2, 'output' => 'CRITICAL: ' + msg, 'handler' => config[:handler] }
    sensu_client_socket d.to_json
  end

  def run
    rspec_results = `ruby -S rspec #{config[:spec_dir]} --format json`
    parsed        = JSON.parse(rspec_results)

    parsed['examples'].each do |rspec_test|
      test_name = rspec_test['file_path'].split('/')[-1] + '_' + rspec_test['line_number'].to_s
      output    = rspec_test['full_description']

      if rspec_test['status'] == 'passed'
        send_ok(test_name, output)
      else
        send_warning(test_name, output)
      end
    end

    puts parsed['summary_line']

    summary       = parsed['summary_line']
    failure_count = summary.split[2]

    if failure_count == '0'
      exit_with(:ok, summary)
    else
      exit_with(:critical, summary)
    end
  end

  def exit_with(sym, message)
    case sym
      when :ok
        ok message
      when :critical
        critical message
      else
        unknown message
    end
  end

end
