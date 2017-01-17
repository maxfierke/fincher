require "./strategies/*"

module Typhar
  class Transformer
    getter plaintext_scanner
    getter source_scanner

    def initialize(
      @plaintext_scanner     : StringScanner,
      @source_scanner        : StringScanner,
      @displacement_strategy : Typhar::DisplacementStrategies::Base,
      @replacement_strategy  : Typhar::ReplacementStrategies::Base
    )
    end

    def transform() : String
      current_offset = 0

      String.build do |builder|
        # Advance position
        displacer.advance_to_next!(source_scanner)
        
        plaintext_scanner.string.each_char do |msg_char|
          # Grab previously unmodified section
          unmodified = source_scanner.string[current_offset...source_scanner.offset]
          builder << unmodified

          # Replace the next char
          replaced_char = replacer.replace(msg_char)
          source_scanner.offset += 1
          builder << replaced_char

          # Record this offset
          current_offset = source_scanner.offset

          # Advance position
          displacer.advance_to_next!(source_scanner)
        end

        builder << source_scanner.rest
        builder
      end
    end

    def displacer
      @displacement_strategy
    end

    def replacer
      @replacement_strategy
    end
  end
end