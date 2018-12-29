require "./fincher"

Colorize.on_tty_only!
Fincher.debug = true
Fincher::CLI.run ARGV
