module Typhar
  module ReplacementStrategies
    abstract class Base
      getter seed

      def initialize(@seed : UInt32)
      end

      abstract def replace(to_replace : String | Char) : String | Char
    end
  end
end
