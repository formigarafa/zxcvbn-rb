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
    #{Time.now.year}
  PASSWORD_LIST

  password_list.each do |pw|
    it "works with '#{pw}'" do
      expect{ Zxcvbn.zxcvbn(pw) }.not_to raise_error
    end

    it "works the same as js version for '#{pw}'" do
      ruby_result = Zxcvbn.zxcvbn(pw)
      js_result = js_ctx.call('zxcvbn', pw)
      expect(ruby_result).to eq js_result
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
