module Fincher
  # Date and time when binary was compiled
  COMPILED_AT = {{`date -u`.chomp.stringify}}

  # `fincher` version
  VERSION = {{`shards version`.chomp.stringify}}
end
