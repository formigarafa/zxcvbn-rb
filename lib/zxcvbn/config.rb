module Zxcvbn
  module Config
    def add_dictionary(path)
      data = File.read(path, encoding: "UTF-8")
      lines = data.each_line(chomp: true).map { |l| l.strip }.reject(&:empty?)
      name = File.basename(path, ".*")
      ranked = Zxcvbn::Matching.new.build_ranked_dict(lines)
      Zxcvbn::Matching.register_dictionary(name, ranked)
    end

    module_function :add_dictionary
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
