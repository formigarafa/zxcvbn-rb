# frozen_string_literal: true

module ResultHelpers
  def strip_log10(result)
    if result.is_a?(Hash)
      result.reject! do |k, _v|
        ["guesses_log10", "calc_time", "crack_times_seconds", "crack_times_display"].include?(k)
      end
      (result["sequence"] || []).each do |m|
        m.reject! { |k, _v| k == "guesses_log10" }
        (m["base_matches"] || []).each do |bm|
          bm.reject! { |k, _v| k == "guesses_log10" }
        end
        (m["base_matches"] || []).uniq!
      end
      (result["sequence"] || []).uniq!
    else
      result.map do |m|
        (m["base_matches"] || []).each do |bm|
          bm.reject! { |k, _v| k == "guesses_log10" }
        end
        (m["base_matches"] || []).uniq!
        m.reject! { |k, _v| k == "sub_display" }
      end
      result.uniq!
    end
    result
  end
end
