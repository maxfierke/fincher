module Fincher
  module ReplacementStrategies
    class Keymap < Base
      getter keymap

      def initialize(@seed : UInt32, @keymap : Fincher::Types::Keymap)
      end

      def replace(to_replace : Char) : Char
        keymap_replace(to_replace)
      end

      def replace(to_replace : String) : String
        to_replace.gsub { |c| keymap_replace(c) }
      end

      private def keymap_replace(to_replace : Char) : Char
        keymap_entry = keymap[to_replace.to_s]?

        if keymap_entry
          keymap_entry.neighbors.sample(sampler).char_at(0)
        else
          raise UnknownKeyError.new("Unknown key '#{to_replace}' in keymap")
        end
      end

      private def sampler
        @sampler ||= Random.new(seed)
      end
    end
  end
end
