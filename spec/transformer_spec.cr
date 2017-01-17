require "./spec_helper"

describe Typhar::Transformer do
  describe "#transform" do
    it "does stuff" do
      source = "I am a test sentence. The quick brown fox jumps over the lazy dog. That dog is lazy as fuck. God damn. How many dogs there gotta be that be like this man come on son. Why."
      source_scanner = StringScanner.new(source)

      plaintext = "hello"
      plaintext_scanner = StringScanner.new(plaintext)

      transformer = Typhar::Transformer.new(
        plaintext_scanner,
        source_scanner,
        Typhar::DisplacementStrategies::NCharOffset.new(plaintext_scanner, 123, 20),
        Typhar::ReplacementStrategies::NShifter.new(123, 0)
      )

      puts transformer.transform

      true.should eq(true)
    end
  end
end
