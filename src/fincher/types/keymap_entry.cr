module Fincher
  module Types
    class KeymapEntry
      include YAML::Serializable

      property shift : String
      property neighbors : Array(String)
    end
  end
end
