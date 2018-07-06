module Typhar
  module DisplacementStrategies
    class NCharOffset < Base
      getter offset

      def initialize(@plaintext_scanner : Typhar::IO, @seed : UInt32, @offset : Int32)
      end

      def advance_to_next!(scanner : Typhar::IOScanner, msg_char : Char) : Typhar::IOScanner
        raise StrategyNotFeasibleException.new(
          "Cannot advance #{offset} chars at scanner position #{scanner.pos}"
        ) unless is_feasible?(scanner)

        scanner.pos += offset
        scanner
      end

      def is_feasible?(scanner : Typhar::IOScanner)
        scanner.size > scanner.pos + offset
      end
    end
  end
end
