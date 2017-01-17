module Typhar
  module DisplacementStrategies
    abstract class Base
      getter seed
      getter plaintext_scanner

      def initialize(@plaintext_scanner : StringScanner, @seed : UInt32)
      end

      abstract def advance_to_next!(scanner : StringScanner) : StringScanner

      def advance_to_next(scanner : StringScanner)
        advance_to_next!(scanner.dup)
      end

      abstract def is_feasible?(scanner : StringScanner)
    end
  end
end
