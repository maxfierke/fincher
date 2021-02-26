require "./types/*"
require "./strategies/*"

module Fincher
  class Transformer
    getter plaintext_scanner
    getter source_scanner

    def initialize(
      @plaintext_scanner     : Fincher::IO,
      @source_stream         : Fincher::IO,
      @displacement_strategy : Fincher::DisplacementStrategies::Base,
      @replacement_strategy  : Fincher::ReplacementStrategies::Base
    )
    end

    def transform(io) : ::IO
      current_offset = 0

      source_scanner = IOScanner.new(@source_stream)

      plaintext_scanner.each_char do |msg_char|
        # Advance position
        displacer.advance_to_next!(source_scanner, msg_char, io: io)

        # Replace the next char
        replaced_char = replacer.replace(msg_char)
        io << replaced_char

        # Skip the current char, since we just replace it
        source_scanner.skip(1)
      end

      io << source_scanner.gets_to_end
      io
    end

    def displacer
      @displacement_strategy
    end

    def replacer
      @replacement_strategy
    end
  end
end
