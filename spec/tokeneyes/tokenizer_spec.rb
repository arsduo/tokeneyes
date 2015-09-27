require 'spec_helper'

module Tokeneyes
  RSpec.describe Tokenizer do
    describe "#parse_into_words" do
      # As with the WordReader, it is easier and safer to test this by actually feeding it words
      # than by doing elaborate mocking and stubbing.
      let(:tokenizer) { Tokenizer.new(text) }
      let(:results) { tokenizer.parse_into_words }

      context "for a simple text" do
        let(:text) { "I am the very model of a modern major general"}

        it "returns the results matching the text" do
          expect(results.map(&:to_s).join(" ")).to eq(text)
        end

        it "properly captures the beginning of the text" do
          expect(results.first.begins_sentence?).to be true
          # e.g. none of the rest are true
          expect(results[1..-1].none?(&:begins_sentence?)).to be true
        end

        it "properly captures the end of the text" do
          expect(results.last.ends_sentence?).to be true
          # e.g. none of the rest are true
          expect(results[0..-2].none?(&:ends_sentence?)).to be true
        end

        it "captures that there's no punctuation" do
          expect(results.none?(&:punctuation_before)).to be true
          expect(results.none?(&:punctuation_after)).to be true
        end
      end

      context "for a text with some punctuation" do
        let(:text) { "With information vegetable, animal, and mineral!" }

        it "returns results mapping to the words" do
          expect(results.map(&:to_s).join(" ")).to eq("With information vegetable animal and mineral")
        end

        it "properly captures the beginning of the text" do
          expect(results.first.begins_sentence?).to be true
          # e.g. none of the rest are true
          expect(results[1..-1].map(&:begins_sentence?).none?).to be true
        end

        it "properly captures the end of the text" do
          expect(results.last.ends_sentence?).to be true
          # e.g. none of the rest are true
          expect(results[0..-2].map(&:ends_sentence?).none?).to be true
        end

        it "captures the commas as punctuation_after" do
          expect(results[2].punctuation_after).to eq(",")
          expect(results[3].punctuation_after).to eq(",")
        end

        it "captures the commas as punctuation_before" do
          expect(results[3].punctuation_before).to eq(",")
          expect(results[4].punctuation_before).to eq(",")
        end

        it "captures the end puncutation" do
          expect(results[-1].punctuation_after).to eq("!")
        end

        it "captures the lack of beginning punctuation otherwise" do
          expect((results - results[3..4]).none?(&:punctuation_before)).to be true
        end

        it "captures the lack of ending punctuation otherwise" do
          expect((results - results[2..3] - [results.last]).none?(&:punctuation_after)).to be true
        end
      end

      context "for a text multiple sentences" do
        let(:text) { "Oh! False one, you have deceiv'd me!" }

        it "returns results mapping to the words" do
          expect(results.map(&:to_s).join(" ")).to eq("Oh False one you have deceiv'd me")
        end

        it "properly captures the beginning of the text" do
          expect(results.first.begins_sentence?).to be true
        end

        it "properly captures the end of the first sentence" do
          expect(results.first.ends_sentence?).to be true
        end

        it "properly captures the beginning of the second sentence" do
          expect(results[1].begins_sentence?).to be true
        end

        it "properly captures the end of the second sentence" do
          expect(results.last.ends_sentence?).to be true
        end

        it "properly captures the end of the text" do
          expect(results.last.ends_sentence?).to be true
          # e.g. none of the rest are true
          expect(results[1..-2].map(&:ends_sentence?).none?).to be true
        end

        it "captures the comma" do
          expect(results[2].punctuation_after).to eq(",")
          expect(results[3].punctuation_before).to eq(",")
        end

        it "captures the first exclamation mark as punctuation after" do
          expect(results[0].punctuation_after).to eq("!")
        end

        it "does NOT capture the first ! as punctuation_before, because it's a different sentence" do
          expect(results[1].punctuation_before).to be_nil
        end

        it "captures the end puncutation" do
          expect(results[-1].punctuation_after).to eq("!")
        end

        it "captures the lack of beginning punctuation otherwise" do
          expect(([results[0], results[2]] + results[4..-1]).none?(&:punctuation_before)).to be true
        end

        it "captures the lack of ending punctuation otherwise" do
          expect(([results[1]] + results[3..-2]).none?(&:punctuation_after)).to be true
        end
      end

      context "for text with twitter symbols" do
        let(:text) { "Hey @ahkoppel -- look at this; it's #awesome." }

        it "captures all the texts, including the @ and #" do
          expect(results.map(&:to_s).join(" ")).to eq("Hey @ahkoppel look at this it's #awesome")
        end

        skip "captures the --" do
          expect(results[1].punctuation_after).to eq("--")
          expect(results[2].punctuation_before).to eq("--")
        end

        it "ends the sentence at the ;" do
          expect(results[4].ends_sentence?).to be true
          expect(results[5].begins_sentence?).to be true
        end

        it "captures ; as punctuation_after only" do
          expect(results[4].punctuation_after).to eq(";")
          expect(results[5].punctuation_before).to be_nil
        end

        skip "ends with ." do
          expect(results[-1].ends_sentence?).to be true
          expect(results[-1].punctuation_after).to eq(".")
        end
      end
    end
  end
end
