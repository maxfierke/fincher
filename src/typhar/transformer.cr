require "./strategies/*"

module Typhar
  class Transformer
    getter plaintext_scanner
    getter source_scanner

    def initialize(
      @plaintext_scanner     : Typhar::IO,
      @source_scanner        : Typhar::IO,
      @displacement_strategy : Typhar::DisplacementStrategies::Base,
      @replacement_strategy  : Typhar::ReplacementStrategies::Base
    )
    end

    def transform() : String
      current_offset = 0

      String.build do |builder|
        # Advance position
        displacer.advance_to_next!(source_scanner)
        
        plaintext_scanner.each_char do |msg_char|
          # Grab previously unmodified section
          read_size = source_scanner.pos - current_offset
          source_scanner.seek(current_offset)
          unmodified = source_scanner.gets(read_size)
          builder << unmodified

          # Replace the next char
          replaced_char = replacer.replace(msg_char)
          source_scanner.skip(1)
          builder << replaced_char

          # Record this offset
          current_offset = source_scanner.pos

          # Advance position
          displacer.advance_to_next!(source_scanner)
        end

        builder << source_scanner.gets_to_end
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