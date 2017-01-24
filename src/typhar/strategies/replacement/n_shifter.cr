module Typhar
  module ReplacementStrategies
    class NShifter < Base
      getter n

      def initialize(@seed : UInt32, @n : Int32)
      end

      def replace(to_replace : String | Char) : String | Char
        case to_replace
        when String
          to_replace.gsub { |c| n_shift(c) }
        else
          n_shift(to_replace)
        end
      end

      private def n_shift(char : Char) : Char
        if char < Char::MAX
          char + n
        else
          '\u{1}'
        end
      end
    end
  end
end
