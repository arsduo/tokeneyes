module Tokeneyes
  # Represents a word as read from the stream, with certain useful related metadata.
  class Word
    attr_reader :text
    attr_accessor :punctuation_before, :punctuation_after
    attr_writer :begins_sentence, :ends_sentence

    def initialize(text)
      @text = text
      @begins_sentence = @ends_sentence = false
    end

    def begins_sentence?
      @begins_sentence
    end

    def ends_sentence?
      @ends_sentence
    end

    def to_s
      @text
    end
  end
end
