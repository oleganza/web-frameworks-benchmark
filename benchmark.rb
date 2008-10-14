#!/usr/bin/env ruby

#
# Runners
#

module Frameworks
  module Merb
    @port = 4000
    @path = "merb"
  
    def start
      execute "MERB_ENV=production merb -p #{port} -d"
    end
    def stop
      execute "MERB_ENV=production merb -K #{port}"
    end
  end

  module MerbVeryFlat
    @port = 4002
    @path = "merb-very-flat"
  
    def start
      execute "MERB_ENV=production merb -I merb-very-flat.rb -p #{port} -d"
    end
    def stop
      execute "MERB_ENV=production merb -I merb-very-flat.rb -K #{port}"
    end
  end

  # Note: shitty ramaze doesn't allow to run daemon by "ruby start.rb -d", but "ramaze" command
  # doesn't understand "-p" option. Using 7000, as hardcoded in the start.rb
  module Ramaze
    @port = 7000
    @path = "ramaze"
  
    def start 
      execute "ramaze"
    end
    def stop
      execute "ramaze -d stop"
    end
  end

  module Rails
    @port = 3000
    @path = "rails"
  
    def start
      execute "script/server -e production -p #{port} -d "
    end
    def stop
      execute "script/process/reaper -a kill -r mongrel.pid"
    end
  end
end

module Runner
  module ClassMethods
    attr_accessor :port, :path
  end
  class Base
    attr_accessor :port, :path
    def self.new_with(mod)
      i = Class.new(self){ include mod }.new
      i.extend(InstanceMethods)
      mod.extend(ClassMethods)
      i.path = mod.path
      i.port = mod.port
      i
    end
    def execute(str)
      str = "cd #{path}; #{str}"
      puts ">> #{str}"
      system(str)
    end
  end
  module InstanceMethods
    def start
      puts "Starting #{path} on port #{port}"
      super
    end
    def stop
      puts "Stopping #{path} on port #{port}"
      sleep 0.3
      super
    end
  end
end

requests_num = (ENV['N'] || 1000).to_i
concurrency  = (ENV['C'] || 10).to_i

#
# Benchmark suite
# 
runners = Frameworks.constants.map{|c| Frameworks.const_get(c)}
#runners = [Frameworks::Merb, Frameworks::MerbVeryFlat]
runners.map{|r| r.extend(Runner::ClassMethods) }

def run(runners, requests_num, concurrency)
  puts "Testing frameworks with #{requests_num} requests and #{concurrency} connections: "
  # runners.each do |r|
  #   puts "  #{r.name} on port #{r.port}"
  # end

  results = runners.inject({}) do |table, r|
    instance = Runner::Base.new_with(r)
    port = r.port
    name = r.name.gsub(/^.*::/,'')
    puts "Benchmarking #{name} on port #{port}..."
    cmd = %{ab -c #{concurrency} -n #{requests_num} http://127.0.0.1:#{port}/ 2>/dev/null}
    puts ">> #{cmd}"
    result = `#{cmd}`
    sleep 0.3
    result[/Requests per second:\s*([\d.]+)/]
    rps = $1.to_f
    table[name] = rps
    table
  end

  results.each do |name, rps|
    puts "#{name} => #{rps} rps"
  end
end

def start(runners)
  runners.each do |r|
    instance = Runner::Base.new_with(r)
    instance.start
  end
end

def stop(runners)
  runners.each do |r|
    instance = Runner::Base.new_with(r)
    instance.stop
  end  
  sleep 1
  puts "Inspecting stale processes:"
  system(%{ps aux | egrep "merb|start.rb|ramaze|rails"})
end



cmd = ARGV[0]

if cmd == 'start'
  start(runners)
  puts ""
  puts ""
  sleep 0.5
  run(runners, requests_num, concurrency)
elsif cmd == 'restart'
  stop(runners)
  sleep 1
  start(runners)
  puts ""
  puts ""
  sleep 2
  run(runners, requests_num, concurrency)
elsif cmd == 'run'
  run(runners, requests_num, concurrency)
elsif cmd == 'stop'
  stop(runners)
else
  puts "Start and stop servers with ./benchmark.rb start|stop"
  puts "Use './benchmark.rb run' against already booted servers."
  puts ""
end


