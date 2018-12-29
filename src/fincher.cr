require "colorize"
require "cli"
require "random/secure"
require "yaml"
require "./fincher/*"

module Fincher
  @@debug = false

  def self.debug=(value)
    @@debug = value
  end

  def self.debug(msg)
    if debug = @@debug
      STDERR.puts "[+] #{msg}".colorize(:light_gray)
    end
  end

  def self.info(msg)
    STDERR.puts msg
  end

  def self.error(msg)
    STDERR.puts "#{msg}".colorize(:red)
  end
end
