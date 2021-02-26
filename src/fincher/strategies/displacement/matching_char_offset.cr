module Fincher
  module DisplacementStrategies
    class MatchingCharOffset < Base
      getter offset

      def initialize(@plaintext_scanner : Fincher::IO, @seed : UInt32, @offset : Int32)
      end

      def advance_to_next!(scanner : Fincher::IOScanner, msg_char : Char, io : IO) : Fincher::IOScanner
        offset.times do
          io << scanner.scan_until(/\b[\w\-\']+\b\W+\b/im)

          raise StrategyNotFeasibleError.new(
            "Cannot advance #{offset} words for character '#{msg_char}' at scanner position #{scanner.pos}"
          ) unless is_feasible?(scanner)
        end

        matching_char_str = scanner.scan_until(/#{msg_char}/i)
        raise StrategyNotFeasibleError.new(
          "Cound not find character '#{msg_char}' after #{offset} words at scanner position #{scanner.pos}"
        ) unless matching_char_str
        io << matching_char_str[0...-1]
        scanner.offset = scanner.offset - 1
        scanner
      end

      def is_feasible?(scanner : Fincher::IOScanner)
        !scanner.last_match.nil?
      end
    end
  end
end
