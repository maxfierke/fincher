require "../../spec_helper"

describe Typhar::DisplacementStrategies::MWordOffset do
  describe "#advance_to_next!" do
    scanner = IO::Memory.new("hello")

    describe "when the displacement is feasible" do
      m_word_offsetter = Typhar::DisplacementStrategies::MWordOffset.new(
        scanner,
        123.to_u32,
        3
      )
      source_text_scanner = Typhar::IOScanner.new(IO::Memory.new("lorem ipsum test blerg smorgasboorg"))

      it "adds the configured offset to the StringScanner#offset" do
        m_word_offsetter.advance_to_next!(source_text_scanner)
        source_text_scanner.offset.should eq(16)
      end
    end

    describe "when the displacement is not feasible" do
      m_word_offsetter = Typhar::DisplacementStrategies::MWordOffset.new(
        scanner,
        123.to_u32,
        10
      )
      source_text_scanner = Typhar::IOScanner.new(IO::Memory.new("lorem"))

      it "raises an exception" do
        expect_raises(Typhar::StrategyNotFeasibleException) do
          m_word_offsetter.advance_to_next!(source_text_scanner)
        end
      end
    end
  end
end
