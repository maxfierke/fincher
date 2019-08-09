module Fincher
  module ReplacementStrategies
    abstract class Base
      getter seed

      def initialize(@seed : UInt32)
      end

      abstract def replace(to_replace : Char) : Char
      abstract def replace(to_replace : String) : String
    end
  end
end
