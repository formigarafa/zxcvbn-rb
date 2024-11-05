# frozen_string_literal: true

require_relative "zxcvbn/adjacency_graphs"
require_relative "zxcvbn/frequency_lists"
require_relative "zxcvbn/matching"
require_relative "zxcvbn/scoring"
require_relative "zxcvbn/time_estimates"
require_relative "zxcvbn/feedback"
require_relative "zxcvbn/version"

module Zxcvbn
  class Error < StandardError; end
  Result = Struct.new(
    :password,
    :guesses,
    :guesses_log10,
    :sequence,
    :calc_time,
    :crack_times_seconds,
    :crack_times_display,
    :score,
    :feedback,
    keyword_init: true
  )

  def self.zxcvbn(password, user_inputs = [])
    Tester.new.zxcvbn(password, user_inputs)
  end

  def self.test(password, user_inputs = [])
    Tester.new.test(password, user_inputs)
  end

  class Tester
    def matching
      @matching ||= Matching.new
    end

    def test(password, user_inputs = [])
      Result.new(zxcvbn(password, user_inputs))
    end

    def zxcvbn(password, user_inputs = [])
      start = (Time.now.to_f * 1000).to_i
      matches = matching.omnimatch(password, user_inputs)
      result = Scoring.most_guessable_match_sequence(password, matches)
      result["calc_time"] = (Time.now.to_f * 1000).to_i - start
      attack_times = TimeEstimates.estimate_attack_times(result["guesses"])
      attack_times.each do |prop, val|
        result[prop] = val
      end
      result["feedback"] = Feedback.get_feedback(result["score"], result["sequence"])
      result
    end
  end
end
