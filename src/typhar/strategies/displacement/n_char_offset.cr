module Typhar
  module DisplacementStrategies
    class NCharOffset < Base
      getter offset

      def initialize(@plaintext_scanner : Typhar::IO, @seed : UInt32, @offset : Int32)
      end

      def advance_to_next!(scanner : Typhar::IO) : Typhar::IO
        raise StrategyNotFeasibleException.new(
          "Cannot advance #{offset} chars at scanner position #{scanner.pos}"
        ) unless is_feasible?(scanner)

        scanner.pos += offset
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
