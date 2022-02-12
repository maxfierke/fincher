require "../../spec_helper"

describe Fincher::DisplacementStrategies::MWordOffset do
  describe "#advance_to_next!" do
    scanner = IO::Memory.new("hello")

    describe "when the displacement is feasible" do
      m_word_offsetter = Fincher::DisplacementStrategies::MWordOffset.new(
        scanner,
        123,
        3
      )
      source_text_scanner = Fincher::IOScanner.new(IO::Memory.new("lorem ipsum test blerg smorgasboorg"))
      output_io = IO::Memory.new

      it "adds the configured offset to the StringScanner#offset" do
        m_word_offsetter.advance_to_next!(source_text_scanner, Char::ZERO, io: output_io)
        source_text_scanner.offset.should eq(17)
        output_io.to_s.should eq("lorem ipsum test ")
      end
    end

    describe "when the displacement is not feasible" do
      m_word_offsetter = Fincher::DisplacementStrategies::MWordOffset.new(
        scanner,
        123,
        10
      )
      source_text_scanner = Fincher::IOScanner.new(IO::Memory.new("lorem"))
      output_io = IO::Memory.new

      it "raises an exception" do
        expect_raises(Fincher::StrategyNotFeasibleError) do
          m_word_offsetter.advance_to_next!(source_text_scanner, Char::ZERO, io: output_io)
        end
      end
    end
  end
end
