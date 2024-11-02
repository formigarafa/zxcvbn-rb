# frozen_string_literal: true

module Zxcvbn
  def self.frequency_lists
    ["passwords", "english_wikipedia", "female_names", "surnames", "us_tv_and_film", "male_names"].each_with_object({}) do |n, o|
      o[n] = file_enumerator(File.expand_path("../frequency_lists/#{n}.txt", __FILE__))
    end
  end

  def self.file_enumerator(filename)
    Enumerator.new do |main_enum|
      File.open(filename) do |f|
        f.each_line do |line|
          next if line.nil?

          main_enum << line.strip!.freeze
        end
      end
    end
  end
end
