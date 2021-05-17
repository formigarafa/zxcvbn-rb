# frozen_string_literal: true

RSpec.describe Zxcvbn do
  # LihiandthepeopleofMorianton
  # establishedinthecityofZarahemla
  password_list = <<~PASSWORD_LIST.lines.map(&:strip).reject(&:empty?)
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
    defd12a3f84ff98ae39c9a1dbf31b4bbbfcc189051bff922bb6ffd01360dce24
    5372fb692cbd0e9d7e9d54680bd0a5e34b9acb1ca036865e813a8646eea8b4fe
  PASSWORD_LIST

  context "when comparing with js library" do
    [
      :dictionary_match,
      :reverse_dictionary_match,
      :l33t_match,
      :spatial_match,
      :repeat_match,
      :sequence_match,
      :regex_match,
      :date_match
    ].each do |matcher|
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

          error = (js_result - ruby_result).abs
          error_margin = error.to_f / js_result
          expect(error_margin).to be <= 0.0001
          ruby_result # return value (cannot use the word return from here)
        end
      end

      password_list.each do |pw|
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
          # if ruby_result["sequence"] != js_result["sequence"]
          #   binding.pry
          # end
          expect(ruby_result["sequence"]).to eq js_result["sequence"]
          ruby_base_result = ruby_result.reject { |k, _v| ["sequence", "guesses"].include? k }
          js_base_result = js_result.reject { |k, _v| ["sequence", "guesses"].include? k }
          expect(ruby_base_result).to eq(js_base_result)
          error = (js_result["guesses"] - ruby_result["guesses"]).abs
          error_margin = error.to_f / js_result["guesses"]
          if error_margin > 0.0001
            puts args[0]["pattern"]
            # binding.pry
            # ruby_result = m.call(*args)
          end
          expect(error_margin).to be <= 0.0001
        end
      end
    end

    it "nck" do
      [
        [0,  0, 1],
        [1,  0, 1],
        [5,  0, 1],
        [0,  1, 0],
        [0,  5, 0],
        [2,  1, 2],
        [4,  2, 6],
        [33, 7, 4_272_048]
      ].each do |(n, k, result)|
        expect(Zxcvbn::Scoring.nck(n, k)).to eq(result)
      end
      n = 49
      k = 12
      expect(Zxcvbn::Scoring.nck(n, k)).to eq(Zxcvbn::Scoring.nck(n, n - k))
      expect(Zxcvbn::Scoring.nck(n, k)).to eq(Zxcvbn::Scoring.nck(n - 1, k - 1) + Zxcvbn::Scoring.nck(n - 1, k))
    end

    it "spatial_guesses" do
      match = {
        "token" => "zxcvbn",
        "graph" => "qwerty",
        "turns" => 1,
        "shifted_count" => 0
      }
      idx_end = match["token"].length - 1
      base_guesses = Zxcvbn::Scoring::KEYBOARD_STARTING_POSITIONS * Zxcvbn::Scoring::KEYBOARD_AVERAGE_DEGREE * idx_end
      msg = "with no turns or shifts, guesses is starts * degree * (len-1)"
      expect(Zxcvbn::Scoring.spatial_guesses(match)).to eq(base_guesses), msg

      match.delete "guesses"
      match["token"] = "ZxCvbn"
      match["shifted_count"] = 2
      shifted_guesses = base_guesses * (Zxcvbn::Scoring.nck(6, 2) + Zxcvbn::Scoring.nck(6, 1))
      msg = "guesses is added for shifted keys, similar to capitals in dictionary matching"
      expect(Zxcvbn::Scoring.spatial_guesses(match)).to eq(shifted_guesses), msg

      match.delete "guesses"
      match["token"] = "ZXCVBN"
      match["shifted_count"] = 6
      shifted_guesses = base_guesses * 2
      msg = "when everything is shifted, guesses are doubled"
      expect(Zxcvbn::Scoring.spatial_guesses(match)).to eq(shifted_guesses), msg

      match = {
        "token" => "zxcft6yh",
        "graph" => "qwerty",
        "turns" => 3,
        "shifted_count" => 0
      }
      guesses = 0
      ll = match["token"].length
      s = Zxcvbn::Scoring::KEYBOARD_STARTING_POSITIONS
      d = Zxcvbn::Scoring::KEYBOARD_AVERAGE_DEGREE
      (2..ll).each do |i|
        (1..[match["turns"], i - 1].min).each do |j|
          guesses += Zxcvbn::Scoring.nck(i - 1, j - 1) * s * (d**j)
        end
      end
      msg = "spatial guesses accounts for turn positions, directions and starting keys"
      expect(Zxcvbn::Scoring.spatial_guesses(match)).to eq(guesses), msg

      match = {
        "token" => "zxcvbn",
        "graph" => "qwerty",
        "turns" => 1,
        "shifted_count" => 0
      }
      expect(Zxcvbn::Scoring.spatial_guesses(match)).to eq(2160.0000000000005)
    end

    context "when running #zxcvbn" do
      password_list.each do |pw|
        it "#zxcvbn produces same output for '#{pw}'" do
          ruby_result = strip_log10 Zxcvbn.zxcvbn(pw)
          js_result = strip_log10 js_zxcvbn(pw)

          ruby_sequence_result = ruby_result["sequence"].map do |i|
            i.reject do |k, _v|
              ["guesses", "sub", "sub_display"].include?(k)
            end
          end
          js_sequence_result = js_result["sequence"].map do |i|
            i.reject do |k, _v|
              ["guesses", "sub", "sub_display"].include?(k)
            end
          end
          expect(ruby_sequence_result).to eq js_sequence_result
          ruby_base_result = ruby_result.reject { |k, _v| ["sequence", "guesses"].include? k }
          js_base_result = js_result.reject { |k, _v| ["sequence", "guesses"].include? k }
          expect(ruby_base_result).to eq(js_base_result)

          error = (js_result["guesses"] - ruby_result["guesses"]).abs
          error_margin = error.to_f / js_result["guesses"]
          expect(error_margin).to be <= 0.0001
        end
      end
    end
  end

  it "works with empty string" do
    expect { Zxcvbn.zxcvbn("") }.not_to raise_error
  end

  it "works with very long pass" do
    pw = [
      "hKmuwA4TkmoSmqTuBX#x%%fscPx?BN^JxylhceDouLFLNRuXX5E$R@8^h%mxpv6F#q6*?52",
      "V7cw^QwOC4_7XUXBPp%C9#LTGo-^CcyF*mE2UE^U?gH6Vc3f!Tq6C|KLn%uwqg3q12SrUW@",
      "lryJPnUKVfcS0hPJdK-RVDsZab01_ueyz?oWDq2NKo3zbn2la9t=PkMk1L62eV2yqdorG7p",
      "LY1pCuDf1gJ=%ASFHP7+taxrI0vH4kvhWfHScdveV@?"
    ].join
    expect { Zxcvbn.zxcvbn(pw) }.not_to raise_error
  end
end
