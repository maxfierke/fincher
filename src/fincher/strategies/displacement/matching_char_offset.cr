module Fincher
  module DisplacementStrategies
    class MatchingCharOffset < Base
      getter offset

      def initialize(@plaintext_scanner : Fincher::IO, @seed : UInt32, @offset : Int32)
      end

      def advance_to_next!(scanner : Fincher::IOScanner, msg_char : Char) : Fincher::IOScanner
        offset.times do
          scanner.scan_until(/\b[\w\-\']+\b\W+\b/im)

          raise StrategyNotFeasibleError.new(
            "Cannot advance #{offset} words for character '#{msg_char}' at scanner position #{scanner.pos}"
          ) unless is_feasible?(scanner)
        end
        scanner.skip_until(/#{msg_char}/i)
        scanner.offset = scanner.offset - 1
        scanner
      end

      def is_feasible?(scanner : Fincher::IOScanner)
        !scanner.last_match.nil?
      end
    end
  end
end
