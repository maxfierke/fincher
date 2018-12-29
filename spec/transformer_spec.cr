require "./spec_helper"

describe Fincher::Transformer do
  describe "#transform" do
    it "does stuff" do
      source = "I am a test sentence. The quick brown fox jumps over the lazy dog. That dog is lazy as fuck. God damn. How many dogs there gotta be that be like this man come on son. Why."
      source_scanner = IO::Memory.new(source)

      plaintext = "hello"
      plaintext_scanner = IO::Memory.new(plaintext)
      seed = 123.to_u32

      transformer = Fincher::Transformer.new(
        plaintext_scanner,
        source_scanner,
        Fincher::DisplacementStrategies::NCharOffset.new(plaintext_scanner, seed, 20),
        Fincher::ReplacementStrategies::NShifter.new(seed, 0)
      )

      transformed = IO::Memory.new(source.bytesize)
      transformer.transform(transformed)

      transformed.to_s.should eq(
        "I am a test sentenceh The quick brown foe jumps over the lazl dog. That dog is llzy as fuck. God damo. How many dogs there gotta be that be like this man come on son. Why."
      )
    end
  end
end
