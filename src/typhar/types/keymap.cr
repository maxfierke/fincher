module Typhar
  module Types
    class Keymap
      YAML.mapping(
        data: {
          type: Hash(String, KeymapEntry)
        }
      )

      def [](key)
        data[key]?.not_nil!
      end

      def []?(key)
        data.fetch(key.to_s) do |key|
          result = data.find { |k, v| v.shift == key }
          if result
            result[1]
          else
            nil
          end
        end
      end

      def dereference!
        data.map do |key, value|
          value.neighbors = value.neighbors.flat_map do |neighbor|
            if data[neighbor]?
              neighbor_entry = data[neighbor]
              [neighbor, neighbor_entry.shift]
            else
              raise UnknownKeyError.new("Unknown key '#{neighbor}' in keymap")
            end
          end
        end
      end
    end
  end
end
