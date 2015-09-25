module Tokeneyes
  class WordBoundarySurveyor
    attr_reader :current_char, :previous_char
    def initialize(previous, current)
      @current_char = current
      @previous_char = previous
    end

    # Definite word elements, those that can repeat as much as they want and always be words:
    # alphanumeric characters (including European symbols). If anyone has expertise on non-European
    # languages, I would love to add support for other character groups.
    WORD_ELEMENTS = /[\w\dÀ-ž]/
    # Defines a word boundary that also ends a unit of text.
    SENTENCE_BOUNDARY = /[\.;\?\!]/
    # Possible word elements, those that mark a word boundary unless they're followed by a word
    # element:
    POSSIBLE_WORD_ELEMENTS = /[\.'\-\#]/
    # We don't track all possible punctuation, just some. (In particular, we don't track those that
    # come in pairs, like parentheses and brackets, etc.)
    MEANINGFUL_PUNCTUATION = /[\.,\-;\!\?]/
    # Everything else represents a word boundary.

    def word_finished?
      word_did_indeed_terminate_previously? || !word_continues?
    end

    def character_to_add_to_word
      if word_continues? && previous_character_was_possible_boundary?
        # If the word does continue after a possible edge, that means that we should add both
        # parts
        "#{previous_char}#{current_char}"
      elsif current_char_is_word_element?
        current_char
      else
        # If the word is over (or hasn't yet begun), we have nothing to add; if it's possibly over, we'll find out next
        # character. (If the string were to end on a possible boundary, that would indicate that
        # it isn't actually part of the word anyway.)
        ""
      end
    end

    # Which punctuation ended the word?
    def punctuation
      return nil unless word_finished?
      punctuation_candidate if punctuation_candidate.match(MEANINGFUL_PUNCTUATION)
    end

    def sentence_ended?
      punctuation && punctuation.match(SENTENCE_BOUNDARY)
    end

    protected

    # If our last character was a possible word element but this one isn't, we're done.
    def word_did_indeed_terminate_previously?
      previous_character_was_possible_boundary? && !current_char_is_word_element?
    end

    def word_continues?
      current_char_is_word_element? || current_char_might_be_a_word_element?
    end

    def current_char_is_word_element?
      current_char.match(WORD_ELEMENTS)
    end

    def previous_character_was_possible_boundary?
      previous_char.match(POSSIBLE_WORD_ELEMENTS)
    end

    def current_char_might_be_a_word_element?
      current_char.match(POSSIBLE_WORD_ELEMENTS)
    end

    def punctuation_candidate
      if previous_character_was_possible_boundary?
        previous_char
      else
        current_char
      end
    end
  end
end
