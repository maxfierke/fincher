module Typhar
  module DisplacementStrategies
    abstract class Base
      getter seed
      getter plaintext_scanner

      def initialize(@plaintext_scanner : Typhar::IO, @seed : UInt32)
      end

      abstract def advance_to_next!(scanner : Typhar::IO) : Typhar::IO

      def advance_to_next(scanner : Typhar::IO)
        advance_to_next!(scanner.dup)
      end

      abstract def is_feasible?(scanner : Typhar::IO)
    end
  end
end
