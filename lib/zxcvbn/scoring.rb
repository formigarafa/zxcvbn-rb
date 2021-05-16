# frozen_string_literal: true

module Zxcvbn
  module Scoring
    # on qwerty, 'g' has degree 6, being adjacent to 'ftyhbv'. '\' has degree 1.
    # this calculates the average over all keys.
    def self.calc_average_degree(graph)
      average = 0
      graph.each do |key, neighbors|
        average += neighbors.count {|n| n }
      end
      average /= graph.keys.size
      return average
    end

    BRUTEFORCE_CARDINALITY = 10

    MIN_GUESSES_BEFORE_GROWING_SEQUENCE = 10000

    MIN_SUBMATCH_GUESSES_SINGLE_CHAR = 10

    MIN_SUBMATCH_GUESSES_MULTI_CHAR = 50

    def self.nCk(n, k)
      # http://blog.plover.com/math/choose.html
      if k > n
        return 0
      end
      if k == 0
        return 1
      end
      r = 1
      (1..k).each do |d|
        r *= n
        r /= d
        n -= 1
      end
      return r
    end

    def self.factorial(n)
      # unoptimized, called only on small n
      if n < 2
        return 1
      end
      return (2..10).reduce(&:*)
    end

    # ------------------------------------------------------------------------------
    # search --- most guessable match sequence -------------------------------------
    # ------------------------------------------------------------------------------

    # takes a sequence of overlapping matches, returns the non-overlapping sequence with
    # minimum guesses. the following is a O(l_max * (n + m)) dynamic programming algorithm
    # for a length-n password with m candidate matches. l_max is the maximum optimal
    # sequence length spanning each prefix of the password. In practice it rarely exceeds 5 and the
    # search terminates rapidly.

    # the optimal "minimum guesses" sequence is here defined to be the sequence that
    # minimizes the following function:

    #    g = l! * Product(m.guesses for m in sequence) + D^(l - 1)

    # where l is the length of the sequence.

    # the factorial term is the number of ways to order l patterns.

    # the D^(l-1) term is another length penalty, roughly capturing the idea that an
    # attacker will try lower-length sequences first before trying length-l sequences.

    # for example, consider a sequence that is date-repeat-dictionary.
    #  - an attacker would need to try other date-repeat-dictionary combinations,
    #    hence the product term.
    #  - an attacker would need to try repeat-date-dictionary, dictionary-repeat-date,
    #    ..., hence the factorial term.
    #  - an attacker would also likely try length-1 (dictionary) and length-2 (dictionary-date)
    #    sequences before length-3. assuming at minimum D guesses per pattern type,
    #    D^(l-1) approximates Sum(D^i for i in [1..l-1]

    # ------------------------------------------------------------------------------
    def self.most_guessable_match_sequence(password, matches, _exclude_additive = false)
      n = password.length
      # partition matches into sublists according to ending index j
      matches_by_j = (0...n).map { [] }
      matches.each do |m|
        matches_by_j[m[:j]] << m
      end

      # small detail: for deterministic output, sort each sublist by i.
      matches_by_j.each do |lst|
        lst.sort_by!{|m| m[:i] }
      end

      optimal = {
        # optimal.m[k][l] holds final match in the best length-l match sequence covering the
        # password prefix up to k, inclusive.
        # if there is no length-l sequence that scores better (fewer guesses) than
        # a shorter match sequence spanning the same prefix, optimal.m[k][l] is undefined.
        m: (0...n).map { {} },
        # same structure as optimal.m -- holds the product term Prod(m.guesses for m in sequence).
        # optimal.pi allows for fast (non-looping) updates to the minimization function.
        pi: (0...n).map { {} },
        # same structure as optimal.m -- holds the overall metric.
        g: (0...n).map { {} },
      }

      # helper: considers whether a length-l sequence ending at match m is better (fewer guesses)
      # than previously encountered sequences, updating state if so.
      update = -> (m, l) do
        k = m[:j]
        pi = estimate_guesses(m, password)
        if l > 1
          # we're considering a length-l sequence ending with match m:
          # obtain the product term in the minimization function by multiplying m's guesses
          # by the product of the length-(l-1) sequence ending just before m, at m.i - 1.
          pi *= optimal[:pi][m[:i] - 1][l - 1]
        end
        # calculate the minimization func
        g = factorial(l) * pi
        if !_exclude_additive
          g += MIN_GUESSES_BEFORE_GROWING_SEQUENCE ** (l - 1)
        end
        # update state if new best.
        # first see if any competing sequences covering this prefix, with l or fewer matches,
        # fare better than this sequence. if so, skip it and return.
        optimal[:g][k].each do |competing_l, competing_g|
          if competing_l > l
            next
          end
          if competing_g <= g
            return
          end
        end
        # this sequence might be part of the final optimal sequence.
        optimal[:g][k][l] = g
        optimal[:m][k][l] = m
        optimal[:pi][k][l] = pi
      end

      # helper: make bruteforce match objects spanning i to j, inclusive.
      make_bruteforce_match = -> (i, j) do
        return {
          pattern: 'bruteforce',
          token: password[i..j],
          i: i,
          j: j
        }
      end

      # helper: evaluate bruteforce matches ending at k.
      bruteforce_update = -> (k) do
        # see if a single bruteforce match spanning the k-prefix is optimal.
        m = make_bruteforce_match.call(0, k)
        update.call(m, 1)
        (1..k).each do |i|
          # generate k bruteforce matches, spanning from (i=1, j=k) up to (i=k, j=k).
          # see if adding these new matches to any of the sequences in optimal[i-1]
          # leads to new bests.
          m = make_bruteforce_match.call(i, k);
          optimal[:m][i-1].each do |l, last_m|
            l = l.to_i
            # corner: an optimal sequence will never have two adjacent bruteforce matches.
            # it is strictly better to have a single bruteforce match spanning the same region:
            # same contribution to the guess product with a lower length.
            # --> safe to skip those cases.
            if last_m[:pattern] == 'bruteforce'
              next
            end
            # try adding m to this length-l sequence.
            update.call(m, l + 1)
          end
        end
      end

      # helper: step backwards through optimal.m starting at the end,
      # constructing the final optimal match sequence.
      unwind = -> (n) do
        optimal_match_sequence = []
        k = n - 1
        # find the final best sequence length and score
        l, g = (optimal[:g][k] || []).min_by{|candidate_l, candidate_g| candidate_g || 0 }
        while k >= 0
          m = optimal[:m][k][l]
          optimal_match_sequence.unshift(m)
          k = m[:i] - 1
          l -= 1
        end
        return optimal_match_sequence
      end

      (0...n).each do |k|
        matches_by_j[k].each do |m|
          if m[:i] > 0
            optimal[:m][m[:i] - 1].keys.each do |l|
              update.call(m, l + 1)
            end
          else
            update.call(m, 1)
          end
        end
        bruteforce_update.call(k)
      end

      optimal_match_sequence = unwind.call(n)
      optimal_l = optimal_match_sequence.length

      # corner: empty password
      if password.length == 0
        guesses = 1
      else
        guesses = optimal[:g][n - 1][optimal_l]
      end

      # final result object
      return {
        password: password,
        guesses: guesses,
        guesses_log10: Math.log10(guesses),
        sequence: optimal_match_sequence
      }
    end

    # ------------------------------------------------------------------------------
    # guess estimation -- one function per match pattern ---------------------------
    # ------------------------------------------------------------------------------
    def self.estimate_guesses(match, password)
      if match[:guesses]
        return match[:guesses] # a match's guess estimate doesn't change. cache it.
      end
      min_guesses = 1
      if match[:token].length < password.length
        min_guesses = if match[:token].length == 1
          MIN_SUBMATCH_GUESSES_SINGLE_CHAR
        else
          MIN_SUBMATCH_GUESSES_MULTI_CHAR
        end
      end
      estimation_functions = {
        bruteforce: method(:bruteforce_guesses),
        dictionary: method(:dictionary_guesses),
        spatial: method(:spatial_guesses),
        repeat: method(:repeat_guesses),
        sequence: method(:sequence_guesses),
        regex: method(:regex_guesses),
        date: method(:date_guesses),
      }
      guesses = estimation_functions[match[:pattern].to_sym].call(match)
      match[:guesses] = [guesses, min_guesses].max
      match[:guesses_log10] = Math.log10(match[:guesses])
      return match[:guesses]
    end

    MAX_VALUE = 2 ** 1024

    def self.bruteforce_guesses(match)
      guesses = BRUTEFORCE_CARDINALITY ** match[:token].length
      # trying to match JS behaviour here setting a MAX_VALUE to try to acheieve same values as JS library.
      if guesses > MAX_VALUE
        guesses = MAX_VALUE
      end

      # small detail: make bruteforce matches at minimum one guess bigger than smallest allowed
      # submatch guesses, such that non-bruteforce submatches over the same [i..j] take precedence.
      min_guesses = if match[:token].length == 1
        MIN_SUBMATCH_GUESSES_SINGLE_CHAR + 1
      else
        MIN_SUBMATCH_GUESSES_MULTI_CHAR + 1
      end

      [guesses, min_guesses].max
    end

    def self.repeat_guesses(match)
      return match[:base_guesses] * match[:repeat_count]
    end

    def self.sequence_guesses(match)
      first_chr = match[:token][0]
      # lower guesses for obvious starting points
      if ['a', 'A', 'z', 'Z', '0', '1', '9'].include?(first_chr)
        base_guesses = 4
      else
        if first_chr.match?(/\d/)
          base_guesses = 10 # digits
        else
          # could give a higher base for uppercase,
          # assigning 26 to both upper and lower sequences is more conservative.
          base_guesses = 26
        end
      end
      if !match[:ascending]
        # need to try a descending sequence in addition to every ascending sequence ->
        # 2x guesses
        base_guesses *= 2
      end
      return base_guesses * match[:token].length
    end

    MIN_YEAR_SPACE = 20
    REFERENCE_YEAR = Time.now.year

    def self.regex_guesses(match)
      char_class_bases = {
        alpha_lower: 26,
        alpha_upper: 26,
        alpha: 52,
        alphanumeric: 62,
        digits: 10,
        symbols: 33
      }
      if char_class_bases.has_key? match[:regex_name].to_sym
        return char_class_bases[match[:regex_name].to_sym] ** match[:token].length
      elsif match[:regex_name] == 'recent_year'
        # conservative estimate of year space: num years from REFERENCE_YEAR.
        # if year is close to REFERENCE_YEAR, estimate a year space of MIN_YEAR_SPACE.
        year_space = (match[:regex_match[0]].to_i - REFERENCE_YEAR).abs
        year_space = [year_space, MIN_YEAR_SPACE].max
        return year_space
      end
    end

    def self.date_guesses(match)
      # base guesses: (year distance from REFERENCE_YEAR) * num_days * num_years
      year_space = [(match[:year] - REFERENCE_YEAR).abs, MIN_YEAR_SPACE].max
      guesses = year_space * 365
      if match[:separator]
        # add factor of 4 for separator selection (one of ~4 choices)
        guesses *= 4
      end
      return guesses
    end

    KEYBOARD_AVERAGE_DEGREE = calc_average_degree(ADJACENCY_GRAPHS[:qwerty])
    # slightly different for keypad/mac keypad, but close enough
    KEYPAD_AVERAGE_DEGREE = calc_average_degree(ADJACENCY_GRAPHS[:keypad])

    KEYBOARD_STARTING_POSITIONS = ADJACENCY_GRAPHS[:qwerty].keys.size
    KEYPAD_STARTING_POSITIONS = ADJACENCY_GRAPHS[:keypad].keys.size

    def self.spatial_guesses(match)
      if ['qwerty', 'dvorak'].include?(match[:graph])
        s = KEYBOARD_STARTING_POSITIONS;
        d = KEYBOARD_AVERAGE_DEGREE;
      else
        s = KEYPAD_STARTING_POSITIONS;
        d = KEYPAD_AVERAGE_DEGREE;
      end
      guesses = 0
      ll = match[:token].length
      t = match[:turns]
      # estimate the number of possible patterns w/ length ll or less with t turns or less.
      (2..ll).each do |i|
        possible_turns = [t, i - 1].min
        (1..possible_turns).each do |j|
          guesses += nCk(i - 1, j - 1) * s * (d ** j)
        end
      end
      # add extra guesses for shifted keys. (% instead of 5, A instead of a.)
      # math is similar to extra guesses of l33t substitutions in dictionary matches.
      if match[:shifted_count]
        ss = match[:shifted_count]
        uu = match[:token].length - match[:shifted_count] # unshifted count
        if ss == 0 || uu == 0
          guesses *= 2
        else
          shifted_variations = 0
          (1..[ss, uu].min).each do |i|
            shifted_variations += nCk(ss + uu, i)
          end
          guesses *= shifted_variations
        end
      end
      return guesses
    end

    def self.dictionary_guesses(match)
      match[:base_guesses] = match[:rank] # keep these as properties for display purposes
      match[:uppercase_variations] = uppercase_variations(match)
      match[:l33t_variations] = l33t_variations(match)
      reversed_variations = match[:reversed] && 2 || 1
      return match[:base_guesses] * match[:uppercase_variations] * match[:l33t_variations] * reversed_variations
    end

    START_UPPER = /^[A-Z][^A-Z]+$/
    END_UPPER = /^[^A-Z]+[A-Z]$/
    ALL_UPPER = /^[^a-z]+$/
    ALL_LOWER = /^[^A-Z]+$/

    def self.uppercase_variations(match)
      word = match[:token]
      if word.match?(ALL_LOWER) || word.downcase === word
        return 1
      end
      # a capitalized word is the most common capitalization scheme,
      # so it only doubles the search space (uncapitalized + capitalized).
      # allcaps and end-capitalized are common enough too, underestimate as 2x factor to be safe.
      [START_UPPER, END_UPPER, ALL_UPPER].each do |regex|
        if word.match?(regex)
          return 2
        end
      end
      # otherwise calculate the number of ways to capitalize U+L uppercase+lowercase letters
      # with U uppercase letters or less. or, if there's more uppercase than lower (for eg. PASSwORD),
      # the number of ways to lowercase U+L letters with L lowercase letters or less.
      uu = word.split("").count{|chr| chr.match?(/[A-Z]/)}
      ll = word.split("").count{|chr| chr.match?(/[a-z]/)}
      variations = 0;
      (1..[uu, ll].min).each do |i|
        variations += nCk(uu + ll, i)
      end
      return variations
    end

    def self.l33t_variations(match)
      if !match[:l33t]
        return 1
      end
      variations = 1
      match[:sub].each do |subbed, unsubbed|
        # lower-case match.token before calculating: capitalization shouldn't affect l33t calc.
        chrs = match[:token].downcase.split('')
        ss = chrs.count{|chr| chr == subbed }
        uu = chrs.count{|chr| chr == unsubbed }
        if ss == 0 || uu == 0
          # for this sub, password is either fully subbed (444) or fully unsubbed (aaa)
          # treat that as doubling the space (attacker needs to try fully subbed chars in addition to
          # unsubbed.)
          variations *= 2
        else
          # this case is similar to capitalization:
          # with aa44a, uu = 3, ss = 2, attacker needs to try unsubbed + one sub + two subs
          p = [uu, ss].min
          possibilities = 0
          (1..p).each do |i|
            possibilities += nCk(uu + ss, i)
          end
          variations *= possibilities
        end
      end
      return variations
    end
  end
end
