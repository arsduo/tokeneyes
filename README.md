[![Code Climate](https://codeclimate.com/github/arsduo/tokeneyes/badges/gpa.svg)](https://codeclimate.com/github/arsduo/tokeneyes)
[![Test Coverage](https://codeclimate.com/github/arsduo/tokeneyes/badges/coverage.svg)](https://codeclimate.com/github/arsduo/tokeneyes/coverage)
[![Build Status](https://travis-ci.org/arsduo/tokeneyes.svg)](https://travis-ci.org/arsduo/tokeneyes)

# Tokeneyes

A string tokenizer designed to capture words with associated punctuation and sentence flow
information (e.g. if they start or end a sentence).

### Why write a tokenizer?

As I was writing [markovian](https://github.com/arsduo/markovian), I realized that the Markov text
generator needed significantly more information about the corpus than was possible by simply
calling String#split on the input text. To add punctuation or end sentences properly (rather than
with a series of short, frequent prepositions or pronouns), the gem has to better understand how
words are used in context.

There are a number of excellent tokenizers available, such as the [tokenizer
gem](https://github.com/arbox/tokenizer), [Apache's OpenNLP](http://opennlp.apache.org/index.html),
and the [OpeNER Project](http://www.opener-project.eu/) -- if you're looking to do serious language processing, you should click on one one of those links.

Tokeneyes is a learning exercise; text parsing is a rich, fun, and deceptive
problem -- you can quickly get 80% of the way to proper tokenization, but it's the other 20% of
language use that makes the difference between "amusingly off" and "passes the Turing test". Mine
doesn't and won't, but I've still enjoyed writing it and look forward to refining it further.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tokeneyes'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tokeneyes

## Usage

In a console session, you can run

```ruby
tokenizer = Tokeneyes::Tokenizer.new(text_to_parse)
tokens = tokenizer.parse_into_words
```

This will return an array of
[Tokeneyes::Word](https://github.com/arsduo/tokeneyes/tree/master/lib/tokeneyes/word.rb) objects,
each of which provides the text of the word, punctuation before and after (if applicable) and
whether the word ended or began a sentence (as I have somewhat arbitrarily defined the concept 😁).

## Still to do

There are several significant areas left to do:

* Capture periods at the end of a sentence
* Capture dividing punctuation that occurs after spaces (e.g. -, —, etc.)
* Capture ellipses and other multiple-character punctuation (e.g. ?!, --, etc.)
* Capture URLs as one word

Most of these should be doable by rewriting WordBuilder. Currently, a new WordBuilder is
initialized for each character; if we instead initialize one per word and then pass it each
new character (it then building up the word and setting/clearing punctuation as the word's format
changes), that should allow us to properly handle many of these cases.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/arsduo/tokeneyes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
