require "tokeneyes/word_builder"
require "tokeneyes/word"

module Tokeneyes
  # The WordReader class will read a single word from a StringIO, advancing the IO stream until a
  # word and subsequent boundary are reached (or the string runs out). It will return a Word object
  # containing info on the word and its ending (the object receiving this data will be resopnsible
  # for filling in any data about the previous state, if any).
  class WordReader
    attr_reader :text_stream
    def initialize(text_stream)
      @text_stream = text_stream
    end

    def read_word(previous_char = "", word = "")
      current_char = text_stream.readchar
      word_builder = WordBuilder.new(previous_char, current_char, word)
      word += word_builder.character_to_add_to_word

      # if we detect a word boundary but don't actually have a word yet, keep going -- that is,
      # discard leading punctuation not attached to a word (e.g. x,,y or ^,y)
      if text_stream.eof? || (word_builder.word_finished? && word.length > 0)
        build_word(word, word_builder)
      else
        read_word(current_char, word)
      end
    end

    protected

    def build_word(word, word_builder)
      Word.new(word).tap do |word_object|
        # we don't set punctuation before, even if it's at the beginning (e.g. no previous words)
        # -- that will be set based on the punctuation of the previous word in the class that reads
        # in the whole text.
        word_object.punctuation_after = word_builder.punctuation
        word_object.ends_sentence = word_builder.sentence_ended? || text_stream.eof?
      end
    end
  end
end
