#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'

__DIR__ = File.expand_path(File.dirname(__FILE__))
#line = (ARGV[2..-1] || []).join(' ')
c = `which camping`.strip
Daemons.run(c)

# Daemons.run_proc('camping-daemon') do
# 
#   Dir.chdir(__DIR__)
#   exec("camping camp.rb #{line}")
# end

