require "./typhar"

Colorize.on_tty_only!
Typhar.debug = true
Typhar::CLI.run ARGV
