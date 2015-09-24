module Tokeneyes
  # Represents a word as read from the stream, with certain useful related metadata.
  class Word
    attr_reader :text
    attr_accessor :punctuation_before, :punctuation_after
    attr_writer :begins_sentence, :ends_sentence

    def initialize(text)
      @text = text
    end

    def begins_sentence?
      @begins_sentence
    end

    def ends_sentence?
      @ends_sentence
    end
  end
end
