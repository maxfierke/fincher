require "../../spec_helper"

describe Typhar::DisplacementStrategies::MatchingCharOffset do
  describe "#advance_to_next!" do
    scanner = IO::Memory.new("hello")

    describe "when the displacement is feasible" do
      matching_char_offsetter = Typhar::DisplacementStrategies::MatchingCharOffset.new(
        scanner,
        123,
        3
      )
      source_text_scanner = Typhar::IOScanner.new(IO::Memory.new("lorem ipsum test blerg smorgasboorg"))

      it "adds the configured offset to the StringScanner#offset" do
        matching_char_offsetter.advance_to_next!(source_text_scanner, 'r')
        source_text_scanner.offset.should eq(20)
      end
    end

    describe "when the displacement is not feasible" do
      matching_char_offsetter = Typhar::DisplacementStrategies::MatchingCharOffset.new(
        scanner,
        123,
        10
      )
      source_text_scanner = Typhar::IOScanner.new(IO::Memory.new("lorem"))

      it "raises an exception" do
        expect_raises(Typhar::StrategyNotFeasibleException) do
          matching_char_offsetter.advance_to_next!(source_text_scanner, 'r')
        end
      end
    end
  end
end
