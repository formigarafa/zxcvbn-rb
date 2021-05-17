# frozen_string_literal: true

RSpec.describe Zxcvbn do
  password_list = (<<~PASSWORD_LIST).lines.map(&:strip).reject(&:empty?)
    zxcvbn
    ZXCVBN
    qwER43@!
    Tr0ub4dour&3
    correcthorsebatterystaple
    coRrecth0rseba++ery9.23.2007staple$

    P@ssword
    p@ssword
    p@$$word
    123456
    123456789
    11111111
    zxcvbnm,./
    love88
    angel08
    monkey13
    iloveyou
    woaini
    wang
    johnsonphilosophy
    nosnhoj
    2001
    Johnjohnson
    tianya
    zhang198822
    li4478
    a6a4Aa8a
    b6b4Bb8b
    z6z4Zz8z
    aiIiAaIA
    zxXxZzXZ
    pässwörd
    alpha bravo charlie delta
    a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9
    a b c 1 2 3
    correct-horse-battery-staple
    correct.horse.battery.staple
    correct,horse,battery,staple
    correct~horse~battery~staple
    WhyfaultthebardifhesingstheArgives’harshfate?
    Eupithes’sonAntinousbroketheirsilence
    Athena lavished a marvelous splendor
    buckmulliganstenderchant
    seethenthatyewalkcircumspectly
    LihiandthepeopleofMorianton
    establishedinthecityofZarahemla
    !"£$%^&*()

    D0g..................
    abcdefghijk987654321
    neverforget13/3/1997
    1qaz2wsx3edc

    temppass22
    briansmith
    briansmith4mayor
    password1
    viking
    thx1138
    ScoRpi0ns
    do you know

    ryanhunter2000
    rianhunter2000

    asdfghju7654rewq
    AOEUIDHG&*()LS_

    12345678
    defghi6789

    rosebud
    Rosebud
    ROSEBUD
    rosebuD
    ros3bud99
    r0s3bud99
    R0$38uD99
    abcabcabc123123123abcabcabc
    abcdefghijk
    abcabcabc
    verlineVANDERMARK

    eheuczkqyq
    rWibMFACxAUGZmxhVncy
    Ba9ZyWABu99[BK#6MBgbH88Tofv)vs$w
    philosophy
    13.05.1988
    chenlu0525
    Bilbo Baggin
    rtrtrt
    rtrtrtrt
    rtrtrtrtrt
    rtrtrtrtrtrt
    #{Time.now.year}
  PASSWORD_LIST

  context "when comparing with js library" do
    [:dictionary_match, :reverse_dictionary_match, :l33t_match, :spatial_match, :repeat_match, :sequence_match, :regex_match, :date_match].each do |matcher|
      context "for matcher #{matcher}" do
        password_list.each do |pw|
          it "produces same output for '#{pw}'" do
            js_result = strip_log10 js_matcher(matcher, pw)
            ruby_result = strip_log10 Zxcvbn::Matching.send(matcher, pw)
            expect(ruby_result).to contain_exactly(*js_result)
          end
        end
      end
    end

    context "when running #omnimatch" do
      password_list.each do |pw|
        it "produces same output for '#{pw}'" do
          ruby_result = strip_log10 Zxcvbn::Matching.omnimatch(pw)
          js_result = strip_log10 js_omnimatch(pw)
          expect(ruby_result).to contain_exactly(*js_result)
        end
      end
    end

    context "when running #estimate_guesses" do
      before do
        allow(Zxcvbn::Scoring).to receive(:estimate_guesses).and_wrap_original do |m, *args|
          js_result = js_estimate_guesses(*args)
          ruby_result = m.call(*args)
          expect(ruby_result).to be_within(0.001).of(js_result)
          ruby_result
        end
      end

      password_list.each do |pw|
      # ["2001"].each do |pw|
        it "#estimate_guesses produces same output for '#{pw}'" do
          matches = Zxcvbn::Matching.omnimatch(pw)
          Zxcvbn::Scoring.most_guessable_match_sequence(pw, matches)
        end
      end
    end

    context "when running #most_guessable_match_sequence" do
      password_list.each do |pw|
      # ["2001"].each do |pw|
        it "#most_guessable_match_sequence produces same output for '#{pw}'" do
          matches = Zxcvbn::Matching.omnimatch(pw)
          ruby_result = strip_log10 Zxcvbn::Scoring.most_guessable_match_sequence(pw, matches)
          js_result = strip_log10 js_most_guessable_match_sequence(pw, matches)
          expect(ruby_result).to eq js_result
        end
      end
    end

    it 'nCk' do
      [
        [ 0,  0, 1 ],
        [ 1,  0, 1 ],
        [ 5,  0, 1 ],
        [ 0,  1, 0 ],
        [ 0,  5, 0 ],
        [ 2,  1, 2 ],
        [ 4,  2, 6 ],
        [ 33, 7, 4272048 ]
      ].each do |(n, k, result)|
        expect(Zxcvbn::Scoring.nCk(n, k)).to eq(result)
      end
      n = 49
      k = 12
      expect(Zxcvbn::Scoring.nCk(n, k)).to eq(Zxcvbn::Scoring.nCk(n, n-k))
      expect(Zxcvbn::Scoring.nCk(n, k)).to eq(Zxcvbn::Scoring.nCk(n-1, k-1) + Zxcvbn::Scoring.nCk(n-1, k))
    end

    it "spatial_guesses" do
      match = {
        "token" => 'zxcvbn',
        "graph" => 'qwerty',
        "turns" => 1,
        "shifted_count" => 0,
      }
      base_guesses = Zxcvbn::Scoring::KEYBOARD_STARTING_POSITIONS * Zxcvbn::Scoring::KEYBOARD_AVERAGE_DEGREE * (match["token"].length - 1)
      msg = "with no turns or shifts, guesses is starts * degree * (len-1)"
      expect(Zxcvbn::Scoring.spatial_guesses(match)).to eq(base_guesses), msg

      match.delete "guesses"
      match["token"] = 'ZxCvbn'
      match["shifted_count"] = 2
      shifted_guesses = base_guesses * (Zxcvbn::Scoring.nCk(6, 2) + Zxcvbn::Scoring.nCk(6, 1))
      msg = "guesses is added for shifted keys, similar to capitals in dictionary matching"
      expect(Zxcvbn::Scoring.spatial_guesses(match)).to eq(shifted_guesses), msg

      match.delete "guesses"
      match["token"] = 'ZXCVBN'
      match["shifted_count"] = 6
      shifted_guesses = base_guesses * 2
      msg = "when everything is shifted, guesses are doubled"
      expect(Zxcvbn::Scoring.spatial_guesses(match)).to eq(shifted_guesses), msg

      match = {
        "token" => 'zxcft6yh',
        "graph" => 'qwerty',
        "turns" => 3,
        "shifted_count" => 0
      }
      guesses = 0
      ll = match["token"].length
      s = Zxcvbn::Scoring::KEYBOARD_STARTING_POSITIONS
      d = Zxcvbn::Scoring::KEYBOARD_AVERAGE_DEGREE
      (2..ll).each do |i|
        (1..[match["turns"], i-1].min).each do |j|
          guesses += Zxcvbn::Scoring.nCk(i-1, j-1) * s * (d ** j)
        end
      end
      msg = "spatial guesses accounts for turn positions, directions and starting keys"
      expect(Zxcvbn::Scoring.spatial_guesses(match)).to eq(guesses), msg

      match = {
        "token" => "zxcvbn",
        "graph" => "qwerty",
        "turns" => 1,
        "shifted_count" => 0,
      }
      expect(Zxcvbn::Scoring.spatial_guesses(match)).to eq(2160.0000000000005)
    end

    context "when running #zxcvbn" do
      password_list.each do |pw|
        it "#zxcvbn produces same output for '#{pw}'" do
          ruby_result = strip_log10 Zxcvbn.zxcvbn(pw)
          js_result = strip_log10 js_zxcvbn(pw)
          expect(ruby_result).to eq(js_result)
        end
      end
    end
  end

  it "works with empty string" do
    expect{ Zxcvbn.zxcvbn("") }.not_to raise_error
  end

  it "works with very long pass" do
    pw = "hKmuwA4TkmoSmqTuBX#x%%fscPx?BN^JxylhceDouLFLNRuXX5E$R@8^h%mxpv6F#q6*?52V7cw^QwOC4_7XUXBPp%C9#LTGo-^CcyF*mE2UE^U?gH6Vc3f!Tq6C|KLn%uwqg3q12SrUW@lryJPnUKVfcS0hPJdK-RVDsZab01_ueyz?oWDq2NKo3zbn2la9t=PkMk1L62eV2yqdorG7pLY1pCuDf1gJ=%ASFHP7+taxrI0vH4kvhWfHScdveV@?"
    expect{ Zxcvbn.zxcvbn(pw) }.not_to raise_error
  end
end
