module ResultHelpers
  def strip_log10(result)
    result.reject!{|k, v| ["guesses_log10", "calc_time"].include?(k) }
    (result["sequence"] || []).map do |m|
      m.reject!{|k, v| k == "guesses_log10"}
    end
    result
  end
end
