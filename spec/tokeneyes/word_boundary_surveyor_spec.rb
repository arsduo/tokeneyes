require 'spec_helper'

module Tokeneyes
  RSpec.describe WordBoundarySurveyor do
    possible_dividers = ["#", ".", "'", "-"]

    describe "#word_finished?" do
      it "returns false if the word hasn't terminated" do
        expect(WordBoundarySurveyor.new("a", "b").word_finished?).to be_falsy
      end

      it "treats numbers as word components" do
        expect(WordBoundarySurveyor.new("1", "9").word_finished?).to be_falsy
      end

      "äüßöÖÄÜ".split("").each do |euro_char|
        it "treats #{euro_char} as a word" do
          expect(WordBoundarySurveyor.new("1", euro_char).word_finished?).to be_falsy
        end
      end

      possible_dividers.each do |possible_divider|
        it "returns false if the word encounters #{possible_divider} after a word" do
          expect(WordBoundarySurveyor.new("a", possible_divider).word_finished?).to be_falsy
        end

        it "returns false if it encounters #{possible_divider} and then a word" do
          expect(WordBoundarySurveyor.new(possible_divider, "a").word_finished?).to be_falsy
        end

        it "returns true if it encounters #{possible_divider} and then another divider"  do
          expect(WordBoundarySurveyor.new(possible_divider, possible_divider).word_finished?).to be_truthy
        end

        it "returns true if it encounters #{possible_divider} and then a different value"  do
          expect(WordBoundarySurveyor.new(possible_divider, " ").word_finished?).to be_truthy
        end
      end

      ["!", "?", ";"].each do |definite_divider|
        it "returns true if it encounters #{definite_divider}" do
          expect(WordBoundarySurveyor.new("a", definite_divider).word_finished?).to be_truthy
        end
      end

      it "returns true if it encounters another random character" do
        expect(WordBoundarySurveyor.new("a", "😺").word_finished?).to be_truthy
      end

      it "returns true for an empty string" do
        expect(WordBoundarySurveyor.new("a", "").word_finished?).to be_truthy
      end
    end

    describe "#character_to_add_to_word" do
      it "returns the current character if it's a letter" do
        expect(WordBoundarySurveyor.new("a", "b").character_to_add_to_word).to eq("b")
      end

      it "returns the current character if it's a number" do
        expect(WordBoundarySurveyor.new("a", "1").character_to_add_to_word).to eq("1")
      end

      it "returns the previous and current character if the possible boundary wasn't the word end" do
        expect(WordBoundarySurveyor.new("#", "1").character_to_add_to_word).to eq("#1")
      end

      it "returns an empty string for a possible word boundary" do
        expect(WordBoundarySurveyor.new("1", "#").character_to_add_to_word).to eq("")
      end

      it "returns an empty string for a definite boundary" do
        expect(WordBoundarySurveyor.new("a", "!").character_to_add_to_word).to eq("")
      end

      it "returns an empty string for an empty string" do
        expect(WordBoundarySurveyor.new("a", "").character_to_add_to_word).to eq("")
      end
    end

    describe "#punctuation" do
      it "returns nil if the word isn't over" do
        expect(WordBoundarySurveyor.new("a", "b").punctuation).to be_nil
      end

      it "returns nil if we're at a possible boundary" do
        expect(WordBoundarySurveyor.new("a", "#").punctuation).to be_nil
      end

      ["-", "."].each do |possible_divider|
        it "returns the previous character if #{possible_divider} did end the word" do
          expect(WordBoundarySurveyor.new(possible_divider, "-").punctuation).to eq(possible_divider)
        end
      end

      ["?", ",", "!", ";"].each do |punctuation_mark|
        it "returns a current character if the word ended with #{punctuation_mark}" do
          expect(WordBoundarySurveyor.new("1", punctuation_mark).punctuation).to eq(punctuation_mark)
        end
      end

      it "doesn't return punctuation for other characters" do
        expect(WordBoundarySurveyor.new("a", "😺").punctuation).to be_nil
      end
    end

    describe "#sentence_ended?" do
      ["!", "?", ";"].each do |definite_divider|
        it "returns true if the sentence ended on a #{definite_divider}" do
          expect(WordBoundarySurveyor.new("a", definite_divider).sentence_ended?).to be_truthy
        end
      end

      it "returns true if the sentence ended on a ." do
        expect(WordBoundarySurveyor.new(".", " ").sentence_ended?).to be_truthy
      end

      it "return false if the word may be continuing" do
        expect(WordBoundarySurveyor.new("a", ".").sentence_ended?).to be_falsy
      end

      it "returns false if the word isn't over" do
        expect(WordBoundarySurveyor.new("a", "1").sentence_ended?).to be_falsy
      end

      it "returns false if the word but not the sentence is over" do
        expect(WordBoundarySurveyor.new("a", ")").sentence_ended?).to be_falsy
      end
    end
  end
end
