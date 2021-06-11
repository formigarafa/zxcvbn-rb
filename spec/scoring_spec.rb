# frozen_string_literal: true

RSpec.describe "Zxcvbn::Scoring.nck" do
  [
    [0,  0, 1],
    [1,  0, 1],
    [5,  0, 1],
    [0,  1, 0],
    [0,  5, 0],
    [2,  1, 2],
    [4,  2, 6],
    [33, 7, 4_272_048]
  ].each do |n, k, result|
    it "calculates Zxcvbn::Scoring.nck(#{n}, #{k}) == #{result}" do
      expect(Zxcvbn::Scoring.nck(n, k)).to eq(result)
    end
  end

  n = 49
  k = 12
  it "pass mirror identity check" do
    expect(Zxcvbn::Scoring.nck(n, k)).to eq(Zxcvbn::Scoring.nck(n, n - k))
  end

  it "pass pascal's triangle identity check" do
    expect(Zxcvbn::Scoring.nck(n, k)).to eq(Zxcvbn::Scoring.nck(n - 1, k - 1) + Zxcvbn::Scoring.nck(n - 1, k))
  end
end

RSpec.describe "search" do
  m = lambda do |i, j, guesses|
    {
      "i" => i,
      "j" => j,
      "guesses" => guesses
    }
  end
  password = "0123456789"

  # for tests, set additive penalty to zero.
  exclude_additive = true

  describe "returns one bruteforce match given an empty match sequence:" do
    result = Zxcvbn::Scoring.most_guessable_match_sequence password, []
    it "result.length == 1" do
      expect(result["sequence"].length).to eq(1)
    end

    m0 = result["sequence"][0]
    it "match.pattern == 'bruteforce'" do
      expect(m0["pattern"]).to eq("bruteforce")
    end

    it "match.token == #{password}" do
      expect(m0["token"]).to eq(password)
    end

    it "[i, j] == [#{m0["i"]}, #{m0["j"]}]" do
      expect([m0["i"], m0["j"]]).to eq([0, 9])
    end
  end

  describe "returns match + bruteforce when match covers a prefix of password:" do
    matches = [m.call(0, 5, 1)]
    m0, = matches
    result = Zxcvbn::Scoring.most_guessable_match_sequence password, matches, _exclude_additive: exclude_additive
    it "result.match.sequence.length == 2" do
      expect(result["sequence"].length).to eq(2)
    end

    it "first match is the provided match object" do
      expect(result["sequence"][0]).to eq(m0)
    end

    m1 = result["sequence"][1]
    it "second match is bruteforce" do
      expect(m1["pattern"]).to eq("bruteforce")
    end

    it "second match covers full suffix after first match" do
      expect([m1["i"], m1["j"]]).to eq([6, 9])
    end
  end

  describe "returns bruteforce + match when match covers a suffix:" do
    matches = [m.call(3, 9, 1)]
    m1, = matches
    result = Zxcvbn::Scoring.most_guessable_match_sequence password, matches, _exclude_additive: exclude_additive
    it "result.match.sequence.length == 2" do
      expect(result["sequence"].length).to eq(2)
    end

    m0 = result["sequence"][0]
    it "first match is bruteforce" do
      expect(m0["pattern"]).to eq("bruteforce")
    end
    it "first match covers full prefix before second match" do
      expect([m0["i"], m0["j"]]).to eq([0, 2])
    end

    it "second match is the provided match object" do
      expect(result["sequence"][1]).to eq(m1)
    end
  end

  describe "returns bruteforce + match + bruteforce when match covers an infix:" do
    matches = [m.call(1, 8, 1)]
    m1, = matches
    result = Zxcvbn::Scoring.most_guessable_match_sequence password, matches, _exclude_additive: exclude_additive
    it "result.length == 3" do
      expect(result["sequence"].length).to eq(3)
    end

    it "middle match is the provided match object" do
      expect(result["sequence"][1]).to eq(m1)
    end

    m0 = result["sequence"][0]
    m2 = result["sequence"][2]
    it "first match is bruteforce" do
      expect(m0["pattern"]).to eq("bruteforce")
    end

    it "third match is bruteforce" do
      expect(m2["pattern"]).to eq("bruteforce")
    end
    it "first match covers full prefix before second match" do
      expect([m0["i"], m0["j"]]).to eq([0, 0])
    end
    it "third match covers full suffix after second match" do
      expect([m2["i"], m2["j"]]).to eq([9, 9])
    end
  end

  describe "chooses lower-guesses match given two matches of the same span:" do
    let(:matches) { [m.call(0, 9, 1), m.call(0, 9, 2)] }
    let(:m0) { matches[0] }
    let(:m1) { matches[1] }
    let(:result) do
      Zxcvbn::Scoring.most_guessable_match_sequence password, matches, _exclude_additive: exclude_additive
    end

    it "result.length == 1" do
      expect(result["sequence"].length).to eq(1)
    end
    it "result.sequence[0] == m0" do
      expect(result["sequence"][0]).to eq(m0)
    end

    describe "make sure ordering doesn't matter" do
      before { m0["guesses"] = 3 }
      it "result.length == 1" do
        expect(result["sequence"].length).to eq(1)
      end
      it "result.sequence[0] == m1" do
        expect(result["sequence"][0]).to eq(m1)
      end
    end
  end

  describe "when m0 covers m1 and m2," do
    let(:matches) { [m.call(0, 9, 3), m.call(0, 3, 2), m.call(4, 9, 1)] }
    let(:m0) { matches[0] }
    let(:m1) { matches[1] }
    let(:m2) { matches[2] }
    let(:result) do
      Zxcvbn::Scoring.most_guessable_match_sequence password, matches, _exclude_additive: exclude_additive
    end
    describe "choose [m0] when m0 < m1 * m2 * fact(2):" do
      it "total guesses == 3" do
        expect(result["guesses"]).to eq(3)
      end
      it "sequence is [m0]" do
        expect(result["sequence"]).to eq([m0])
      end
    end

    describe "choose [m1, m2] when m0 > m1 * m2 * fact(2):" do
      before { m0["guesses"] = 5 }
      it "total guesses == 4" do
        expect(result["guesses"]).to eq(4)
      end
      it "sequence is [m1, m2]" do
        expect(result["sequence"]).to eq([m1, m2])
      end
    end
  end
end

RSpec.describe "calc_guesses" do
  it "estimate_guesses returns cached guesses when available" do
    match = { "guesses" => 1 }
    expect(Zxcvbn::Scoring.estimate_guesses(match, "")).to eq(1)
  end

  it "estimate_guesses delegates based on pattern" do
    match = {
      "pattern" => "date",
      "token" => "1977",
      "year" => 1977,
      "month" => 7,
      "day" => 14
    }
    expect(Zxcvbn::Scoring.estimate_guesses(match, "1977")).to eq(Zxcvbn::Scoring.date_guesses(match))
  end
end

RSpec.describe "repeat guesses" do
  [
    ["aa",   "a",  2],
    ["999",  "9",  3],
    ["$$$$", "$",  4],
    ["abab", "ab", 2],
    ["batterystaplebatterystaplebatterystaple", "batterystaple", 3]
  ].each do |token, base_token, repeat_count|
    base_guesses = Zxcvbn::Scoring.most_guessable_match_sequence(
      base_token,
      Zxcvbn::Matching.omnimatch(base_token)
    )["guesses"]
    match = {
      "token" => token,
      "base_token" => base_token,
      "base_guesses" => base_guesses,
      "repeat_count" => repeat_count
    }
    expected_guesses = base_guesses * repeat_count
    it "the repeat pattern '#{token}' has guesses of #{expected_guesses}" do
      expect(Zxcvbn::Scoring.repeat_guesses(match)).to eq(expected_guesses)
    end
  end
end

RSpec.describe "sequence guesses" do
  [
    ["ab",   true,  4 * 2],      # obvious start * len-2
    ["XYZ",  true,  26 * 3],     # base26 * len-3
    ["4567", true,  10 * 4],     # base10 * len-4
    ["7654", false, 10 * 4 * 2], # base10 * len 4 * descending
    ["ZYX",  false, 4 * 3 * 2]   # obvious start * len-3 * descending
  ].each do |token, ascending, guesses|
    it "the sequence pattern '#{token}' has guesses of #{guesses}" do
      match = {
        "token" => token,
        "ascending" => ascending
      }
      expect(Zxcvbn::Scoring.sequence_guesses(match)).to eq(guesses)
    end
  end
end

RSpec.describe "regex guesses" do
  it "guesses of 26^7 for 7-char lowercase regex" do
    match = {
      "token" => "aizocdk",
      "regex_name" => "alpha_lower",
      "regex_match" => ["aizocdk"]
    }
    expect(Zxcvbn::Scoring.regex_guesses(match)).to eq(26**7)
  end

  it "guesses of 62^5 for 5-char alphanumeric regex" do
    match = {
      "token" => "ag7C8",
      "regex_name" => "alphanumeric",
      "regex_match" => ["ag7C8"]
    }
    expect(Zxcvbn::Scoring.regex_guesses(match)).to eq((2 * 26 + 10)**5)
  end

  it "guesses of |year - REFERENCE_YEAR| for distant year matches" do
    match = {
      "token" => "1972",
      "regex_name" => "recent_year",
      "regex_match" => ["1972"]
    }
    expect(Zxcvbn::Scoring.regex_guesses(match)).to eq((Zxcvbn::Scoring::REFERENCE_YEAR - 1972).abs)
  end

  it "guesses of MIN_YEAR_SPACE for a year close to REFERENCE_YEAR" do
    match = {
      "token" => "2005",
      "regex_name" => "recent_year",
      "regex_match" => ["2005"]
    }
    expect(Zxcvbn::Scoring.regex_guesses(match)).to eq(Zxcvbn::Scoring::MIN_YEAR_SPACE)
  end
end

RSpec.describe "date guesses" do
  it "guesses for '1123' is 365 * distance_from_ref_year" do
    match = {
      "token" => "1123",
      "separator" => "",
      "has_full_year" => false,
      "year" => 1923,
      "month" => 1,
      "day" => 1
    }
    expect(Zxcvbn::Scoring.date_guesses(match)).to eq(365 * (Zxcvbn::Scoring::REFERENCE_YEAR - match["year"]).abs)
  end

  it "recent years assume MIN_YEAR_SPACE. extra guesses are added for separators." do
    match = {
      "token" => "1/1/2010",
      "separator" => "/",
      "has_full_year" => true,
      "year" => 2010,
      "month" => 1,
      "day" => 1
    }
    expect(Zxcvbn::Scoring.date_guesses(match)).to eq(365 * Zxcvbn::Scoring::MIN_YEAR_SPACE * 4)
  end
end

RSpec.describe "spatial guesses" do
  match = {
    "token" => "zxcvbn",
    "graph" => "qwerty",
    "turns" => 1,
    "shifted_count" => 0
  }

  base_guesses = (
    Zxcvbn::Scoring::KEYBOARD_STARTING_POSITIONS *
    Zxcvbn::Scoring::KEYBOARD_AVERAGE_DEGREE *
    # - 1 term because: not counting spatial patterns of length 1
    # eg for length==6, multiplier is 5 for needing to try len2,len3,..,len6
    (match["token"].length - 1)
  )

  it "with no turns or shifts, guesses is starts * degree * (len-1)" do
    expect(Zxcvbn::Scoring.spatial_guesses(match)).to eq(base_guesses)
  end

  it "guesses is added for shifted keys, similar to capitals in dictionary matching" do
    match["guesses"] = nil
    match["token"] = "ZxCvbn"
    match["shifted_count"] = 2
    shifted_guesses = base_guesses * (Zxcvbn::Scoring.nck(6, 2) + Zxcvbn::Scoring.nck(6, 1))
    expect(Zxcvbn::Scoring.spatial_guesses(match)).to eq(shifted_guesses)
  end

  it "when everything is shifted, guesses are doubled" do
    match["guesses"] = nil
    match["token"] = "ZXCVBN"
    match["shifted_count"] = 6
    shifted_guesses = base_guesses * 2
    expect(Zxcvbn::Scoring.spatial_guesses(match)).to eq(shifted_guesses)
  end

  it "spatial guesses accounts for turn positions, directions and starting keys" do
    match = {
      "token" => "zxcft6yh",
      "graph" => "qwerty",
      "turns" => 3,
      "shifted_count" => 0
    }
    guesses = 0
    L = match["token"].length
    s = Zxcvbn::Scoring::KEYBOARD_STARTING_POSITIONS
    d = Zxcvbn::Scoring::KEYBOARD_AVERAGE_DEGREE
    (2..L).each do |i|
      (1..[match["turns"], i - 1].min).each do |j|
        guesses += Zxcvbn::Scoring.nck(i - 1, j - 1) * s * (d**j)
      end
    end
    expect(Zxcvbn::Scoring.spatial_guesses(match)).to eq(guesses)
  end
end

RSpec.describe "dictionary_guesses" do
  it "base guesses == the rank" do
    match = {
      "token" => "aaaaa",
      "rank" => 32
    }
    expect(Zxcvbn::Scoring.dictionary_guesses(match)).to eq(32)
  end

  it "extra guesses are added for capitalization" do
    match = {
      "token" => "AAAaaa",
      "rank" => 32
    }
    expect(Zxcvbn::Scoring.dictionary_guesses(match)).to eq(32 * Zxcvbn::Scoring.uppercase_variations(match))
  end

  it "guesses are doubled when word is reversed" do
    match = {
      "token" => "aaa",
      "rank" => 32,
      "reversed" => true
    }
    expect(Zxcvbn::Scoring.dictionary_guesses(match)).to eq(32 * 2)
  end

  it "extra guesses are added for common l33t substitutions" do
    match = {
      "token" => "aaa@@@",
      "rank" => 32,
      "l33t" => true,
      "sub" => { "@" => "a" }
    }
    expect(Zxcvbn::Scoring.dictionary_guesses(match)).to eq(32 * Zxcvbn::Scoring.l33t_variations(match))
  end

  it "extra guesses are added for both capitalization and common l33t substitutions" do
    match = {
      "token" => "AaA@@@",
      "rank" => 32,
      "l33t" => true,
      "sub" => { "@" => "a" }
    }
    expected = 32 * Zxcvbn::Scoring.l33t_variations(match) * Zxcvbn::Scoring.uppercase_variations(match)
    expect(Zxcvbn::Scoring.dictionary_guesses(match)).to eq(expected)
  end
end

RSpec.describe "uppercase variants" do
  [
    ["", 1],
    ["a", 1],
    ["A", 2],
    ["abcdef", 1],
    ["Abcdef", 2],
    ["abcdeF", 2],
    ["ABCDEF", 2],
    ["aBcdef", Zxcvbn::Scoring.nck(6, 1)],
    ["aBcDef", Zxcvbn::Scoring.nck(6, 1) + Zxcvbn::Scoring.nck(6, 2)],
    ["ABCDEf", Zxcvbn::Scoring.nck(6, 1)],
    ["aBCDEf", Zxcvbn::Scoring.nck(6, 1) + Zxcvbn::Scoring.nck(6, 2)],
    ["ABCdef", Zxcvbn::Scoring.nck(6, 1) + Zxcvbn::Scoring.nck(6, 2) + Zxcvbn::Scoring.nck(6, 3)]
  ].each do |word, variants|
    it "guess multiplier of #{word} is #{variants}" do
      expect(Zxcvbn::Scoring.uppercase_variations("token" => word)).to eq(variants)
    end
  end
end

RSpec.describe "l33t variants" do
  it "1 variant for non-l33t matches" do
    match = { "l33t" => false }
    expect(Zxcvbn::Scoring.l33t_variations(match)).to eq(1)
  end

  [
    ["",  1, {}],
    ["a", 1, {}],
    ["4", 2, { "4" => "a" }],
    ["4pple", 2, { "4" => "a" }],
    ["abcet", 1, {}],
    ["4bcet", 2, { "4" => "a" }],
    ["a8cet", 2, { "8" => "b" }],
    ["abce+", 2, { "+" => "t" }],
    ["48cet", 4, { "4" => "a", "8" => "b" }],
    ["a4a4aa",  Zxcvbn::Scoring.nck(6, 2) + Zxcvbn::Scoring.nck(6, 1), { "4" => "a" }],
    ["4a4a44",  Zxcvbn::Scoring.nck(6, 2) + Zxcvbn::Scoring.nck(6, 1), { "4" => "a" }],
    ["a44att+", (Zxcvbn::Scoring.nck(4, 2) + Zxcvbn::Scoring.nck(4, 1)) * Zxcvbn::Scoring.nck(3, 1),
     { "4" => "a", "+" => "t" }]
  ].each do |word, variants, sub|
    it "extra l33t guesses of #{word} is #{variants}" do
      match = {
        "token" => word,
        "sub" => sub,
        "l33t" => !sub.empty?
      }
      expect(Zxcvbn::Scoring.l33t_variations(match)).to eq(variants)
    end
  end

  it "capitalization doesn't affect extra l33t guesses calc" do
    match = {
      "token" => "Aa44aA",
      "l33t" => true,
      "sub" => { "4" => "a" }
    }

    variants = Zxcvbn::Scoring.nck(6, 2) + Zxcvbn::Scoring.nck(6, 1)
    expect(Zxcvbn::Scoring.l33t_variations(match)).to eq(variants)
  end
end
