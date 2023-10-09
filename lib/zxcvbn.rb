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

  def self.zxcvbn(password, user_inputs = [])
    start = (Time.now.to_f * 1000).to_i
    matches = Matching.omnimatch(password, user_inputs)
    result = Scoring.most_guessable_match_sequence(password, matches)
    result["calc_time"] = (Time.now.to_f * 1000).to_i - start
    attack_times = TimeEstimates.estimate_attack_times(result["guesses"])
    attack_times.each do |prop, val|
      result[prop] = val
    end
    result["feedback"] = Feedback.get_feedback(result["score"], result["sequence"])
    result
  end

  def self.test(password, user_inputs = [])
    OpenStruct.new(Zxcvbn.zxcvbn(password, user_inputs)) # rubocop:disable Style/OpenStructUse
  end

  class Tester
    def test(password, user_inputs = [])
      Zxcvbn.test(password, user_inputs)
    end
  end
end
