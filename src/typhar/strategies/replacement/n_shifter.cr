module Typhar
  module ReplacementStrategies
    class NShifter < Base
      getter n

      def initialize(@seed : Int32, @n : Int32)
      end

      def replace(to_replace : String | Char | Nil) : String | Char | Nil
        case to_replace
        when String
          to_replace.gsub { |c| n_shift(c) }
        when Char
          n_shift(to_replace)
        when Nil
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
