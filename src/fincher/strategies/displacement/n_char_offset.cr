module Fincher
  module DisplacementStrategies
    class NCharOffset < Base
      getter offset

      def initialize(@plaintext_scanner : Fincher::IO, @seed : UInt32, @offset : Int32)
      end

      def advance_to_next!(scanner : Fincher::IOScanner, msg_char : Char) : Fincher::IOScanner
        raise StrategyNotFeasibleError.new(
          "Cannot advance #{offset} chars at scanner position #{scanner.pos}"
        ) unless is_feasible?(scanner)

        scanner.pos += offset
        scanner
      end

      def is_feasible?(scanner : Fincher::IOScanner)
        scanner.size > scanner.pos + offset
      end
    end
  end
end
