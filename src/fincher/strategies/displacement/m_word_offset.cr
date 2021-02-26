module Fincher
  module DisplacementStrategies
    class MWordOffset < Base
      getter offset

      def initialize(@plaintext_scanner : Fincher::IO, @seed : UInt32, @offset : Int32)
      end

      def advance_to_next!(scanner : Fincher::IOScanner, msg_char : Char, io : ::IO) : Fincher::IOScanner
        offset.times do
          io << scanner.scan_until(/\b[\w\-\']+\b\W+\b/im)

          raise StrategyNotFeasibleError.new(
            "Cannot advance #{offset} words at scanner position #{scanner.pos}"
          ) unless is_feasible?(scanner)
        end
        scanner
      end

      def is_feasible?(scanner : Fincher::IOScanner)
        !scanner.last_match.nil?
      end
    end
  end
end
