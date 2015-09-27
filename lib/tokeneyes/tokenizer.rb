require 'tokeneyes/word_reader'

module Tokeneyes
  class Tokenizer
    attr_reader :text
    def initialize(text)
      @text = text
    end

    def parse_into_words
      extract_words_from_stream until text_stream.eof?
      results
    end

    protected

    def extract_words_from_stream(previous_word = nil)
      unless text_stream.eof?
        word = read_next_word(previous_word)
        results.push(word) if word
        extract_words_from_stream(word)
      end
    end

    def read_next_word(previous_word)
      current_word = word_reader.read_word
      # If we finished the text and just have nonsense afterward (or have nothing in the entire
      # text that's a word), ignore that.
      if current_word.length > 0
        populate_previous_punctuation(previous_word, current_word)
        current_word
      end
    end

    def results
      @results ||= []
    end

    # Various metadata about what preceded a word can (only) be drawn from the previous word.
    def populate_previous_punctuation(previous_word, current_word)
      if !previous_word || previous_word.ends_sentence?
        current_word.begins_sentence = true
      else
        current_word.punctuation_before = previous_word.punctuation_after
      end
    end

    def word_reader
      @word_reader ||= WordReader.new(text_stream)
    end

    def text_stream
      @text_stream ||= StringIO.new(text)
    end
  end
end
