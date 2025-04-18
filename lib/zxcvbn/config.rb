module Zxcvbn
  module Config
    extend self

    def add_dictionary(path)
      data = File.read(path)
      lines = data.split("\n").map(&:strip)
      filename = File.basename(path, ".*")
      new_ranked_dictionary = Hash[filename, Zxcvbn::Matching.build_ranked_dict(lines.join(",").split(","))]
      Zxcvbn::Matching::RANKED_DICTIONARIES.merge! new_ranked_dictionary
    end
  end

  class << self
    def configure
      block_given? ? yield(Config) : Config
    end

    def config
      Config
    end
  end
end
