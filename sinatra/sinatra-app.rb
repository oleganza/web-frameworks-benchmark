#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'

# -- sinatra-app.rb -e production -p 5000
__DIR__ = File.expand_path(File.dirname(__FILE__))
Daemons.run_proc('sinatra-daemon', :log_output => 'sinatra.log') do
  Dir.chdir(__DIR__)
  ARGV.shift
  ARGV.shift
  
  require 'sinatra'
  get '/' do
    %{Hi, I'm a small Sinatra application!}
  end
  
  if Sinatra.application.options.run
    Sinatra.run
  end
end
