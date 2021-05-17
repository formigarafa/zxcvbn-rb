# frozen_string_literal: true

module Zxcvbn
  module TimeEstimates
    def self.estimate_attack_times(guesses)
      crack_times_seconds = {
        "online_throttling_100_per_hour" => guesses / (100.0 / 3600.0),
        "online_no_throttling_10_per_second" => guesses / 10.0,
        "offline_slow_hashing_1e4_per_second" => guesses / 1e4,
        "offline_fast_hashing_1e10_per_second" => guesses / 1e10
      }
      crack_times_display = {}
      crack_times_seconds.each do |scenario, seconds|
        crack_times_display[scenario] = display_time(seconds)
      end

      {
        "crack_times_seconds" => crack_times_seconds,
        "crack_times_display" => crack_times_display,
        "score" => guesses_to_score(guesses)
      }
    end

    def self.guesses_to_score(guesses)
      delta = 5
      if guesses < 1e3 + delta
        # risky password: "too guessable"
        0
      elsif guesses < 1e6 + delta
        # modest protection from throttled online attacks: "very guessable"
        1
      elsif guesses < 1e8 + delta
        # modest protection from unthrottled online attacks: "somewhat guessable"
        2
      elsif guesses < 1e10 + delta
        # modest protection from offline attacks: "safely unguessable"
        # assuming a salted, slow hash function like bcrypt, scrypt, PBKDF2, argon, etc
        3
      else
        # strong protection from offline attacks under same scenario: "very unguessable"
        4
      end
    end

    def self.display_time(seconds)
      minute = 60
      hour = minute * 60
      day = hour * 24
      month = day * 31
      year = month * 12
      century = year * 100
      display_num, display_str = if seconds < 1
        [nil, "less than a second"]
      elsif seconds < minute
        base = seconds.round
        [base, "#{base} second"]
      elsif seconds < hour
        base = (seconds / minute).round
        [base, "#{base} minute"]
      elsif seconds < day
        base = (seconds / hour).round
        [base, "#{base} hour"]
      elsif seconds < month
        base = (seconds / day).round
        [base, "#{base} day"]
      elsif seconds < year
        base = (seconds / month).round
        [base, "#{base} month"]
      elsif seconds < century
        base = (seconds / year).round
        [base, "#{base} year"]
      else
        [nil, "centuries"]
      end
      display_str += "s" if display_num && display_num != 1
      display_str
    end
  end
end
