require "../../spec_helper"

describe Fincher::DisplacementStrategies::NCharOffset do
  describe "#advance_to_next!" do
    scanner = IO::Memory.new("hello")

    describe "when the displacement is feasible" do
      n_char_offsetter = Fincher::DisplacementStrategies::NCharOffset.new(
        scanner,
        123.to_u32,
        10
      )
      source_text_scanner = Fincher::IOScanner.new(IO::Memory.new("lorem ipsum test"))

      it "adds the configured offset to the StringScanner#offset" do
        n_char_offsetter.advance_to_next!(source_text_scanner, Char::ZERO)
        source_text_scanner.pos = 10
      end
    end

    describe "when the displacement is not feasible" do
      n_char_offsetter = Fincher::DisplacementStrategies::NCharOffset.new(
        scanner,
        123.to_u32,
        10
      )
      source_text_scanner = Fincher::IOScanner.new(IO::Memory.new("lorem"))

      it "raises an exception" do
        expect_raises(Fincher::StrategyNotFeasibleException) do
          n_char_offsetter.advance_to_next!(source_text_scanner, Char::ZERO)
        end
      end
    end
  end
end
