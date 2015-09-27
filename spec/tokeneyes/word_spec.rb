require 'spec_helper'

module Tokeneyes
  RSpec.describe Word do
    let(:text) { Faker::Lorem.word }
    let(:word) { Word.new(text) }

    describe "#ends_sentence?" do
      it "returns true if appropriate" do
        word.ends_sentence = true
        expect(word.ends_sentence?).to be true
      end

      it "returns false if appropriate" do
        word.ends_sentence = false
        expect(word.ends_sentence?).to be false
      end
    end

    describe "#begins_sentence?" do
      it "returns true if appropriate" do
        word.begins_sentence = true
        expect(word.begins_sentence?).to be true
      end

      it "returns false if appropriate" do
        word.begins_sentence = false
        expect(word.begins_sentence?).to be false
      end
    end

    describe "#to_s" do
      it "returns the word" do
        word.begins_sentence = false
        word.ends_sentence = true
        expect(word.to_s).to eq(text)
      end
    end

    describe "#length" do
      it "returns the word's length" do
        expect(word.length).to eq(text.length)
      end
    end
  end
end
