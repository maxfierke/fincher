require "../../spec_helper"

describe Typhar::DisplacementStrategies::NCharOffset do
  describe "#advance_to_next!" do
    scanner = IO::Memory.new("hello")

    describe "when the displacement is feasible" do
      n_char_offsetter = Typhar::DisplacementStrategies::NCharOffset.new(
        scanner,
        123.to_u32,
        10
      )
      source_text_scanner = IO::Memory.new("lorem ipsum test")

      it "adds the configured offset to the StringScanner#offset" do
        n_char_offsetter.advance_to_next!(source_text_scanner)
        source_text_scanner.pos = 10
      end
    end

    describe "when the displacement is not feasible" do
      n_char_offsetter = Typhar::DisplacementStrategies::NCharOffset.new(
        scanner,
        123.to_u32,
        10
      )
      source_text_scanner = IO::Memory.new("lorem")

      it "raises an exception" do
        expect_raises(Typhar::StrategyNotFeasibleException) do
          n_char_offsetter.advance_to_next!(source_text_scanner)
        end
      end
    end
  end
end
