module ResultHelpers
  def strip_log10(result)
    if result.is_a?(Hash)
      result.reject!{|k, v| ["guesses_log10", "calc_time"].include?(k) }
      (result["sequence"] || []).each do |m|
        m.reject!{|k, v| k == "guesses_log10"}
      end
    else
      result.each do |m|
        (m["base_matches"] || []).each do |bm|
          bm.reject!{|k, v| k == "guesses_log10"}
        end
      end
    end
    result
  end
end
