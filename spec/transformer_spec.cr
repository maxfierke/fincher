require "./spec_helper"

describe Typhar::Transformer do
  describe "#transform" do
    it "does stuff" do
      source = "I am a test sentence. The quick brown fox jumps over the lazy dog. That dog is lazy as fuck. God damn. How many dogs there gotta be that be like this man come on son. Why."
      source_scanner = StringScanner.new(source)

      plaintext = "hello"
      plaintext_scanner = StringScanner.new(plaintext)
      seed = 123.to_u32

      transformer = Typhar::Transformer.new(
        plaintext_scanner,
        source_scanner,
        Typhar::DisplacementStrategies::NCharOffset.new(plaintext_scanner, seed, 20),
        Typhar::ReplacementStrategies::NShifter.new(seed, 0)
      )

      transformer.transform.should eq(
        "I am a test sentenceh The quick brown foxejumps over the lazy log. That dog is lazylas fuck. God damn. Hotta be that be like this man come on son. Why."
      )
    end
  end
end
