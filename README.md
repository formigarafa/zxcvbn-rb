# Zxcvbn

[![Gem Version](https://badge.fury.io/rb/zxcvbn.svg)](https://badge.fury.io/rb/zxcvbn)

Ruby port of Dropbox's [zxcvbn.js](https://github.com/dropbox/zxcvbn) JavaScript library running completely in Ruby (no need to load execjs or libv8).

### Goals:
- Exact same results as [dropbox/zxcvbn.js (Version 4.4.2)](https://github.com/dropbox/zxcvbn). If **result compatibility** is found or made different a major version will be bumped so no one is caught off guard.
- Parity of features to [dropbox/zxcvbn.js (Version 4.4.2)](https://github.com/dropbox/zxcvbn) interface.
- 100% native Ruby solution: **No Javascript Runtime**.

### Compatible with [zxcvbn-js](https://github.com/bitzesty/zxcvbn-js) and [zxcvbn-ruby](https://github.com/envato/zxcvbn-ruby)

This gem include compatibility interfaces so it can be used as a drop-in substitution both of the most popular alternatives `zxcvbn-js` and `zxcvbn-ruby`). Besides `Zxcvbn.zxcvbn` you can just call `Zxcvbn.test` or use `Zxcvbn::Tester.new` the same way as you would if you were using any of them.

|                                    | `zxcvbn-rb`            | `zxcvbn-js`            | `zxcvbn-ruby`          |
|------------------------------------|------------------------|------------------------|------------------------|
| Results match `zxcvbn.js (V4.4.2)` | :white_check_mark: yes | :white_check_mark: yes | :x: no                 |
| Run without Javascript Runtime     | :white_check_mark: yes | :x: no                 | :white_check_mark: yes |
| Interface compatibility with others| :white_check_mark: yes | :x: no                 | :x: no                 |

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

```ruby
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

## Testing Multiple Passwords

The dictionaries used for password strength testing are loaded each request to `Zxcvbn.zxcvbn`. If you you'd prefer to persist the dictionaries in memory (approx 7.2MB RSS) to perform lots of password tests in succession then you can use the `Zxcvbn::Tester` API:

```ruby
tester = Zxcvbn::Tester.new
=> #<Zxcvbn::Tester:0x0000000102498678>

tester.zxcvbn('@lfred2004', ['alfred'])
=> {"password"=>"@lfred2004", "guesses"=>15000, "guesses_log10"=>4.176091259055681, "sequence"=>[{"pattern"=>"dictionary", ... "feedback"=>{"warning"=>"", "suggestions"=>["Add another word or two. Uncommon words are better.", "Predictable substitutions like '@' instead of 'a' don't help very much"]}}

>> tester.zxcvbn('j0hn2025', ['john'])
=> {"password"=>"j0hn2025", "guesses"=>225333.3333333333, "guesses_log10"=>5.352825441221974, "sequence"=>[{"pattern"=>"dictionary", ... "feedback"=>{"warning"=>"Common names and surnames are easy to guess", "suggestions"=>["Add another word or two. Uncommon words are better.", "Predictable substitutions like '@' instead of 'a' don't help very much"]}}
```

### Note about translations (i18n, gettext, etc...)
Check the [wiki](https://github.com/formigarafa/zxcvbn-rb/wiki) for more details on how to handle translations.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/formigarafa/zxcvbn-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/formigarafa/zxcvbn-rb/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Zxcvbn project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/formigarafa/zxcvbn-rb/blob/master/CODE_OF_CONDUCT.md).
