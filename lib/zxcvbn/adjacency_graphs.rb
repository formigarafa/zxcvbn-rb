# frozen_string_literal: true

# generated by scripts/build_keyboard_adjacency_graphs.py
module Zxcvbn
  # rubocop:disable Layout/SpaceInsideArrayLiteralBrackets
  # rubocop:disable Layout/ExtraSpacing
  ADJACENCY_GRAPHS = {
    "qwerty" => {
      "!" => ["`~",  nil,  nil, "2@", "qQ",  nil],
      "\"" => [";:", "[{", "]}", nil,  nil, "/?"],
      "#" => ["2@",  nil,  nil, "4$", "eE", "wW"],
      "$" => ["3#",  nil,  nil, "5%", "rR", "eE"],
      "%" => ["4$",  nil,  nil, "6^", "tT", "rR"],
      "&" => ["6^",  nil,  nil, "8*", "uU", "yY"],
      "'" => [";:", "[{", "]}",  nil,  nil, "/?"],
      "(" => ["8*",  nil,  nil, "0)", "oO", "iI"],
      ")" => ["9(",  nil,  nil, "-_", "pP", "oO"],
      "*" => ["7&",  nil,  nil, "9(", "iI", "uU"],
      "+" => ["-_",  nil,  nil,  nil, "]}", "[{"],
      "," => ["mM", "kK", "lL", ".>",  nil,  nil],
      "-" => ["0)",  nil,  nil, "=+", "[{", "pP"],
      "." => [",<", "lL", ";:", "/?",  nil,  nil],
      "/" => [".>", ";:", "'\"", nil,  nil,  nil],
      "0" => ["9(",  nil,  nil, "-_", "pP", "oO"],
      "1" => ["`~",  nil,  nil, "2@", "qQ",  nil],
      "2" => ["1!",  nil,  nil, "3#", "wW", "qQ"],
      "3" => ["2@",  nil,  nil, "4$", "eE", "wW"],
      "4" => ["3#",  nil,  nil, "5%", "rR", "eE"],
      "5" => ["4$",  nil,  nil, "6^", "tT", "rR"],
      "6" => ["5%",  nil,  nil, "7&", "yY", "tT"],
      "7" => ["6^",  nil,  nil, "8*", "uU", "yY"],
      "8" => ["7&",  nil,  nil, "9(", "iI", "uU"],
      "9" => ["8*",  nil,  nil, "0)", "oO", "iI"],
      ":" => ["lL", "pP", "[{", "'\"", "/?", ".>"],
      ";" => ["lL", "pP", "[{", "'\"", "/?", ".>"],
      "<" => ["mM", "kK", "lL", ".>",  nil,  nil],
      "=" => ["-_",  nil,  nil,  nil, "]}", "[{"],
      ">" => [",<", "lL", ";:", "/?",  nil,  nil],
      "?" => [".>", ";:", "'\"", nil,  nil,  nil],
      "@" => ["1!",  nil,  nil, "3#", "wW", "qQ"],
      "A" => [ nil, "qQ", "wW", "sS", "zZ",  nil],
      "B" => ["vV", "gG", "hH", "nN",  nil,  nil],
      "C" => ["xX", "dD", "fF", "vV",  nil,  nil],
      "D" => ["sS", "eE", "rR", "fF", "cC", "xX"],
      "E" => ["wW", "3#", "4$", "rR", "dD", "sS"],
      "F" => ["dD", "rR", "tT", "gG", "vV", "cC"],
      "G" => ["fF", "tT", "yY", "hH", "bB", "vV"],
      "H" => ["gG", "yY", "uU", "jJ", "nN", "bB"],
      "I" => ["uU", "8*", "9(", "oO", "kK", "jJ"],
      "J" => ["hH", "uU", "iI", "kK", "mM", "nN"],
      "K" => ["jJ", "iI", "oO", "lL", ",<", "mM"],
      "L" => ["kK", "oO", "pP", ";:", ".>", ",<"],
      "M" => ["nN", "jJ", "kK", ",<",  nil,  nil],
      "N" => ["bB", "hH", "jJ", "mM",  nil,  nil],
      "O" => ["iI", "9(", "0)", "pP", "lL", "kK"],
      "P" => ["oO", "0)", "-_", "[{", ";:", "lL"],
      "Q" => [ nil, "1!", "2@", "wW", "aA",  nil],
      "R" => ["eE", "4$", "5%", "tT", "fF", "dD"],
      "S" => ["aA", "wW", "eE", "dD", "xX", "zZ"],
      "T" => ["rR", "5%", "6^", "yY", "gG", "fF"],
      "U" => ["yY", "7&", "8*", "iI", "jJ", "hH"],
      "V" => ["cC", "fF", "gG", "bB",  nil,  nil],
      "W" => ["qQ", "2@", "3#", "eE", "sS", "aA"],
      "X" => ["zZ", "sS", "dD", "cC",  nil,  nil],
      "Y" => ["tT", "6^", "7&", "uU", "hH", "gG"],
      "Z" => [ nil, "aA", "sS", "xX",  nil,  nil],
      "[" => ["pP", "-_", "=+", "]}", "'\"", ";:"],
      "\\" => ["]}", nil,  nil,  nil,  nil,  nil],
      "]" => ["[{", "=+",  nil, "\\|", nil, "'\""],
      "^" => ["5%",  nil,  nil, "7&", "yY", "tT"],
      "_" => ["0)",  nil,  nil, "=+", "[{", "pP"],
      "`" => [ nil,  nil,  nil, "1!",  nil,  nil],
      "a" => [ nil, "qQ", "wW", "sS", "zZ",  nil],
      "b" => ["vV", "gG", "hH", "nN",  nil,  nil],
      "c" => ["xX", "dD", "fF", "vV",  nil,  nil],
      "d" => ["sS", "eE", "rR", "fF", "cC", "xX"],
      "e" => ["wW", "3#", "4$", "rR", "dD", "sS"],
      "f" => ["dD", "rR", "tT", "gG", "vV", "cC"],
      "g" => ["fF", "tT", "yY", "hH", "bB", "vV"],
      "h" => ["gG", "yY", "uU", "jJ", "nN", "bB"],
      "i" => ["uU", "8*", "9(", "oO", "kK", "jJ"],
      "j" => ["hH", "uU", "iI", "kK", "mM", "nN"],
      "k" => ["jJ", "iI", "oO", "lL", ",<", "mM"],
      "l" => ["kK", "oO", "pP", ";:", ".>", ",<"],
      "m" => ["nN", "jJ", "kK", ",<",  nil,  nil],
      "n" => ["bB", "hH", "jJ", "mM",  nil,  nil],
      "o" => ["iI", "9(", "0)", "pP", "lL", "kK"],
      "p" => ["oO", "0)", "-_", "[{", ";:", "lL"],
      "q" => [ nil, "1!", "2@", "wW", "aA",  nil],
      "r" => ["eE", "4$", "5%", "tT", "fF", "dD"],
      "s" => ["aA", "wW", "eE", "dD", "xX", "zZ"],
      "t" => ["rR", "5%", "6^", "yY", "gG", "fF"],
      "u" => ["yY", "7&", "8*", "iI", "jJ", "hH"],
      "v" => ["cC", "fF", "gG", "bB",  nil,  nil],
      "w" => ["qQ", "2@", "3#", "eE", "sS", "aA"],
      "x" => ["zZ", "sS", "dD", "cC",  nil,  nil],
      "y" => ["tT", "6^", "7&", "uU", "hH", "gG"],
      "z" => [ nil, "aA", "sS", "xX",  nil,  nil],
      "{" => ["pP", "-_", "=+", "]}", "'\"", ";:"],
      "|" => ["]}",  nil,  nil,  nil,  nil,  nil],
      "}" => ["[{", "=+",  nil, "\\|", nil, "'\""],
      "~" => [ nil,  nil,  nil, "1!",  nil,  nil]
    },
    "dvorak" => {
      "!" => ["`~",  nil,  nil, "2@", "'\"", nil],
      "\"" => [ nil, "1!", "2@", ",<", "aA", nil],
      "#" => ["2@",  nil,  nil, "4$", ".>", ",<"],
      "$" => ["3#",  nil,  nil, "5%", "pP", ".>"],
      "%" => ["4$",  nil,  nil, "6^", "yY", "pP"],
      "&" => ["6^",  nil,  nil, "8*", "gG", "fF"],
      "'" => [ nil, "1!", "2@", ",<", "aA",  nil],
      "(" => ["8*",  nil,  nil, "0)", "rR", "cC"],
      ")" => ["9(",  nil,  nil, "[{", "lL", "rR"],
      "*" => ["7&",  nil,  nil, "9(", "cC", "gG"],
      "+" => ["/?", "]}",  nil, "\\|", nil, "-_"],
      "," => ["'\"", "2@", "3#", ".>", "oO", "aA"],
      "-" => ["sS", "/?", "=+",  nil,  nil, "zZ"],
      "." => [",<", "3#", "4$", "pP", "eE", "oO"],
      "/" => ["lL", "[{", "]}", "=+", "-_", "sS"],
      "0" => ["9(",  nil,  nil, "[{", "lL", "rR"],
      "1" => ["`~",  nil,  nil, "2@", "'\"", nil],
      "2" => ["1!",  nil,  nil, "3#", ",<", "'\""],
      "3" => ["2@",  nil,  nil, "4$", ".>", ",<"],
      "4" => ["3#",  nil,  nil, "5%", "pP", ".>"],
      "5" => ["4$",  nil,  nil, "6^", "yY", "pP"],
      "6" => ["5%",  nil,  nil, "7&", "fF", "yY"],
      "7" => ["6^",  nil,  nil, "8*", "gG", "fF"],
      "8" => ["7&",  nil,  nil, "9(", "cC", "gG"],
      "9" => ["8*",  nil,  nil, "0)", "rR", "cC"],
      ":" => [ nil, "aA", "oO", "qQ",  nil,  nil],
      ";" => [ nil, "aA", "oO", "qQ",  nil,  nil],
      "<" => ["'\"", "2@", "3#", ".>", "oO", "aA"],
      "=" => ["/?", "]}",  nil, "\\|",  nil, "-_"],
      ">" => [",<", "3#", "4$", "pP", "eE", "oO"],
      "?" => ["lL", "[{", "]}", "=+", "-_", "sS"],
      "@" => ["1!",  nil,  nil, "3#", ",<", "'\""],
      "A" => [ nil, "'\"", ",<", "oO", ";:", nil],
      "B" => ["xX", "dD", "hH", "mM",  nil,  nil],
      "C" => ["gG", "8*", "9(", "rR", "tT", "hH"],
      "D" => ["iI", "fF", "gG", "hH", "bB", "xX"],
      "E" => ["oO", ".>", "pP", "uU", "jJ", "qQ"],
      "F" => ["yY", "6^", "7&", "gG", "dD", "iI"],
      "G" => ["fF", "7&", "8*", "cC", "hH", "dD"],
      "H" => ["dD", "gG", "cC", "tT", "mM", "bB"],
      "I" => ["uU", "yY", "fF", "dD", "xX", "kK"],
      "J" => ["qQ", "eE", "uU", "kK",  nil,  nil],
      "K" => ["jJ", "uU", "iI", "xX",  nil,  nil],
      "L" => ["rR", "0)", "[{", "/?", "sS", "nN"],
      "M" => ["bB", "hH", "tT", "wW",  nil,  nil],
      "N" => ["tT", "rR", "lL", "sS", "vV", "wW"],
      "O" => ["aA", ",<", ".>", "eE", "qQ", ";:"],
      "P" => [".>", "4$", "5%", "yY", "uU", "eE"],
      "Q" => [";:", "oO", "eE", "jJ",  nil,  nil],
      "R" => ["cC", "9(", "0)", "lL", "nN", "tT"],
      "S" => ["nN", "lL", "/?", "-_", "zZ", "vV"],
      "T" => ["hH", "cC", "rR", "nN", "wW", "mM"],
      "U" => ["eE", "pP", "yY", "iI", "kK", "jJ"],
      "V" => ["wW", "nN", "sS", "zZ",  nil,  nil],
      "W" => ["mM", "tT", "nN", "vV",  nil,  nil],
      "X" => ["kK", "iI", "dD", "bB",  nil,  nil],
      "Y" => ["pP", "5%", "6^", "fF", "iI", "uU"],
      "Z" => ["vV", "sS", "-_",  nil,  nil,  nil],
      "[" => ["0)",  nil,  nil, "]}", "/?", "lL"],
      "\\" => ["=+", nil,  nil,  nil,  nil,  nil],
      "]" => ["[{",  nil,  nil,  nil, "=+", "/?"],
      "^" => ["5%",  nil,  nil, "7&", "fF", "yY"],
      "_" => ["sS", "/?", "=+",  nil,  nil, "zZ"],
      "`" => [ nil,  nil,  nil, "1!",  nil,  nil],
      "a" => [ nil, "'\"", ",<", "oO", ";:", nil],
      "b" => ["xX", "dD", "hH", "mM",  nil,  nil],
      "c" => ["gG", "8*", "9(", "rR", "tT", "hH"],
      "d" => ["iI", "fF", "gG", "hH", "bB", "xX"],
      "e" => ["oO", ".>", "pP", "uU", "jJ", "qQ"],
      "f" => ["yY", "6^", "7&", "gG", "dD", "iI"],
      "g" => ["fF", "7&", "8*", "cC", "hH", "dD"],
      "h" => ["dD", "gG", "cC", "tT", "mM", "bB"],
      "i" => ["uU", "yY", "fF", "dD", "xX", "kK"],
      "j" => ["qQ", "eE", "uU", "kK",  nil,  nil],
      "k" => ["jJ", "uU", "iI", "xX",  nil,  nil],
      "l" => ["rR", "0)", "[{", "/?", "sS", "nN"],
      "m" => ["bB", "hH", "tT", "wW",  nil,  nil],
      "n" => ["tT", "rR", "lL", "sS", "vV", "wW"],
      "o" => ["aA", ",<", ".>", "eE", "qQ", ";:"],
      "p" => [".>", "4$", "5%", "yY", "uU", "eE"],
      "q" => [";:", "oO", "eE", "jJ",  nil,  nil],
      "r" => ["cC", "9(", "0)", "lL", "nN", "tT"],
      "s" => ["nN", "lL", "/?", "-_", "zZ", "vV"],
      "t" => ["hH", "cC", "rR", "nN", "wW", "mM"],
      "u" => ["eE", "pP", "yY", "iI", "kK", "jJ"],
      "v" => ["wW", "nN", "sS", "zZ",  nil,  nil],
      "w" => ["mM", "tT", "nN", "vV",  nil,  nil],
      "x" => ["kK", "iI", "dD", "bB",  nil,  nil],
      "y" => ["pP", "5%", "6^", "fF", "iI", "uU"],
      "z" => ["vV", "sS", "-_",  nil,  nil,  nil],
      "{" => ["0)",  nil,  nil, "]}", "/?", "lL"],
      "|" => ["=+",  nil,  nil,  nil,  nil,  nil],
      "}" => ["[{",  nil,  nil,  nil, "=+", "/?"],
      "~" => [ nil,  nil,  nil, "1!",  nil,  nil]
    },
    "keypad" => {
      "*" => ["/", nil, nil, nil, "-", "+", "9", "8"],
      "+" => ["9", "*", "-", nil, nil, nil, nil, "6"],
      "-" => ["*", nil, nil, nil, nil, nil, "+", "9"],
      "." => ["0", "2", "3", nil, nil, nil, nil, nil],
      "/" => [nil, nil, nil, nil, "*", "9", "8", "7"],
      "0" => [nil, "1", "2", "3", ".", nil, nil, nil],
      "1" => [nil, nil, "4", "5", "2", "0", nil, nil],
      "2" => ["1", "4", "5", "6", "3", ".", "0", nil],
      "3" => ["2", "5", "6", nil, nil, nil, ".", "0"],
      "4" => [nil, nil, "7", "8", "5", "2", "1", nil],
      "5" => ["4", "7", "8", "9", "6", "3", "2", "1"],
      "6" => ["5", "8", "9", "+", nil, nil, "3", "2"],
      "7" => [nil, nil, nil, "/", "8", "5", "4", nil],
      "8" => ["7", nil, "/", "*", "9", "6", "5", "4"],
      "9" => ["8", "/", "*", "-", "+", nil, "6", "5"]
    },
    "mac_keypad" => {
      "*" => ["/", nil, nil, nil, nil, nil, "-", "9"],
      "+" => ["6", "9", "-", nil, nil, nil, nil, "3"],
      "-" => ["9", "/", "*", nil, nil, nil, "+", "6"],
      "." => ["0", "2", "3", nil, nil, nil, nil, nil],
      "/" => ["=", nil, nil, nil, "*", "-", "9", "8"],
      "0" => [nil, "1", "2", "3", ".", nil, nil, nil],
      "1" => [nil, nil, "4", "5", "2", "0", nil, nil],
      "2" => ["1", "4", "5", "6", "3", ".", "0", nil],
      "3" => ["2", "5", "6", "+", nil, nil, ".", "0"],
      "4" => [nil, nil, "7", "8", "5", "2", "1", nil],
      "5" => ["4", "7", "8", "9", "6", "3", "2", "1"],
      "6" => ["5", "8", "9", "-", "+", nil, "3", "2"],
      "7" => [nil, nil, nil, "=", "8", "5", "4", nil],
      "8" => ["7", nil, "=", "/", "9", "6", "5", "4"],
      "9" => ["8", "=", "/", "*", "-", "+", "6", "5"],
      "=" => [nil, nil, nil, nil, "/", "9", "8", "7"]
    }
  }.freeze
  # rubocop:enable Layout/ExtraSpacing
  # rubocop:enable Layout/SpaceInsideArrayLiteralBrackets
end
