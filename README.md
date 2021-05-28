# Zxcvbn

[![Gem Version](https://badge.fury.io/rb/zxcvbn.svg)](https://badge.fury.io/rb/zxcvbn)
[![Build Status](https://travis-ci.com/formigarafa/zxcvbn-rb.svg?branch=master)](https://travis-ci.com/formigarafa/zxcvbn-rb)

Ruby port of Dropbox's [zxcvbn.js][zxcvbn.js] JavaScript library running completely in Ruby (no need to load execjs or libv8).

The intention is to provide an option 100% Ruby solution with all the same features and same results (or as close to the original JS function as possible).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zxcvbn'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install zxcvbn

## Usage

```
Zxcvbn.zxcvbn("password")
=> {
  "password" => "password",
  "guesses" => 3,
  "guesses_log10" => 0.47712125471966244,
  "sequence" => [
    {
      "pattern" => "dictionary",
      "i" => 0,
      "j" => 7,
      "token" => "password",
      "matched_word" => "password",
      "rank" => 2,
      "dictionary_name" => "passwords",
      "reversed" => false,
      "l33t" => false,
      "base_guesses" => 2,
      "uppercase_variations" => 1,
      "l33t_variations" => 1,
      "guesses" => 2,
      "guesses_log10" => 0.3010299956639812
    }
  ],
  "calc_time" => 1,
  "crack_times_seconds" => {
    "online_throttling_100_per_hour" => 108.0,
    "online_no_throttling_10_per_second" => 0.3,
    "offline_slow_hashing_1e4_per_second" => 0.0003,
    "offline_fast_hashing_1e10_per_second" => 3.0e-10},
  "crack_times_display" => {
    "online_throttling_100_per_hour" => "2 minutes",
    "online_no_throttling_10_per_second" => "less than a second",
    "offline_slow_hashing_1e4_per_second" => "less than a second",
    "offline_fast_hashing_1e10_per_second" => "less than a second"
  },
  "score" => 0,
  "feedback" => {
    "warning" => "This is a top-10 common password",
    "suggestions" => [
      "Add another word or two. Uncommon words are better."
    ]
  }
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/formigarafa/zxcvbn. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/zxcvbn/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Zxcvbn project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/zxcvbn/blob/master/CODE_OF_CONDUCT.md).
