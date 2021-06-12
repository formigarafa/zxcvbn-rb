# frozen_string_literal: true

module ResultHelpers
  # strips data where the architectures produce minor differences in precision,
  # like infinitesimals floats and data calculated from it.
  # these item are calculated based on other properties exposed on the result
  # so the test is still valid. for example: guesses_log10 is based on guesses.
  # and calc_time changes on every run so it is not comparable.
  def strip_precision(result)
    if result.is_a?(Hash)
      result.reject! do |k, _v|
        ["guesses_log10", "calc_time", "crack_times_seconds", "crack_times_display"].include?(k)
      end
      (result["sequence"] || []).each do |m|
        m.reject! { |k, _v| k == "guesses_log10" }
        (m["base_matches"] || []).each do |bm|
          bm.reject! { |k, _v| k == "guesses_log10" }
        end
      end
    else
      result.map do |m|
        (m["base_matches"] || []).each do |bm|
          bm.reject! { |k, _v| k == "guesses_log10" }
        end
        m.reject! { |k, _v| k == "sub_display" }
      end
      result.uniq!
    end
    result
  end
end
