require "../../spec_helper"

describe Typhar::ReplacementStrategies::Keymap do
  describe "#replace!" do
    describe "when given a char" do
      it "replaces char with a neighboring char based on keymap" do
        keymap_replacer = Typhar::ReplacementStrategies::Keymap.new(8.to_u32, "en-US_qwerty")
        to_replace = 'b'
        replaced = keymap_replacer.replace(to_replace)

        replaced.should match(/^[vghnVGHN]$/)
      end
    end

    describe "when given a string" do
      it "replaces each char in the string with a neighboring char based on keymap" do
        keymap_replacer = Typhar::ReplacementStrategies::Keymap.new(8.to_u32, "en-US_qwerty")
        to_replace = "bbbbb"
        replaced = keymap_replacer.replace(to_replace)

        replaced.should match(/^[vghnVGHN]{5}$/)
      end
    end
  end
end
