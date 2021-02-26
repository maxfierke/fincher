module Fincher
  module DisplacementStrategies
    abstract class Base
      getter seed
      getter plaintext_scanner

      def initialize(@plaintext_scanner : Fincher::IO, @seed : UInt32)
      end

      abstract def advance_to_next!(scanner : Fincher::IOScanner, msg_char : Char, io : ::IO) : Fincher::IOScanner

      abstract def is_feasible?(scanner : Fincher::IOScanner)
    end
  end
end
