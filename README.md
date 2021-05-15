# Zxcvbn

This is a direct Ruby port of Dropbox's [zxcvbn.js][zxcvbn.js] JavaScript library.
The intention is to provide all the same features and same results as close to the original JS fucntion would do.

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
  :password => "pasword",
  :guesses => 3566,
  :guesses_log10 => 3.5521813388393357,
  :sequence => [
    {
      :pattern => "dictionary",
      :i => 0,
      :j => 6,
      :token => "pasword",
      :matched_word => "pasword",
      :rank => 3565,
      :dictionary_name => "passwords",
      :reversed => false,
      :l33t => false,
      :base_guesses => 3565,
      :uppercase_variations => 1,
      :l33t_variations => 1,
      :guesses => 3565,
      :guesses_log10 => 3.5520595341878844
    }
  ],
  :calc_time => 0,
  :crack_times_seconds => {
    :online_throttling_100_per_hour => 128376.0,
    :online_no_throttling_10_per_second => 356.6,
    :offline_slow_hashing_1e4_per_second => 0.3566,
    :offline_fast_hashing_1e10_per_second => 3.566e-07
  },
  :crack_times_display => {
    :online_throttling_100_per_hour => "1 day",
    :online_no_throttling_10_per_second => "6 minutes",
    :offline_slow_hashing_1e4_per_second => "less than a second",
    :offline_fast_hashing_1e10_per_second => "less than a second"
  },
  :score => 1,
  :feedback =>
  {
    :warning => "This is a very common password",
    :suggestions => ["Add another word or two. Uncommon words are better."]
  }
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/zxcvbn. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/zxcvbn/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Zxcvbn project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/zxcvbn/blob/master/CODE_OF_CONDUCT.md).
