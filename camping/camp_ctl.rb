#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'

c = `which camping`.strip
Daemons.run(c)
