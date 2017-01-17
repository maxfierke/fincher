module Typhar
  class CLI < ::Cli::Supercommand
    version Typhar::VERSION
    command_name "typhar"

    class Options
      help
    end

    class Help
      header "Encodes a message as typos within a source text."
      footer "(C) 2017 Max Fierke"
    end

    class Encode < ::Cli::Command
      class Options
        arg "source_text_file", required: true, desc: "source text file"
        arg "message", required: true, desc: "message"
        string "--seed",         var: "NUMBER", default: "", desc: "seed value. randomly generated if omitted"
        string "--fixed-offset", var: "NUMBER", default: "30", desc: "character gap between typos"
        string "--char-shift",   var: "NUMBER", default: "0",  desc: "codepoints to shift"
      end

      class Help
        caption "encode message"
      end

      def run
        source_file = File.read(args.source_text_file)
        plaintext_scanner = StringScanner.new(args.message)
        source_scanner = StringScanner.new(source_file)
        seed = options.seed.empty? ? Random.new_seed : options.seed.to_u32
        offset = options.fixed_offset.to_i
        char_shift = options.char_shift.to_i

        transformer = Typhar::Transformer.new(
          plaintext_scanner,
          source_scanner,
          Typhar::DisplacementStrategies::NCharOffset.new(plaintext_scanner, seed, offset),
          Typhar::ReplacementStrategies::NShifter.new(seed, char_shift)
        )

        puts transformer.transform
      end
    end

    class Version < ::Cli::Command
      class Help
        caption "print the version"
      end

      def run
        puts "Typhar #{version}"
      end
    end
  end
end
