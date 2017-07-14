module Typhar
  module DisplacementStrategies
    class MWordOffset < Base
      getter offset

      def initialize(@plaintext_scanner : Typhar::IO, @seed : UInt32, @offset : Int32)
      end

      def advance_to_next!(scanner : Typhar::IO) : Typhar::IO
        last_match = nil

        offset.times do
          last_match = scanner.scan_until(/(\b[\w\-\']+)\b/)

          if last_match.nil?
            raise StrategyNotFeasibleException.new(
              "Cannot advance #{offset} words at scanner position #{scanner.pos}"
            ) unless is_feasible?(scanner)
          end
        end
        scanner
      end

      def is_feasible?(scanner : Typhar::IO)
        scanner_size(scanner) > scanner.pos + offset
      end

      private def scanner_size(scanner : Typhar::IO)
        case scanner
        when ::IO::FileDescriptor
          scanner.stat.size
        else
          scanner.size
        end
      end
    end
  end
end
