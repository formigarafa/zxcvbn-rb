# frozen_string_literal: true

# takes a pattern and list of prefixes/suffixes
# returns a bunch of variants of that pattern embedded
# with each possible prefix/suffix combination, including no prefix/suffix
# returns a list of triplets [variant, i, j] where [i,j] is the start/end of the pattern, inclusive
def genpws(pattern, prefixes, suffixes)
  prefixes = prefixes.dup
  suffixes = suffixes.dup
  [prefixes, suffixes].each do |lst|
    lst.unshift "" if !lst.include?("")
  end
  result = []
  prefixes.each do |prefix|
    suffixes.each do |suffix|
      i = prefix.length
      j = prefix.length + pattern.length - 1
      result.push [prefix + pattern + suffix, i, j]
    end
  end
  result
end

def check_matches(prefix, rspec_it, matches, pattern_names, patterns, ijs, props)
  if pattern_names.is_a? String
    # shortcut: if checking for a list of the same type of patterns,
    # allow passing a string 'pat' instead of array ['pat', 'pat', ...]
    pattern_names = Array.new(patterns.length, pattern_names)
  end

  is_equal_len_args = pattern_names.length == patterns.length && pattern_names.length == ijs.length
  props.each do |_prop, lst|
    # props is structured as: keys that points to list of values
    is_equal_len_args &&= (lst.length == patterns.length)
  end

  raise "unequal argument lists to check_matches" if !is_equal_len_args

  rspec_it.call("#{prefix}: matches.length == #{patterns.length}") do
    expect(matches.length).to eq(patterns.length)
  end

  (0...patterns.length).each do |k|
    match = matches[k]
    pattern_name = pattern_names[k]
    pattern = patterns[k]
    i, j = ijs[k]
    rspec_it.call("#{prefix}: matches[#{k}].pattern == '#{pattern_name}'") do
      expect(match["pattern"]).to eq(pattern_name)
    end

    rspec_it.call("#{prefix}: matches[#{k}] should have [i, j] of [#{i}, #{j}]") do
      expect([match["i"], match["j"]]).to eq([i, j])
    end

    rspec_it.call("#{prefix}: matches[#{k}].token == '#{pattern}'") do
      expect(match["token"]).to eq(pattern)
    end

    props.each do |prop_name, prop_list|
      prop_msg = prop_list[k]
      prop_msg = "'#{prop_msg}'" if prop_msg.is_a?(String)
      rspec_it.call("#{prefix}: matches[#{k}].#{prop_name} == #{prop_msg}") do
        expect(match[prop_name]).to eq(prop_list[k])
      end
    end
  end
end

RSpec.describe "matching utils" do
  describe "#translate" do
    chr_map = { "a" => "A", "b" => "B" }
    [
      ["a",    chr_map, "A"],
      ["c",    chr_map, "c"],
      ["ab",   chr_map, "AB"],
      ["abc",  chr_map, "ABc"],
      ["aa",   chr_map, "AA"],
      ["abab", chr_map, "ABAB"],
      ["",     chr_map, ""],
      ["",     {},      ""],
      ["abc",  {},      "abc"]
    ].each do |string, map, result|
      it "translates '#{string}' to '#{result}' with provided charmap" do
        expect(Zxcvbn::Matching.translate(string, map)).to eq result
      end
    end
  end

  describe "#sorted" do
    it "leaves an empty list untouched" do
      expect(Zxcvbn::Matching.sorted([])).to eq []
    end

    it "sorts matches on primary index i and secondary j" do
      m1 = { "i" => 5, "j" => 5 }
      m2 = { "i" => 6, "j" => 7 }
      m3 = { "i" => 2, "j" => 5 }
      m4 = { "i" => 0, "j" => 0 }
      m5 = { "i" => 2, "j" => 3 }
      m6 = { "i" => 0, "j" => 3 }
      expect(Zxcvbn::Matching.sorted([m1, m2, m3, m4, m5, m6])).to eq [m4, m6, m5, m3, m1, m2]
    end
  end
end

RSpec.describe "dictionary matching" do
  test_dicts = {
    "d1" => {
      "motherboard" => 1,
      "mother" => 2,
      "board" => 3,
      "abcd" => 4,
      "cdef" => 5
    },
    "d2" => {
      "z" => 1,
      "8" => 2,
      "99" => 3,
      "$" => 4,
      "asdf1234&*" => 5
    }
  }

  dm = ->(pw) { Zxcvbn::Matching.dictionary_match(pw, {}, test_dicts) }

  matches = dm.call("motherboard")
  patterns = ["mother", "motherboard", "board"]
  msg = "matches words that contain other words"
  check_matches(
    msg,
    method(:it),
    matches,
    "dictionary",
    patterns,
    [[0, 5], [0, 10], [6, 10]],
    {
      "matched_word" => ["mother", "motherboard", "board"],
      "rank" => [2, 1, 3],
      "dictionary_name" => ["d1", "d1", "d1"]
    }
  )

  matches = dm.call("abcdef")
  patterns = ["abcd", "cdef"]
  msg = "matches multiple words when they overlap"
  check_matches(
    msg,
    method(:it),
    matches,
    "dictionary",
    patterns,
    [[0, 3], [2, 5]],
    {
      "matched_word" => ["abcd", "cdef"],
      "rank" => [4, 5],
      "dictionary_name" => ["d1", "d1"]
    }
  )

  matches = dm.call("BoaRdZ")
  patterns = ["BoaRd", "Z"]
  msg = "ignores uppercasing"
  check_matches(
    msg,
    method(:it),
    matches,
    "dictionary",
    patterns,
    [[0, 4], [5, 5]],
    {
      "matched_word" => ["board", "z"],
      "rank" => [3, 1],
      "dictionary_name" => ["d1", "d2"]
    }
  )

  prefixes = ["q", "%%"]
  suffixes = ["%", "qq"]
  a_word = "asdf1234&*"
  genpws(a_word, prefixes, suffixes).each do |password, i, j|
    matches = dm.call(password)
    msg = "identifies words surrounded by non-words"
    check_matches(
      msg,
      method(:it),
      matches,
      "dictionary",
      [a_word], [[i, j]],
      {
        "matched_word" => [a_word],
        "rank" => [5],
        "dictionary_name" => ["d2"]
      }
    )
  end

  test_dicts.each do |name, dict|
    dict.each do |word, rank|
      next if word == "motherboard" # skip words that contain others

      matches = dm.call(word)
      msg = "matches against all words in provided dictionaries"
      check_matches(
        msg,
        method(:it),
        matches,
        "dictionary",
        [word],
        [[0, word.length - 1]],
        {
          "matched_word" => [word],
          "rank" => [rank],
          "dictionary_name" => [name]
        }
      )
    end
  end

  # test the default dictionaries
  matches = Zxcvbn::Matching.dictionary_match("wow", {})
  patterns = ["wow"]
  ijs = [[0, 2]]
  msg = "default dictionaries"
  check_matches(
    msg,
    method(:it),
    matches,
    "dictionary",
    patterns,
    ijs,
    {
      "matched_word" => patterns,
      "rank" => [322],
      "dictionary_name" => ["us_tv_and_film"]
    }
  )

  user_dict = Zxcvbn::Matching.build_user_input_dictionary(["foo", "bar"])
  matches = Zxcvbn::Matching.dictionary_match("foobar", user_dict)
  matches = matches.select { |match| match["dictionary_name"] == "user_inputs" }
  msg = "matches with provided user input dictionary"
  check_matches(
    msg,
    method(:it),
    matches,
    "dictionary",
    ["foo", "bar"],
    [[0, 2], [3, 5]],
    {
      "matched_word" => ["foo", "bar"],
      "rank" => [1, 2]
    }
  )
end

RSpec.describe "reverse dictionary matching" do
  test_dicts = {
    "d1" => {
      "123" => 1,
      "321" => 2,
      "456" => 3,
      "654" => 4
    }
  }
  password = "0123456789"
  matches = Zxcvbn::Matching.reverse_dictionary_match(password, {}, test_dicts)
  msg = "matches against reversed words"
  check_matches(
    msg,
    method(:it),
    matches,
    "dictionary",
    ["123", "456"],
    [[1, 3], [4, 6]],
    {
      "matched_word" => ["321", "654"],
      "reversed" => [true, true],
      "dictionary_name" => ["d1", "d1"],
      "rank" => [2, 4]
    }
  )
end

RSpec.describe "l33t matching" do
  test_table = {
    "a" => ["4", "@"],
    "c" => ["(", "{", "[", "<"],
    "g" => ["6", "9"],
    "o" => ["0"]
  }

  [
    ["", {}],
    ['abcdefgo123578!#$&*)]}>', {}],
    ["a",     {}],
    ["4",     { "a" => ["4"] }],
    ["4@",    { "a" => ["4", "@"] }],
    ["4({60", { "a" => ["4"], "c" => ["(", "{"], "g" => ["6"], "o" => ["0"] }]
  ].each do |pw, expected|
    it "reduces l33t table to only the substitutions that a password might be employing" do
      expect(Zxcvbn::Matching.relevant_l33t_subtable(pw, test_table)).to eq(expected)
    end
  end

  [
    [{}, [{}]],
    [{ "a" => ["@"] }, [{ "@" => "a" }]],
    [{ "a" => ["@", "4"] },                [{ "@" => "a" }, { "4" => "a" }]],
    [{ "a" => ["@", "4"], "c" => ["("] },  [{ "@" => "a", "(" => "c" }, { "4" => "a", "(" => "c" }]]
  ].each do |table, subs|
    it "enumerates the different sets of l33t substitutions a password might be using" do
      expect(Zxcvbn::Matching.enumerate_l33t_subs(table)).to eq(subs)
    end
  end

  dicts = {
    "words" => {
      "aac" => 1,
      "password" => 3,
      "paassword" => 4,
      "asdf0" => 5
    },
    "words2" => {
      "cgo" => 1
    }
  }

  lm = ->(pw) { Zxcvbn::Matching.l33t_match(pw, {}, dicts, test_table) }

  it "doesn't match ''" do
    expect(lm.call("")).to eq([])
  end

  it "doesn't match pure dictionary words" do
    expect(lm.call("password")).to eq([])
  end

  [
    ["p4ssword",    "p4ssword", "password", "words",  3, [0, 7],  { "4" => "a" }],
    ["p@ssw0rd",    "p@ssw0rd", "password", "words",  3, [0, 7],  { "@" => "a", "0" => "o" }],
    ["aSdfO{G0asDfO", "{G0",    "cgo",      "words2", 1, [5, 7], { "{" => "c", "0" => "o" }]
  ].each do |password, pattern, word, dictionary_name, rank, ij, sub|
    msg = "matches against common l33t substitutions"
    check_matches(
      msg,
      method(:it),
      lm.call(password),
      "dictionary",
      [pattern],
      [ij],
      {
        "l33t" => [true],
        "sub" => [sub],
        "matched_word" => [word],
        "rank" => [rank],
        "dictionary_name" => [dictionary_name]
      }
    )
  end

  matches = lm.call("@a(go{G0")
  msg = "matches against overlapping l33t patterns"
  check_matches(
    msg,
    method(:it),
    matches,
    "dictionary",
    ["@a(", "(go", "{G0"],
    [[0, 2], [2, 4], [5, 7]],
    {
      "l33t" => [true, true, true],
      "sub" => [{ "@" => "a", "(" => "c" }, { "(" => "c" }, { "{" => "c", "0" => "o" }],
      "matched_word" => ["aac", "cgo", "cgo"],
      "rank" => [1, 1, 1],
      "dictionary_name" => ["words", "words2", "words2"]
    }
  )

  it "doesn't match when multiple l33t substitutions are needed for the same letter" do
    expect(lm.call("p4@ssword")).to eq([])
  end

  it "doesn't match single-character l33ted words" do
    matches = Zxcvbn::Matching.l33t_match("4 1 @", {})
    expect(matches).to eq([])
  end

  # known issue: subsets of substitutions aren't tried.
  # for long inputs, trying every subset of every possible substitution could quickly get large,
  # but there might be a performant way to fix.
  # (so in this example: {'4': a, '0': 'o'} is detected as a possible sub,
  # but the subset {'4': 'a'} isn't tried, missing the match for asdf0.)
  # TODO: consider partially fixing by trying all subsets of size 1 and maybe 2
  it "doesn't match with subsets of possible l33t substitutions" do
    expect(lm.call("4sdf0")).to eq([])
  end
end

RSpec.describe "spatial matching" do
  ["", "/", "qw", "*/"].each do |password|
    it "doesn't match 1- and 2-character spatial patterns" do
      expect(Zxcvbn::Matching.spatial_match(password)).to eq([])
    end
  end

  # for testing, make a subgraph that contains a single keyboard
  _graphs = { "qwerty" => Zxcvbn::ADJACENCY_GRAPHS["qwerty"] }
  a_pattern = "6tfGHJ"
  matches = Zxcvbn::Matching.spatial_match "rz!#{a_pattern}%z", _graphs
  msg = "matches against spatial patterns surrounded by non-spatial patterns"
  check_matches(
    msg,
    method(:it),
    matches,
    "spatial",
    [a_pattern],
    [[3, 3 + a_pattern.length - 1]],
    {
      "graph" => ["qwerty"],
      "turns" => [2],
      "shifted_count" => [3]
    }
  )

  [
    ["12345",        "qwerty",     1, 0],
    ["@WSX",         "qwerty",     1, 4],
    ["6tfGHJ",       "qwerty",     2, 3],
    ["hGFd",         "qwerty",     1, 2],
    ["/;p09876yhn",  "qwerty",     3, 0],
    ["Xdr%",         "qwerty",     1, 2],
    ["159-",         "keypad",     1, 0],
    ["*84",          "keypad",     1, 0],
    ["/8520",        "keypad",     1, 0],
    ["369",          "keypad",     1, 0],
    ["/963.",        "mac_keypad", 1, 0],
    ["*-632.0214",   "mac_keypad", 9, 0],
    ["aoEP%yIxkjq:", "dvorak",     4, 5],
    [";qoaOQ:Aoq;a", "dvorak", 11, 4]
  ].each do |pattern, keyboard, turns, shifts|
    _graphs = {}
    _graphs[keyboard] = Zxcvbn::ADJACENCY_GRAPHS[keyboard]
    matches = Zxcvbn::Matching.spatial_match pattern, _graphs
    msg = "matches '#{pattern}' as a #{keyboard} pattern"
    check_matches(
      msg,
      method(:it),
      matches,
      "spatial",
      [pattern],
      [[0, pattern.length - 1]],
      {
        "graph" => [keyboard],
        "turns" => [turns],
        "shifted_count" => [shifts]
      }
    )
  end
end

RSpec.describe "sequence matching" do
  ["", "a", "1"].each do |password|
    it "doesn't match length-#{password.length} sequences" do
      expect(Zxcvbn::Matching.sequence_match(password)).to eq([])
    end
  end

  matches = Zxcvbn::Matching.sequence_match "abcbabc"
  msg = "matches overlapping patterns"
  check_matches(
    msg,
    method(:it),
    matches,
    "sequence",
    ["abc", "cba", "abc"],
    [[0, 2], [2, 4], [4, 6]],
    { "ascending" => [true, false, true] }
  )

  prefixes = ["!", "22"]
  suffixes = ["!", "22"]
  a_pattern = "jihg"
  genpws(a_pattern, prefixes, suffixes).each do |password, i, j|
    matches = Zxcvbn::Matching.sequence_match password
    msg = "matches embedded sequence patterns #{password}"
    check_matches(
      msg,
      method(:it),
      matches,
      "sequence",
      [a_pattern],
      [[i, j]],
      {
        "sequence_name" => ["lower"],
        "ascending" => [false]
      }
    )
  end

  [
    ["ABC",   "upper",  true],
    ["CBA",   "upper",  false],
    ["PQR",   "upper",  true],
    ["RQP",   "upper",  false],
    ["XYZ",   "upper",  true],
    ["ZYX",   "upper",  false],
    ["abcd",  "lower",  true],
    ["dcba",  "lower",  false],
    ["jihg",  "lower",  false],
    ["wxyz",  "lower",  true],
    ["zxvt",  "lower",  false],
    ["0369", "digits", true],
    ["97531", "digits", false]
  ].each do |pattern, name, is_ascending|
    matches = Zxcvbn::Matching.sequence_match pattern
    msg = "matches '#{pattern}' as a '#{name}' sequence"
    check_matches(
      msg,
      method(:it),
      matches,
      "sequence",
      [pattern],
      [[0, pattern.length - 1]],
      {
        "sequence_name" => [name],
        "ascending" => [is_ascending]
      }
    )
  end
end

RSpec.describe "repeat matching" do
  ["", "#"].each do |password|
    it "doesn't match length-#{password.length} repeat patterns" do
      expect(Zxcvbn::Matching.repeat_match(password, {})).to eq([])
    end
  end

  # test single-character repeats
  prefixes = ["@", "y4@"]
  suffixes = ["u", "u%7"]
  pattern = "&&&&&"
  genpws(pattern, prefixes, suffixes).each do |password, i, j|
    matches = Zxcvbn::Matching.repeat_match(password, {})
    msg = "matches embedded repeat patterns"
    check_matches(
      msg,
      method(:it),
      matches,
      "repeat",
      [pattern],
      [[i, j]],
      { "base_token" => ["&"] }
    )
  end

  [3, 12].each do |length|
    ["a", "Z", "4", "&"].each do |chr|
      pattern = chr * length
      matches = Zxcvbn::Matching.repeat_match(pattern, {})
      msg = "matches repeats with base character '#{chr}'"
      check_matches(
        msg,
        method(:it),
        matches,
        "repeat",
        [pattern],
        [[0, pattern.length - 1]],
        { "base_token" => [chr] }
      )
    end
  end

  matches = Zxcvbn::Matching.repeat_match("BBB1111aaaaa@@@@@@", {})
  patterns = ["BBB", "1111", "aaaaa", "@@@@@@"]
  msg = "matches multiple adjacent repeats"
  check_matches(
    msg,
    method(:it),
    matches,
    "repeat",
    patterns,
    [[0, 2], [3, 6], [7, 11], [12, 17]],
    { "base_token" => ["B", "1", "a", "@"] }
  )

  matches = Zxcvbn::Matching.repeat_match("2818BBBbzsdf1111@*&@!aaaaaEUDA@@@@@@1729", {})
  msg = "matches multiple repeats with non-repeats in-between"
  check_matches(
    msg,
    method(:it),
    matches,
    "repeat",
    patterns,
    [[4, 6], [12, 15], [21, 25], [30, 35]],
    { "base_token" => ["B", "1", "a", "@"] }
  )

  # test multi-character repeats
  pattern = "abab"
  matches = Zxcvbn::Matching.repeat_match(pattern, {})
  msg = "matches multi-character repeat pattern"
  check_matches(
    msg,
    method(:it),
    matches,
    "repeat",
    [pattern],
    [[0, pattern.length - 1]],
    { "base_token" => ["ab"] }
  )

  pattern = "aabaab"
  matches = Zxcvbn::Matching.repeat_match(pattern, {})
  msg = "matches aabaab as a repeat instead of the aa prefix"
  check_matches(
    msg,
    method(:it),
    matches,
    "repeat",
    [pattern],
    [[0, pattern.length - 1]],
    { "base_token" => ["aab"] }
  )

  pattern = "abababab"
  matches = Zxcvbn::Matching.repeat_match(pattern, {})
  msg = "identifies ab as repeat string, even though abab is also repeated"
  check_matches(
    msg,
    method(:it),
    matches,
    "repeat",
    [pattern],
    [[0, pattern.length - 1]],
    { "base_token" => ["ab"] }
  )
end

RSpec.describe "regex matching" do
  [
    ["1922", "recent_year"],
    ["2017", "recent_year"]
  ].each do |pattern, name|
    matches = Zxcvbn::Matching.regex_match pattern
    msg = "matches #{pattern} as a #{name} pattern"
    check_matches(
      msg,
      method(:it),
      matches,
      "regex",
      [pattern],
      [[0, pattern.length - 1]],
      { "regex_name" => [name] }
    )
  end
end

RSpec.describe "date matching" do
  ["", " ", "-", "/", "\\", "_", "."].each do |sep|
    password = "13#{sep}2#{sep}1921"
    matches = Zxcvbn::Matching.date_match password
    msg = "matches dates that use '#{sep}' as a separator"
    check_matches(
      msg,
      method(:it),
      matches,
      "date",
      [password],
      [[0, password.length - 1]],
      {
        "separator" => [sep],
        "year" => [1921],
        "month" => [2],
        "day" => [13]
      }
    )
  end

  ["mdy", "dmy", "ymd", "ydm"].each do |order|
    d = 8
    m = 8
    y = 88
    password = order.sub("y", y.to_s).sub("m", m.to_s).sub("d", d.to_s)
    matches = Zxcvbn::Matching.date_match password
    msg = "matches dates with '#{order}' format"
    check_matches(
      msg,
      method(:it),
      matches,
      "date",
      [password],
      [[0, password.length - 1]],
      {
        "separator" => [""],
        "year" => [1988],
        "month" => [8],
        "day" => [8]
      }
    )
  end

  password1 = "111504"
  matches = Zxcvbn::Matching.date_match password1
  msg = "matches the date with year closest to REFERENCE_YEAR when ambiguous"
  check_matches(
    msg,
    method(:it),
    matches,
    "date",
    [password1],
    [[0, password1.length - 1]],
    {
      "separator" => [""],
      "year" => [2004], # picks '04' -> 2004 as year, not '1504'
      "month" => [11],
      "day" => [15]
    }
  )

  [
    [1,  1,  1999],
    [11, 8,  2000],
    [9,  12, 2005],
    [22, 11, 1551]
  ].each do |day, month, year|
    password = "#{year}#{month}#{day}"
    matches = Zxcvbn::Matching.date_match password
    msg = "matches #{password}"
    check_matches(
      msg,
      method(:it),
      matches,
      "date",
      [password],
      [[0, password.length - 1]],
      {
        "separator" => [""],
        "year" => [year]
      }
    )
    password = "#{year}.#{month}.#{day}"
    matches = Zxcvbn::Matching.date_match password
    msg = "matches #{password}"
    check_matches(
      msg,
      method(:it),
      matches,
      "date",
      [password],
      [[0, password.length - 1]],
      {
        "separator" => ["."],
        "year" => [year]
      }
    )
  end

  password2 = "02/02/02"
  matches = Zxcvbn::Matching.date_match password2
  msg = "matches zero-padded dates"
  check_matches(
    msg,
    method(:it),
    matches,
    "date",
    [password2],
    [[0, password2.length - 1]],
    {
      "separator" => ["/"],
      "year" => [2002],
      "month" => [2],
      "day" => [2]
    }
  )

  prefixes = ["a", "ab"]
  suffixes = ["!"]
  pattern = "1/1/91"
  genpws(pattern, prefixes, suffixes).each do |password, i, j|
    matches = Zxcvbn::Matching.date_match password
    msg = "matches embedded dates"
    check_matches(
      msg,
      method(:it),
      matches,
      "date",
      [pattern],
      [[i, j]],
      {
        "year" => [1991],
        "month" => [1],
        "day" => [1]
      }
    )
  end

  matches = Zxcvbn::Matching.date_match "12/20/1991.12.20"
  msg = "matches overlapping dates"
  check_matches(
    msg,
    method(:it),
    matches,
    "date",
    ["12/20/1991", "1991.12.20"],
    [[0, 9], [6, 15]],
    {
      "separator" => ["/", "."],
      "year" => [1991, 1991],
      "month" => [12, 12],
      "day" => [20, 20]
    }
  )

  matches = Zxcvbn::Matching.date_match "912/20/919"
  msg = "matches dates padded by non-ambiguous digits"
  check_matches(
    msg,
    method(:it),
    matches,
    "date",
    ["12/20/91"],
    [[1, 8]],
    {
      "separator" => ["/"],
      "year" => [1991],
      "month" => [12],
      "day" => [20]
    }
  )
end

RSpec.describe "omnimatch" do
  it "doesn't match ''" do
    expect(Zxcvbn::Matching.omnimatch("", [])).to eq([])
  end

  password = "r0sebudmaelstrom11/20/91aaaa"
  matches = Zxcvbn::Matching.omnimatch(password, [])
  [
    ["dictionary",  [0, 6]],
    ["dictionary",  [7, 15]],
    ["date",        [16, 23]],
    ["repeat",      [24, 27]]
  ].each do |pattern_name, (i, j)|
    it "matches a #{pattern_name} pattern at [#{i}, #{j}] for #{password}" do
      included = false
      matches.each do |match|
        included = true if (match["i"] == i) && (match["j"] == j) && (match["pattern"] == pattern_name)
      end
      expect(included).to eq(true)
    end
  end
end
