require 'spec_helper'

module Tokeneyes
  RSpec.describe WordBuilder do
    possible_dividers = ["#", ".", "'", "-"]

    describe "#word_finished?" do
      it "returns false if the word hasn't terminated" do
        expect(WordBuilder.new("a", "b", "aba").word_finished?).to be_falsy
      end

      it "treats numbers as word components" do
        expect(WordBuilder.new("a", "9", "aj1").word_finished?).to be_falsy
      end

      "äüßöÖÄÜ".split("").each do |euro_char|
        it "treats #{euro_char} as a word" do
          expect(WordBuilder.new("1", euro_char, "a").word_finished?).to be_falsy
        end
      end

      possible_dividers.each do |possible_divider|
        it "returns false if the word encounters #{possible_divider} after a word" do
          expect(WordBuilder.new("a", possible_divider, "abc").word_finished?).to be_falsy
        end

        it "returns false if it encounters #{possible_divider} and then a word" do
          expect(WordBuilder.new(possible_divider, "a", "abc").word_finished?).to be_falsy
        end

        it "returns true if it encounters #{possible_divider} and then another divider"  do
          expect(WordBuilder.new(possible_divider, possible_divider, "abc").word_finished?).to be_truthy
        end

        it "returns true if it encounters #{possible_divider} and then a different value"  do
          expect(WordBuilder.new(possible_divider, " ", "abc").word_finished?).to be_truthy
        end
      end

      ["!", "?", ";"].each do |definite_divider|
        it "returns true if it encounters #{definite_divider}" do
          expect(WordBuilder.new("a", definite_divider, "a").word_finished?).to be_truthy
        end
      end

      it "returns true if it encounters another random character" do
        expect(WordBuilder.new("a", "😺", "a").word_finished?).to be_truthy
      end

      it "returns true for an empty string" do
        expect(WordBuilder.new("a", "", "a").word_finished?).to be_truthy
      end

      it "returns false if the first character is blank and it's followed by a letter" do
        expect(WordBuilder.new("", "a", "").word_finished?).to be_falsy
      end

      it "returns false if the first character is blank and followed by a possible boundary" do
        expect(WordBuilder.new("", "-", "").word_finished?).to be_falsy
      end

      it "returns false if the first character is blank and followed by a definite boundary" do
        expect(WordBuilder.new("", "!", "").word_finished?).to be_falsy
      end
    end

    describe "#character_to_add_to_word" do
      it "returns the current character if it's a letter" do
        expect(WordBuilder.new("a", "b", "a").character_to_add_to_word).to eq("b")
      end

      it "returns the current character if it's a number" do
        expect(WordBuilder.new("a", "1", "ab").character_to_add_to_word).to eq("1")
      end

      it "returns the previous and current character if there is a word and the possible boundary wasn't the word end" do
        expect(WordBuilder.new("#", "1", "abc").character_to_add_to_word).to eq("#1")
      end

      it "returns the just the current character after a possible boundary if there isn't a word previously" do
        expect(WordBuilder.new("#", "1", "").character_to_add_to_word).to eq("1")
      end

      it "returns an empty string for two possible boundaries" do
        expect(WordBuilder.new("#", "-", "abc").character_to_add_to_word).to eq("")
      end

      it "returns an empty string for .." do
        expect(WordBuilder.new(".", ".", "abc").character_to_add_to_word).to eq("")
      end

      it "returns .a when continuing past a possible boundary" do
        expect(WordBuilder.new(".", "a", "abc").character_to_add_to_word).to eq(".a")
      end

      it "returns an empty string for a space" do
        expect(WordBuilder.new("1", " ", "1").character_to_add_to_word).to eq("")
      end

      it "returns an empty string for a possible word boundary" do
        expect(WordBuilder.new("1", "#", "1").character_to_add_to_word).to eq("")
      end

      it "returns an empty string for a definite boundary" do
        expect(WordBuilder.new("a", "!", "abc3").character_to_add_to_word).to eq("")
      end

      it "returns an empty string for an empty string" do
        expect(WordBuilder.new("a", "", "a").character_to_add_to_word).to eq("")
      end

      it "returns the letter if the first character is blank and it's followed by a letter" do
        expect(WordBuilder.new("", "a", "").character_to_add_to_word).to eq("a")
      end

      it "returns nothing if the first character is blank and followed by a possible boundary" do
        expect(WordBuilder.new("", "-", "").character_to_add_to_word).to eq("")
      end

      it "returns nothing if the first character is blank and followed by a definite boundary" do
        expect(WordBuilder.new("", "!", "").character_to_add_to_word).to eq("")
      end
    end

    describe "#punctuation" do
      it "returns nil if the word isn't over" do
        expect(WordBuilder.new("a", "b", "a").punctuation).to be_nil
      end

      it "returns nil if we're at a possible boundary" do
        expect(WordBuilder.new("a", "#", "a").punctuation).to be_nil
      end

      ["-", "."].each do |possible_divider|
        it "returns the previous character if #{possible_divider} did end the word" do
          expect(WordBuilder.new(possible_divider, "-", "a").punctuation).to eq(possible_divider)
        end
      end

      ["?", ",", "!", ";"].each do |punctuation_mark|
        it "returns a current character if the word ended with #{punctuation_mark}" do
          expect(WordBuilder.new("1", punctuation_mark, "1").punctuation).to eq(punctuation_mark)
        end
      end

      it "doesn't return punctuation for other characters" do
        expect(WordBuilder.new("a", "😺", "a").punctuation).to be_nil
      end
    end

    describe "#sentence_ended?" do
      ["!", "?", ";"].each do |definite_divider|
        it "returns true if the sentence ended on a #{definite_divider}" do
          expect(WordBuilder.new("a", definite_divider, "a").sentence_ended?).to be_truthy
        end
      end

      it "returns true if the sentence ended on a ." do
        expect(WordBuilder.new(".", " ", "a").sentence_ended?).to be_truthy
      end

      it "returns false if the word hasn't started" do
        expect(WordBuilder.new("", "!", "").sentence_ended?).to be_falsy
      end

      it "return false if the word may be continuing" do
        expect(WordBuilder.new("a", ".", "a").sentence_ended?).to be_falsy
      end

      it "returns false if the word isn't over" do
        expect(WordBuilder.new("a", "1", "a").sentence_ended?).to be_falsy
      end

      it "returns false if the word but not the sentence is over" do
        expect(WordBuilder.new("a", ")", "a").sentence_ended?).to be_falsy
      end
    end
  end
end
