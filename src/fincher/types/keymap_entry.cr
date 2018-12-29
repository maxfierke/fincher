module Fincher
  module Types
    class KeymapEntry
      YAML.mapping(
        shift: String,
        neighbors: Array(String)
      )
    end
  end
end
