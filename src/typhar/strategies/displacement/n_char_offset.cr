module Typhar
  module DisplacementStrategies
    class NCharOffset < Base
      getter offset

      def initialize(@plaintext_scanner : StringScanner, @seed : Int32, @offset : Int32)
      end

      def advance_to_next!(scanner : StringScanner) : StringScanner
        raise StrategyNotFeasibleException.new(
          "Cannot advance #{offset} chars at scanner position #{scanner.offset}"
        ) unless is_feasible?(scanner)
        
        scanner.offset += offset
        scanner
      end

      def is_feasible?(scanner : StringScanner)
        scanner.string.size > scanner.offset + offset
      end
    end
  end
end
