module Typhar
  module DisplacementStrategies
    abstract class Base
      getter seed
      getter plaintext_scanner

      def initialize(@plaintext_scanner : Typhar::IO, @seed : UInt32)
      end

      abstract def advance_to_next!(scanner : Typhar::IOScanner, msg_char : Char) : Typhar::IOScanner

      abstract def is_feasible?(scanner : Typhar::IOScanner)
    end
  end
end
