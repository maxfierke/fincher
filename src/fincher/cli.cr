module Fincher
  class CLI
    @cli : Commander::Command

    getter :cli

    class Encode
      @seed : UInt32?

      def initialize(options : Commander::Options, args : Commander::Arguments)
        @options = options
        @args = args
      end

      def run(io = STDOUT)
        plaintext_scanner = ::IO::Memory.new(args[0])
        displacement_strategy = options.string["displacement_strategy"]
        replacement_strategy = options.string["replacement_strategy"]

        source_file = if source_text_file = args[1]?
          File.open(source_text_file)
        else
          STDIN
        end

        transformer = Fincher::Transformer.new(
          plaintext_scanner,
          source_file,
          displacement_strategy_for(displacement_strategy, plaintext_scanner, options),
          replacement_strategy_for(replacement_strategy, options)
        ).transform(io)
      ensure
        source_file.close if source_file
      end

      private getter :options, :args

      private def displacement_strategy_for(strategy, plaintext_scanner, options)
        case strategy
        when "word-offset"
          word_offset = options.int["word_offset"].to_i32
          Fincher::DisplacementStrategies::MWordOffset.new(plaintext_scanner, seed, word_offset)
        when "char-offset"
          char_offset = options.int["char_offset"].to_i32
          Fincher::DisplacementStrategies::NCharOffset.new(plaintext_scanner, seed, char_offset)
        when "matching-char-offset"
          word_offset = options.int["word_offset"].to_i32
          Fincher::DisplacementStrategies::MatchingCharOffset.new(plaintext_scanner, seed, word_offset)
        else
          raise StrategyDoesNotExistError.new(
            "Displacement strategy '#{strategy}' does not exist."
          )
        end
      end

      private def replacement_strategy_for(strategy, options)
        case strategy
        when "n-shifter"
          codepoint_shift = options.int["codepoint_shift"].to_i32
          Fincher::ReplacementStrategies::NShifter.new(seed, codepoint_shift)
        when "keymap"
          keymap_name = options.string["keymap"]
          keymap = Fincher::Types::Keymap.load!(keymap_name)
          Fincher::ReplacementStrategies::Keymap.new(seed, keymap)
        else
          raise StrategyDoesNotExistError.new(
            "Replacement strategy '#{strategy}' does not exist."
          )
        end
      end

      private def seed
        @seed ||= options.int["seed"] == 0 ? generate_seed : options.int["seed"].to_u32
      end

      private def generate_seed
        s = Random::Secure.hex(4).to_u32(16)
        Fincher.info "Using #{s} as seed"
        s
      end
    end

    def initialize
      @cli = Commander::Command.new do |cmd|
        cmd.use = "fincher"

        cmd.long = <<-DESC
Encodes a message as typos within a source text.

  Version v#{Fincher::VERSION}
  Compiled at #{Fincher::COMPILED_AT}

  Documentation: https://github.com/maxfierke/fincher
  Issue tracker: https://github.com/maxfierke/fincher/issues
DESC

        cmd.flags.add do |flag|
          flag.name = "version"
          flag.short = "-V"
          flag.long = "--version"
          flag.default = false
          flag.description = "prints version number."
          flag.persistent = true
        end

        cmd.commands.add do |encode_cmd|
          encode_cmd.use = "encode MESSAGE [SRC_FILE]"
          encode_cmd.short = "encode a message"
          encode_cmd.long = <<-DESC
          Encodes MESSAGE in the contents of a file provided by SRC_FILE or STDIN, if not provided.

            Output will be printed to standard output
          DESC

          encode_cmd.flags.add do |flag|
            flag.name = "seed"
            flag.long = "--seed"
            flag.default = 0
            flag.description = "seed value. randomly generated if omitted"
          end

          encode_cmd.flags.add do |flag|
            flag.name = "displacement_strategy"
            flag.long = "--displacement-strategy"
            flag.default = "matching-char-offset"
            flag.description = "displacement strategy (Options: char-offset, word-offset, matching-char-offset)"
          end

          encode_cmd.flags.add do |flag|
            flag.name = "replacement_strategy"
            flag.long = "--replacement-strategy"
            flag.default = "keymap"
            flag.description = "replacement strategy (Options: n-shifter, keymap)"
          end

          encode_cmd.flags.add do |flag|
            flag.name = "char_offset"
            flag.long = "--char-offset"
            flag.default = 130
            flag.description = "character gap between typos (Displacement Strategies: char-offset)"
          end

          encode_cmd.flags.add do |flag|
            flag.name = "word_offset"
            flag.long = "--word-offset"
            flag.default = 38
            flag.description = "word gap between typos (Displacement Strategies: word-offset, matching-char-offset)"
          end

          encode_cmd.flags.add do |flag|
            flag.name = "codepoint_shift"
            flag.long = "--codepoint-shift"
            flag.default = 7
            flag.description = "codepoints to shift (Replacement Strategies: n-shifter)"
          end

          encode_cmd.flags.add do |flag|
            flag.name = "keymap"
            flag.long = "--keymap"
            flag.default = "en-US_qwerty"
            flag.description = "Keymap definition to use for keymap replacement strategy"
          end

          encode_cmd.run do |options, arguments|
            if arguments.empty?
              Fincher.error "message is required"
              next
            end

            if arguments.size > 2
              Fincher.error "unexpected arguments: expected 1-2, received #{arguments.size}"
              next
            end

            Encode.new(options, arguments).run
          end
        end

        cmd.run do |options, _|
          if options.bool["version"]
            puts Fincher::VERSION
            exit
          end

          puts cmd.help
        end
      end
    end

    def self.run!(argv)
      new.run!(argv)
    end

    def run!(argv)
      Commander.run(cli, argv)
    rescue e : ::Fincher::Error
      Fincher.error e.message
    end
  end
end
