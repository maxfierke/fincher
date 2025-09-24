require "./fincher"

Colorize.on_tty_only!
Fincher.debug = {{flag?(:debug)}}
Fincher::CLI.run!(ARGV)
