module Fincher
  class CLI < ::Cli::Supercommand
    version Fincher::VERSION
    command_name "fincher"

    class Options
      help
    end

    class Help
      header "Encodes a message as typos within a source text."
      footer "(C) 2017 Max Fierke"
    end

    class Encode < ::Cli::Command
      @seed : UInt32?

      class Options
        arg "source_text_file", required: true, desc: "source text file"
        arg "message", required: true, desc: "message"
        string "--seed",
               var: "NUMBER",
               required: false,
               default: "",
               desc: "seed value. randomly generated if omitted"
        string "--displacement-strategy",
               var: "STRING",
               default: "word-offset",
               desc: "displacement strategy (Options: char-offset, word-offset, matching-char-offset)"
        string "--replacement-strategy",
               var: "STRING",
               default: "n-shifter",
               desc: "replacement strategy (Options: n-shifter, keymap)"
        string "--char-offset",
               var: "NUMBER",
               default: "130",
               desc: "character gap between typos (Displacement Strategies: char-offset)"
        string "--word-offset",
               var: "NUMBER",
               default: "38",
               desc: "word gap between typos (Displacement Strategies: word-offset, matching-char-offset)"
        string "--codepoint-shift",
               var: "NUMBER",
               default: "7",
               desc: "codepoints to shift (Replacement Strategies: n-shifter)"
      end

      class Help
        caption "encode message"
      end

      def run(io = STDOUT)
        plaintext_scanner = ::IO::Memory.new(args.message)
        displacement_strategy = options.displacement_strategy
        replacement_strategy = options.replacement_strategy
        source_file = File.open(args.source_text_file)

        transformer = Fincher::Transformer.new(
          plaintext_scanner,
          source_file,
          displacement_strategy_for(displacement_strategy, plaintext_scanner, options),
          replacement_strategy_for(replacement_strategy, options)
        ).transform(io)
      rescue e : StrategyDoesNotExistException
        Fincher.error e.message
      ensure
        source_file.close if source_file
      end

      private def displacement_strategy_for(strategy, plaintext_scanner, options)
        case strategy
        when "word-offset"
          word_offset = options.word_offset.to_i
          Fincher::DisplacementStrategies::MWordOffset.new(plaintext_scanner, seed, word_offset)
        when "char-offset"
          char_offset = options.char_offset.to_i
          Fincher::DisplacementStrategies::NCharOffset.new(plaintext_scanner, seed, char_offset)
        when "matching-char-offset"
          word_offset = options.word_offset.to_i
          Fincher::DisplacementStrategies::MatchingCharOffset.new(plaintext_scanner, seed, word_offset)
        else
          raise StrategyDoesNotExistException.new(
            "Displacement strategy '#{strategy}' does not exist."
          )
        end
      end

      private def replacement_strategy_for(strategy, options)
        case strategy
        when "n-shifter"
          codepoint_shift = options.codepoint_shift.to_i
          Fincher::ReplacementStrategies::NShifter.new(seed, codepoint_shift)
        when "keymap"
          keymap_name = "en-US_qwerty"
          Fincher::ReplacementStrategies::Keymap.new(seed, keymap_name)
        else
          raise StrategyDoesNotExistException.new(
            "Replacement strategy '#{strategy}' does not exist."
          )
        end
      end

      private def seed
        @seed ||= options.seed.empty? ? generate_seed : options.seed.to_u32
      end

      private def generate_seed
        s = Random::Secure.hex(4).to_u32(16)
        Fincher.info "Using #{s} as seed"
        s
      end
    end

    class Version < ::Cli::Command
      class Help
        caption "print the version"
      end

      def run
        puts "Fincher #{version}"
      end
    end
  end
end
