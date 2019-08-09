require "../../spec_helper"

describe Fincher::ReplacementStrategies::Keymap do
  describe "#replace!" do
    describe "when given a char" do
      it "replaces char with a neighboring char based on keymap" do
        keymap = Fincher::Types::Keymap.load!("en-US_qwerty")
        keymap_replacer = Fincher::ReplacementStrategies::Keymap.new(8.to_u32, keymap)
        to_replace = 'b'
        replaced = keymap_replacer.replace(to_replace)

        replaced.to_s.should match(/^[vghnVGHN]$/)
      end
    end

    describe "when given a string" do
      it "replaces each char in the string with a neighboring char based on keymap" do
        keymap = Fincher::Types::Keymap.load!("en-US_qwerty")
        keymap_replacer = Fincher::ReplacementStrategies::Keymap.new(8.to_u32, keymap)
        to_replace = "bbbbb"
        replaced = keymap_replacer.replace(to_replace)

        replaced.should match(/^[vghnVGHN]{5}$/)
      end
    end
  end
end
