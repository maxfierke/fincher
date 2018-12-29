module Fincher
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

      def self.load!(keymap_name)
        keymap_file = Fincher::EmbeddedFs.get?("keymaps/#{keymap_name}.yml")

        if keymap_file
          keymap_yml = keymap_file.gets_to_end
          from_yaml(keymap_yml)
        else
          raise UnknownKeymapError.new(
            "Keymap '#{keymap_name}' does not exist. Are you able to define it?\
            Please open a PR on https://github.com/maxfierke/fincher"
          )
        end
      end

      def self.from_yaml(*args)
        super(*args).not_nil!.dereference!
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

        self
      end
    end
  end
end
