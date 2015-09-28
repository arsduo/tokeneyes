module Tokeneyes
  # Given a word fragment and the next character in the stream, continue building the word until we
  # hit a boundary.
  class WordBuilder
    # We track both the word so far and the previous character (which may be punctuation and not
    # part of the word).
    attr_reader :previous_char, :current_char, :word_so_far
    def initialize(previous, current, word)
      @current_char = current.to_s
      @previous_char = previous.to_s
      @word_so_far = word
    end

    # Definite word elements, those that can repeat as much as they want and always be words:
    # alphanumeric characters (including some European symbols). If anyone has expertise on non-European
    # languages, I would love to add support for other character groups.
    WORD_ELEMENTS = Set.new(
      # Letters
      ("A".."Z").to_a + ("a".."z").to_a +
      # Numbers
      ("0".."9").to_a +
      # A subset of European characters
      ("\u00C0".."\uD7FF").to_a + ("\u00D8".."\u00F6").to_a + ("\u00F8".."\u00FC").to_a +
      # Hashtag, @mention, and email support -- this will need to be made more intelligent later
      ["@", "#"]
    )

    # Defines a word boundary that also ends a unit of text.
    SENTENCE_BOUNDARY = Set.new([".", ";", "?", "!"])
    # Possible word elements, those that mark a word boundary unless they're followed by a word
    # element:
    POSSIBLE_WORD_ELEMENTS = Set.new([".", "'", "-"])
    # We don't track all possible punctuation, just some. (In particular, we don't track those that
    # come in pairs, like parentheses and brackets, etc.)
    # TODO add support for ellipses, interrobang, etc.
    MEANINGFUL_PUNCTUATION = Set.new([".", ",", "-", ";", "!", "?"])
    # Everything else represents a word boundary.

    def word_finished?
      # if the word hasn't actually started, we always continue it until we find something
      return false if word_so_far.length == 0
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
      punctuation_candidate if MEANINGFUL_PUNCTUATION.include?(punctuation_candidate)
    end

    def sentence_ended?
      !!(punctuation && SENTENCE_BOUNDARY.include?(punctuation))
    end

    protected

    # If our last character was a possible word element but this one isn't, we're done.
    def word_did_indeed_terminate_previously?
      previous_character_was_possible_boundary? && !current_char_is_word_element?
    end

    def word_continues?
      current_char_is_word_element? || current_char_is_possible_boundary?
    end

    def current_char_is_word_element?
      WORD_ELEMENTS.include?(current_char)
    end

    def previous_character_was_possible_boundary?
      # it's not a possible word boundary if the word hasn't yet started
      POSSIBLE_WORD_ELEMENTS.include?(previous_char) && word_so_far.length > 0
    end

    def current_char_is_possible_boundary?
      # If the previous character was also a boundary, this one can't be as well -- we've ended the
      # word.
      POSSIBLE_WORD_ELEMENTS.include?(current_char) && !previous_character_was_possible_boundary?
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
