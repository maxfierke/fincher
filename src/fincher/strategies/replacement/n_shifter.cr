module Fincher
  module ReplacementStrategies
    class NShifter < Base
      getter n

      def initialize(@seed : UInt32, @n : Int32)
      end

      def replace(to_replace : Char) : Char
        n_shift(to_replace)
      end

      def replace(to_replace : String) : String
        to_replace.gsub { |c| n_shift(c) }
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
