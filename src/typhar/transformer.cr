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
      last_offset = 0
      str = String.build do |builder|
        # Advance position
        displacer.advance_to_next!(source_scanner)
        
        plaintext_scanner.string.each_char do |msg_char|
          # Grab previously unmodified section
          unmodified = source_scanner.string[last_offset...source_scanner.offset]
          builder << unmodified

          # Replace the next char
          replaced_char = replacer.replace(msg_char)
          source_scanner.offset += 1
          builder << replaced_char

          # Record this offset
          last_offset = source_scanner.offset

          # Advance position
          displacer.advance_to_next!(source_scanner)
        end

        rest_size = source_scanner.string.size - last_offset
        builder << source_scanner.string[last_offset..rest_size]

        builder
      end
      str
    end

    def displacer
      @displacement_strategy
    end

    def replacer
      @replacement_strategy
    end
  end
end