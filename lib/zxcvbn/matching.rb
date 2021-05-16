# frozen_string_literal: true

module Zxcvbn
  module Matching
    def self.build_ranked_dict(ordered_list)
      result = {}
      # rank starts at 1, not 0
      ordered_list.each_with_index do |word, idx|
        result[word] = idx + 1
      end
      return result
    end

    RANKED_DICTIONARIES = FREQUENCY_LISTS.each_with_object({}) do |(name, lst), o|
      o[name] = build_ranked_dict(lst);
    end

    GRAPHS = {
      "qwerty" => ADJACENCY_GRAPHS["qwerty"],
      "dvorak" => ADJACENCY_GRAPHS["dvorak"],
      "keypad" => ADJACENCY_GRAPHS["keypad"],
      "mac_keypad" => ADJACENCY_GRAPHS["mac_keypad"]
    }

    L33T_TABLE = {
      "a" => ['4', '@'],
      "b" => ['8'],
      "c" => ['(', '{', '[', '<'],
      "e" => ['3'],
      "g" => ['6', '9'],
      "i" => ['1', '!', '|'],
      "l" => ['1', '|', '7'],
      "o" => ['0'],
      "s" => ['$', '5'],
      "t" => ['+', '7'],
      "x" => ['%'],
      "z" => ['2']
    }

    REGEXEN = {
      # alpha_lower: /[a-z]/,
      # recent_year: /19\d\d|200\d|201\d/g
      "recent_year" => /19\d\d|200\d|201\d/
    }

    DATE_MAX_YEAR = 2050

    DATE_MIN_YEAR = 1000

    DATE_SPLITS = {
      4 => [ # for length-4 strings, eg 1191 or 9111, two ways to split:
        [
          1,
          2 # 1 1 91 (2nd split starts at index 1, 3rd at index 2)
        ],
        [
          2,
          3 # 91 1 1
        ]
      ],
      5 => [
        [
          1,
          3 # 1 11 91
        ],
        [
          2,
          3 # 11 1 91
        ]
      ],
      6 => [
        [
          1,
          2 # 1 1 1991
        ],
        [
          2,
          4 # 11 11 91
        ],
        [
          4,
          5 # 1991 1 1
        ]
      ],
      7 => [
        [
          1,
          3 # 1 11 1991
        ],
        [
          2,
          3 # 11 1 1991
        ],
        [
          4,
          5 # 1991 1 11
        ],
        [
          4,
          6 # 1991 11 1
        ]
      ],
      8 => [
        [
          2,
          4 # 11 11 1991
        ],
        [
          4,
          6 # 1991 11 11
        ]
      ]
    }

    def self.empty(obj)
      obj.empty?
    end

    def self.translate(string, chr_map)
      string.split('').map {|chr| chr_map[chr] || chr}.join("")
    end

    def self.sorted(matches)
      # sort on i primary, j secondary
      matches.sort_by!{|match| [match["i"], match["j"]] }
    end

    # ------------------------------------------------------------------------------
    # omnimatch -- combine everything ----------------------------------------------
    # ------------------------------------------------------------------------------
    def self.omnimatch(password)
      matches = []
      matchers = [:dictionary_match, :reverse_dictionary_match, :l33t_match, :spatial_match, :repeat_match, :sequence_match, :regex_match, :date_match]
      matchers.each do |matcher|
        matches += send(matcher, password)
      end
      return sorted(matches)
    end

    #-------------------------------------------------------------------------------
    # dictionary match (common passwords, english, last names, etc) ----------------
    #-------------------------------------------------------------------------------
    def self.dictionary_match(password, _ranked_dictionaries = RANKED_DICTIONARIES)
      # _ranked_dictionaries variable is for unit testing purposes
      matches = []
      len = password.length
      password_lower = password.downcase
      _ranked_dictionaries.each do |dictionary_name, ranked_dict|
        (0...len).each do |i|
          (i...len).each do |j|
            if ranked_dict.has_key?(password_lower[i..j])
              word = password_lower[i..j]
              rank = ranked_dict[word]
              matches << {
                "pattern" => 'dictionary',
                "i" => i,
                "j" => j,
                "token" => password[i..j],
                "matched_word" => word,
                "rank" => rank,
                "dictionary_name" => dictionary_name,
                "reversed" => false,
                "l33t" => false
              }
            end
          end
        end
      end
      return sorted(matches)
    end

    def self.reverse_dictionary_match(password, _ranked_dictionaries = RANKED_DICTIONARIES)
      reversed_password = password.reverse
      matches = dictionary_match(reversed_password, _ranked_dictionaries)
      matches.each do |match|
        match["token"] = match["token"].reverse
        match["reversed"] = true
        # map coordinates back to original string
        match["i"], match["j"] = [password.length - 1 - match["j"], password.length - 1 - match["i"]]
      end
      return sorted(matches)
    end

    def self.set_user_input_dictionary(ordered_list)
      return RANKED_DICTIONARIES['user_inputs'] = build_ranked_dict(ordered_list.dup)
    end

    #-------------------------------------------------------------------------------
    # dictionary match with common l33t substitutions ------------------------------
    #-------------------------------------------------------------------------------
    # makes a pruned copy of l33t_table that only includes password's possible substitutions
    def self.relevant_l33t_subtable(password, table)
      password_chars = {}
      password.split('').each do |chr|
        password_chars[chr] = true
      end
      subtable = {}
      table.each do |letter, subs|
        relevant_subs = []
        subs.each do |sub|
          if password_chars[sub]
            relevant_subs << sub
          end
        end
        if !relevant_subs.empty?
          subtable[letter] = relevant_subs
        end
      end
      return subtable
    end

    # returns the list of possible 1337 replacement dictionaries for a given password
    def self.enumerate_l33t_subs(table)
      keys = table.keys
      subs = [[]]

      dedup = -> (subs) do
        deduped = []
        members = {}
        subs.each do |sub|
          assoc = sub.map {|k, v| [k, v] }
          assoc.sort!
          label = assoc.map{|k, v| "#{k},#{v}"}.join("-")

          if !members.has_key?(label)
            members[label] = true
            deduped << sub
          end
        end
        return deduped
      end

      helper = -> (keys) do
        if keys.empty?
          return;
        end
        first_key = keys[0]
        rest_keys = keys[1..-1]
        next_subs = []
        table[first_key].each do |l33t_chr|
          subs.each do |sub|
            dup_l33t_index = -1;
            (0...sub.length).each do |i|
              if sub[i][0] === l33t_chr
                dup_l33t_index = i
                break
              end
            end
            if dup_l33t_index === -1
              sub_extension = sub.concat([[l33t_chr, first_key]])
              next_subs << sub_extension
            else
              sub_alternative = sub.dup
              sub_alternative.delete_at(dup_l33t_index)
              sub_alternative << [l33t_chr, first_key]
              next_subs << sub
              next_subs << sub_alternative
            end
          end
        end
        subs = dedup.call(next_subs)
        helper.call(rest_keys)
      end

      helper.call(keys)

      sub_dicts = [] # convert from assoc lists to dicts
      subs.each do |sub|
        sub_dict = {}
        sub.each do |(l33t_chr, chr)|
          sub_dict[l33t_chr] = chr;
        end
        sub_dicts << sub_dict
      end

      return sub_dicts
    end

    def self.l33t_match(password, _ranked_dictionaries = RANKED_DICTIONARIES, _l33t_table = L33T_TABLE)
      matches = []
      enumerate_l33t_subs(relevant_l33t_subtable(password, _l33t_table)).each do |sub|
        if empty(sub) # corner case: password has no relevant subs.
          break
        end
        subbed_password = translate(password, sub)
        dictionary_match(subbed_password, _ranked_dictionaries).each do |match|
          token = password[match["i"]..match["j"]]
          if token.downcase == match["matched_word"]
            next # only return the matches that contain an actual substitution
          end
          match_sub = {} # subset of mappings in sub that are in use for this match
          sub.each do |subbed_chr, chr|
            if token.index(subbed_chr)
              match_sub[subbed_chr] = chr
            end
          end
          match["l33t"] = true;
          match["token"] = token;
          match["sub"] = match_sub;
          match["sub_display"] = results = match_sub.sort_by{|k, v| k}.to_h.map {|k, v| "#{k} -> #{v}" }.join(", ")
          matches << match
        end
      end
      return sorted(matches.select do |match|
        # filter single-character l33t matches to reduce noise.
        # otherwise '1' matches 'i', '4' matches 'a', both very common English words
        # with low dictionary rank.
        match["token"].length > 1;
      end)
    end

    # ------------------------------------------------------------------------------
    # spatial match (qwerty/dvorak/keypad) -----------------------------------------
    # ------------------------------------------------------------------------------
    def self.spatial_match(password, _graphs = GRAPHS)
      matches = []
      _graphs.each do |graph_name, graph|
        matches += spatial_match_helper(password, graph, graph_name)
      end
      return sorted(matches)
    end

    SHIFTED_RX = /[~!@#$%^&*()_+QWERTYUIOP{}|ASDFGHJKL:"ZXCVBNM<>?]/

    def self.spatial_match_helper(password, graph, graph_name)
      matches = []
      i = 0
      while i < password.length - 1
        j = i + 1
        last_direction = nil
        turns = 0
        if (graph_name == 'qwerty' || graph_name == 'dvorak') && SHIFTED_RX.match?(password[i])
          # initial character is shifted
          shifted_count = 1
        else
          shifted_count = 0
        end
        loop do
          prev_char = password[j - 1]
          found = false
          found_direction = -1
          cur_direction = -1
          adjacents = graph[prev_char] || []
          # consider growing pattern by one character if j hasn't gone over the edge.
          if j < password.length
            cur_char = password[j]
            adjacents.each do |adj|
              cur_direction += 1
              if adj && adj.index(cur_char)
                found = true
                found_direction = cur_direction
                if adj.index(cur_char) == 1
                  # index 1 in the adjacency means the key is shifted,
                  # 0 means unshifted: A vs a, % vs 5, etc.
                  # for example, 'q' is adjacent to the entry '2@'.
                  # @ is shifted w/ index 1, 2 is unshifted.
                  shifted_count += 1
                end
                if last_direction != found_direction
                  # adding a turn is correct even in the initial case when last_direction is null:
                  # every spatial pattern starts with a turn.
                  turns += 1
                  last_direction = found_direction
                end
                break
              end
            end
          end
          # if the current pattern continued, extend j and try to grow again
          if found
            j += 1
          else
            # otherwise push the pattern discovered so far, if any...
            if j - i > 2 # don't consider length 1 or 2 chains.
              matches << {
                "pattern" => 'spatial',
                "i" => i,
                "j" => j - 1,
                "token" => password[i...j],
                "graph" => graph_name,
                "turns" => turns,
                "shifted_count" => shifted_count
              }
            end
            # ...and then start a new search for the rest of the password.
            i = j
            break
          end
        end
      end
      return matches
    end

    #-------------------------------------------------------------------------------
    # repeats (aaa, abcabcabc) and sequences (abcdef) ------------------------------
    #-------------------------------------------------------------------------------
    def self.repeat_match(password)
      matches = []
      greedy = /(.+)\1+/
      lazy = /(.+?)\1+/
      lazy_anchored = /^(.+?)\1+$/
      last_index = 0
      while last_index < password.length
        # greedy_last_index = lazy_last_index = last_index
        greedy_match = greedy.match(password, last_index)
        lazy_match = lazy.match(password, last_index)
        if !greedy_match
          break
        end
        # coverage ???
        if (greedy_match[0].length > lazy_match[0].length)
          # greedy beats lazy for 'aabaab'
          #   greedy: [aabaab, aab]
          #   lazy:   [aa,     a]
          match = greedy_match
          # greedy's repeated string might itself be repeated, eg.
          # aabaab in aabaabaabaab.
          # run an anchored lazy match on greedy's repeated string
          # to find the shortest repeated string
          base_token = lazy_anchored.match(match[0])[1]
        else
          # lazy beats greedy for 'aaaaa'
          #   greedy: [aaaa,  aa]
          #   lazy:   [aaaaa, a]
          match = lazy_match;
          base_token = match[1];
        end
        i, j = [match.begin(0), match.end(0) - 1]
        # recursively match and score the base string
        base_analysis = Scoring.most_guessable_match_sequence(base_token, omnimatch(base_token))
        base_matches = base_analysis["sequence"]
        base_guesses = base_analysis["guesses"]
        matches << {
          "pattern" => 'repeat',
          "i" => i,
          "j" => j,
          "token" => match[0],
          "base_token" => base_token,
          "base_guesses" => base_guesses,
          "base_matches" => base_matches,
          "repeat_count" => match[0].length / base_token.length
        }
        last_index = j + 1
      end
      return matches
    end

    MAX_DELTA = 5

    def self.sequence_match(password)
      # Identifies sequences by looking for repeated differences in unicode codepoint.
      # this allows skipping, such as 9753, and also matches some extended unicode sequences
      # such as Greek and Cyrillic alphabets.

      # for example, consider the input 'abcdb975zy'

      # password: a   b   c   d   b    9   7   5   z   y
      # index:    0   1   2   3   4    5   6   7   8   9
      # delta:      1   1   1  -2  -41  -2  -2  69   1

      # expected result:
      # [(i, j, delta), ...] = [(0, 3, 1), (5, 7, -2), (8, 9, 1)]
      if password.length == 1
        return []
      end
      result = []

      update = -> (i, j, delta) do
        delta ||= 0
        if j - i > 1 || (delta).abs == 1
          if 0 < delta.abs && delta.abs <= MAX_DELTA
            token = password[i..j]
            if /^[a-z]+$/.match?(token)
              sequence_name = 'lower'
              sequence_space = 26
            elsif /^[A-Z]+$/.match?(token)
              sequence_name = 'upper'
              sequence_space = 26
            elsif /^\d+$/.match?(token)
              sequence_name = 'digits'
              sequence_space = 10
            else
              # conservatively stick with roman alphabet size.
              # (this could be improved)
              sequence_name = 'unicode'
              sequence_space = 26
            end
            return result << {
              "pattern" => 'sequence',
              "i" =>i,
              "j" =>j,
              "token" => password[i..j],
              "sequence_name" => sequence_name,
              "sequence_space" => sequence_space,
              "ascending" => delta > 0
            }
          end
        end
      end

      result = []
      i = 0
      last_delta = nil
      (1...password.length).each do |k|
        delta = password.bytes[k] - password.bytes[k - 1]
        if !last_delta
          last_delta = delta
        end
        if delta == last_delta
          next
        end
        j = k - 1
        update.call(i, j, last_delta)
        i = j
        last_delta = delta
      end
      update.call(i, password.length - 1, last_delta)
      return result
    end

    #-------------------------------------------------------------------------------
    # regex matching ---------------------------------------------------------------
    #-------------------------------------------------------------------------------
    def self.regex_match(password, _regexen = REGEXEN)
      matches = []
      _regexen.each do |name, regex|
        # regex.lastIndex = 0; # keeps regex_match stateless
        match_index = 0
        while rx_match = regex.match(password, match_index)
          token = rx_match[0]
          matches << {
            "pattern" => 'regex',
            "token" => token,
            "i" => rx_match.begin(0),
            "j" => rx_match.end(0) - 1,
            "regex_name" => name,
            "regex_match" => rx_match
          }
          match_index = rx_match.begin(0) + 1
        end
      end
      return sorted(matches)
    end

    #-------------------------------------------------------------------------------
    # date matching ----------------------------------------------------------------
    #-------------------------------------------------------------------------------
    def self.date_match(password)
      # a "date" is recognized as:
      #   any 3-tuple that starts or ends with a 2- or 4-digit year,
      #   with 2 or 0 separator chars (1.1.91 or 1191),
      #   maybe zero-padded (01-01-91 vs 1-1-91),
      #   a month between 1 and 12,
      #   a day between 1 and 31.

      # note: this isn't true date parsing in that "feb 31st" is allowed,
      # this doesn't check for leap years, etc.

      # recipe:
      # start with regex to find maybe-dates, then attempt to map the integers
      # onto month-day-year to filter the maybe-dates into dates.
      # finally, remove matches that are substrings of other matches to reduce noise.

      # note: instead of using a lazy or greedy regex to find many dates over the full string,
      # this uses a ^...$ regex against every substring of the password -- less performant but leads
      # to every possible date match.
      matches = []
      maybe_date_no_separator = /^\d{4,8}$/

      # maybe_date_with_separator = %r{
      #   ^
      #   ( \d{1,4} )    # day, month, year
      #   ( [\s/\\_.-] ) # separator
      #   ( \d{1,2} )    # day, month
      #   \2             # same separator
      #   ( \d{1,4} )    # day, month, year
      #   $
      # }
      maybe_date_with_separator = /^(\d{1,4})([\s\/\\_.-])(\d{1,2})\2(\d{1,4})$/

      (0..(password.length - 4)).each do |i|
        (i + 3..i + 7).each do |j|
          if j >= password.length
            break
          end
          token = password[i..j]
          if !maybe_date_no_separator.match(token)
            next
          end
          candidates = []
          DATE_SPLITS[token.length].each do |(k, l)|
            dmy = map_ints_to_dmy([token[0...k].to_i, token[k...l].to_i, token[l..-1].to_i])
            if dmy
              candidates << dmy
            end
          end

          if candidates.empty?
            next
          end
          # at this point: different possible dmy mappings for the same i,j substring.
          # match the candidate date that likely takes the fewest guesses: a year closest to 2000.
          # (scoring.REFERENCE_YEAR).

          # ie, considering '111504', prefer 11-15-04 to 1-1-1504
          # (interpreting '04' as 2004)
          best_candidate = candidates.min_by{|candidate| (candidate["year"] - Scoring::REFERENCE_YEAR).abs }
          matches << {
            "pattern" => 'date',
            "token" => token,
            "i" => i,
            "j" => j,
            "separator" => '',
            "year" => best_candidate["year"],
            "month" => best_candidate["month"],
            "day" => best_candidate["day"]
          }
        end
      end
      # dates with separators are between length 6 '1/1/91' and 10 '11/11/1991'
      (0..password.length - 6).each do |i|
        (i + 5..i + 9).each do |j|
          if j >= password.length
            break
          end
          token = password[i..j]
          rx_match = maybe_date_with_separator.match(token)
          if !rx_match
            next
          end
          dmy = map_ints_to_dmy([rx_match[1].to_i, rx_match[3].to_i, rx_match[4].to_i])
          if !dmy
            next
          end
          matches << {
            "pattern" => 'date',
            "token" => token,
            "i" => i,
            "j" => j,
            "separator" => rx_match[2],
            "year" => dmy["year"],
            "month" => dmy["month"],
            "day" => dmy["day"]
          }
        end
      end
      # matches now contains all valid date strings in a way that is tricky to capture
      # with regexes only. while thorough, it will contain some unintuitive noise:

      # '2015_06_04', in addition to matching 2015_06_04, will also contain
      # 5(!) other date matches: 15_06_04, 5_06_04, ..., even 2015 (matched as 5/1/2020)

      # to reduce noise, remove date matches that are strict substrings of others
      return sorted(matches.uniq.select do |match|
        matches.find do |other_match|
          other_match["i"] <= match["i"] && other_match["j"] >= match["j"]
        end
      end)
    end

    def self.map_ints_to_dmy(ints)
      # given a 3-tuple, discard if:
      #   middle int is over 31 (for all dmy formats, years are never allowed in the middle)
      #   middle int is zero
      #   any int is over the max allowable year
      #   any int is over two digits but under the min allowable year
      #   2 ints are over 31, the max allowable day
      #   2 ints are zero
      #   all ints are over 12, the max allowable month
      if ints[1] > 31 || ints[1] <= 0
        return
      end
      over_12 = 0
      over_31 = 0
      under_1 = 0
      ints.each do |int|
        if (99 < int && int < DATE_MIN_YEAR) || int > DATE_MAX_YEAR
          return
        end
        if int > 31
          over_31 += 1
        end
        if int > 12
          over_12 += 1
        end
        if int <= 0
          under_1 += 1
        end
      end
      if over_31 >= 2 || over_12 === 3 || under_1 >= 2
        return
      end

      possible_year_splits = [
        [ints[2], ints[0..1]], # year last
        [ints[0], ints[1..2]], # year first
      ]
      possible_year_splits.each do |(y, rest)|
        if DATE_MIN_YEAR <= y && y <= DATE_MAX_YEAR
          dm = map_ints_to_dm(rest)
          if dm
            return {
              "year" => y,
              "month" => dm["month"],
              "day" => dm["day"]
            }
          else
            # for a candidate that includes a four-digit year,
            # when the remaining ints don't match to a day and month,
            # it is not a date.
            return
          end
        end
      end

      # given no four-digit year, two digit years are the most flexible int to match, so
      # try to parse a day-month out of ints[0..1] or ints[1..0]
      possible_year_splits.each do |(y, rest)|
        dm = map_ints_to_dm(rest)
        if dm
          y = two_to_four_digit_year(y)
          return {
            "year" => y,
            "month" => dm["month"],
            "day" => dm["day"]
          }
        end
      end
    end

    def self.map_ints_to_dm(ints)
      [ints, ints.reverse].each do |(d, m)|
        if (1 <= d && d <= 31) && (1 <= m && m <= 12)
          return {
            "day" => d,
            "month" => m
          }
        end
      end
      return nil
    end

    def self.two_to_four_digit_year(year)
      if year > 99
        return year
      elsif year > 50
        # 87 -> 1987
        return year + 1900
      else
        # 15 -> 2015
        return year + 2000
      end
    end
  end
end
