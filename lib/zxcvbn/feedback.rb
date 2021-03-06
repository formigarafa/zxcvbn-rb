# frozen_string_literal: true

module Zxcvbn
  module Feedback
    DEFAULT_FEEDBACK = {
      "warning" => "",
      "suggestions" => ["Use a few words, avoid common phrases", "No need for symbols, digits, or uppercase letters"]
    }.freeze

    def self.get_feedback(score, sequence)
      if sequence.empty?
        # starting feedback
        return DEFAULT_FEEDBACK
      end

      # no feedback if score is good or great.
      if score > 2
        return {
          "warning" => "",
          "suggestions" => []
        }
      end

      longest_match = sequence.max_by { |match| match["token"].length }
      feedback = get_match_feedback(longest_match, sequence.size == 1)
      extra_feedback = "Add another word or two. Uncommon words are better."
      if feedback
        feedback["suggestions"].unshift(extra_feedback)
        feedback["warning"] = "" if feedback["warning"].nil?
      else
        feedback = {
          "warning" => "",
          "suggestions" => [extra_feedback]
        }
      end
      feedback
    end

    def self.get_match_feedback(match, is_sole_match)
      case match["pattern"]
      when "dictionary"
        get_dictionary_match_feedback(match, is_sole_match)
      when "spatial"
        warning = if match["turns"] == 1
          "Straight rows of keys are easy to guess"
        else
          "Short keyboard patterns are easy to guess"
        end
        {
          "warning" => warning,
          "suggestions" => ["Use a longer keyboard pattern with more turns"]
        }
      when "repeat"
        warning = if match["base_token"].length == 1
          'Repeats like "aaa" are easy to guess'
        else
          'Repeats like "abcabcabc" are only slightly harder to guess than "abc"'
        end
        {
          "warning" => warning,
          "suggestions" => ["Avoid repeated words and characters"]
        }
      when "sequence"
        {
          "warning" => "Sequences like abc or 6543 are easy to guess",
          "suggestions" => ["Avoid sequences"]
        }
      when "regex"
        if match["regex_name"] == "recent_year"
          {
            "warning" => "Recent years are easy to guess",
            "suggestions" => ["Avoid recent years", "Avoid years that are associated with you"]
          }
        end
        # break
      when "date"
        {
          "warning" => "Dates are often easy to guess",
          "suggestions" => ["Avoid dates and years that are associated with you"]
        }
      end
    end

    def self.get_dictionary_match_feedback(match, is_sole_match)
      warning = if match["dictionary_name"] == "passwords"
        if is_sole_match && !match["l33t"] && !match["reversed"]
          if match["rank"] <= 10
            "This is a top-10 common password"
          elsif match["rank"] <= 100
            "This is a top-100 common password"
          else
            "This is a very common password"
          end
        elsif match["guesses_log10"] <= 4
          "This is similar to a commonly used password"
        end
      elsif match["dictionary_name"] == "english_wikipedia"
        "A word by itself is easy to guess" if is_sole_match
      elsif ["surnames", "male_names", "female_names"].include?(match["dictionary_name"])
        if is_sole_match
          "Names and surnames by themselves are easy to guess"
        else
          "Common names and surnames are easy to guess"
        end
      else
        ""
      end
      suggestions = []
      word = match["token"]
      if word.match(Scoring::START_UPPER)
        suggestions << "Capitalization doesn't help very much"
      elsif word.match(Scoring::ALL_UPPER) && word.downcase != word
        suggestions << "All-uppercase is almost as easy to guess as all-lowercase"
      end
      suggestions << "Reversed words aren't much harder to guess" if match["reversed"] && match["token"].length >= 4
      suggestions << "Predictable substitutions like '@' instead of 'a' don't help very much" if match["l33t"]
      {
        "warning" => warning,
        "suggestions" => suggestions
      }
    end
  end
end
