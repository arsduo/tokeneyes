require 'spec_helper'

module Tokeneyes
  RSpec.describe WordReader do
    # Rather than do specs with stubs, it seems easier and safer to integration-test this with
    # the WordBoundarySurveyor -- pass in a bunch of word combinations and see what it gets.

    describe "#read_word" do
      let(:text_stream) { StringIO.new(phrase) }
      let(:reader) { WordReader.new(text_stream) }
      let(:result) { reader.read_word }
      let(:base_phrase) { "tokeneyes" }

      # defaults
      let(:expected_eof) { false }
      let(:sentence_ends) { false }
      let(:punctuation_before) { nil }
      let(:punctuation_after) { nil }

      shared_examples_for :finds_the_word_properly do
        it "returns the word itself, without spaces" do
          expect(result.text).to eq(expected_phrase)
        end

        it "advances the string appropriately" do
          result
          expect(text_stream.eof?).to be expected_eof
          expect(text_stream.read).to eq(remaining_text) unless expected_eof
        end

        it "properly records if the sentence ends" do
          # we use !! to avoid dealing with nil/false in this shared example group
          expect(!!result.ends_sentence?).to be sentence_ends
        end

        it "doesn't mark that the sentence begins" do
          expect(result.begins_sentence?).to be_falsy
        end

        it "has no punctuation before" do
          expect(result.punctuation_before).to be_nil
        end

        it "properly tracks punctuation after" do
          expect(result.punctuation_after).to eq(punctuation_after)
        end
      end

      context "for a basic word" do
        let(:phrase) { base_phrase }
        let(:expected_phrase) { base_phrase }
        let(:expected_eof) { true }
        let(:sentence_ends) { true }

        it_should_behave_like :finds_the_word_properly
      end

      context "for a basic word ending with a space" do
        let(:phrase) { "#{base_phrase} " }
        let(:expected_phrase) { base_phrase }
        let(:expected_eof) { true }
        let(:sentence_ends) { true }

        it_should_behave_like :finds_the_word_properly
      end

      context "for a basic word ending in punctuation" do
        let(:phrase) { "#{base_phrase}, " }
        let(:expected_phrase) { base_phrase }
        let(:expected_eof) { false }
        let(:remaining_text) { " " }
        let(:sentence_ends) { false }
        let(:punctuation_after) { "," }

        it_should_behave_like :finds_the_word_properly
      end

      context "for a basic word beginning in punctuation" do
        let(:phrase) { ",#{base_phrase}" }
        let(:expected_phrase) { base_phrase }
        let(:expected_eof) { true }
        let(:sentence_ends) { true }

        it_should_behave_like :finds_the_word_properly
      end

      context "for a two-word phrase" do
        let(:second_phrase) { "results" }

        context "for the first word" do
          context "with a space" do
            let(:phrase) { "#{base_phrase} #{second_phrase}" }
            let(:expected_phrase) { base_phrase }
            let(:expected_eof) { false }
            let(:remaining_text) { second_phrase }

            it_should_behave_like :finds_the_word_properly
          end

          context "with an extra space" do
            let(:phrase) { "#{base_phrase}  #{second_phrase}" }
            let(:expected_phrase) { base_phrase }
            let(:expected_eof) { false }
            let(:remaining_text) { " #{second_phrase}" }

            it_should_behave_like :finds_the_word_properly
          end

          context "with non-ending punctuation" do
            let(:phrase) { "#{base_phrase}, #{second_phrase}" }
            let(:expected_phrase) { base_phrase }
            let(:expected_eof) { false }
            let(:remaining_text) { " #{second_phrase}" }
            let(:punctuation_after) { "," }

            it_should_behave_like :finds_the_word_properly
          end

          context "with sentence-ending punctuation" do
            let(:phrase) { "#{base_phrase}! #{second_phrase}" }
            let(:expected_phrase) { base_phrase }
            let(:expected_eof) { false }
            let(:sentence_ends) { true }
            let(:remaining_text) { " #{second_phrase}" }
            let(:punctuation_after) { "!" }

            it_should_behave_like :finds_the_word_properly
          end

          context "with ... in the middle" do
            let(:phrase) { "#{base_phrase}...#{second_phrase}" }
            let(:expected_phrase) { base_phrase }
            let(:expected_eof) { false }
            let(:sentence_ends) { true }
            # it reads the space as well to make sure that it's not a . in a word/url
            let(:remaining_text) { ".#{second_phrase}" }
            let(:punctuation_after) { "." }

            it_should_behave_like :finds_the_word_properly
          end
        end

        context "for the second word in the two-word phrase" do
          before :each do
            reader.read_word
          end
          let(:expected_eof) { true }
          let(:sentence_ends) { true }

          context "in a two-word phrase" do
            let(:phrase) { "#{base_phrase} #{second_phrase}" }
            let(:expected_phrase) { second_phrase }

            it_should_behave_like :finds_the_word_properly
          end

          context "with an extra space" do
            let(:phrase) { "#{base_phrase}  #{second_phrase}" }
            let(:expected_phrase) { second_phrase }

            it_should_behave_like :finds_the_word_properly
          end

          context "with non-ending punctuation" do
            let(:phrase) { "#{base_phrase}, #{second_phrase}" }
            let(:expected_phrase) { second_phrase }

            it_should_behave_like :finds_the_word_properly
          end

          context "with sentence-ending punctuation" do
            let(:phrase) { "#{base_phrase}! #{second_phrase}" }
            let(:expected_phrase) { second_phrase }

            it_should_behave_like :finds_the_word_properly
          end

          context "with ... in the middle" do
            let(:phrase) { "#{base_phrase}...#{second_phrase}" }
            let(:expected_phrase) { second_phrase }

            it_should_behave_like :finds_the_word_properly
          end

          context "with ending punctuation" do
            let(:phrase) { "#{base_phrase} #{second_phrase}!" }
            let(:expected_phrase) { second_phrase }
            let(:punctuation_after) { "!" }

            it_should_behave_like :finds_the_word_properly
          end
        end
      end
    end
  end
end
