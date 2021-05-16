module ResultHelpers
  def strip_log10(result)
    if result.is_a?(Hash)
      result.reject!{|k, v| ["guesses_log10", "calc_time"].include?(k) }
      (result["sequence"] || []).each do |m|
        m.reject!{|k, v| k == "guesses_log10"}
      end
      (result["sequence"] || []).uniq!
    else
      result.map do |m|
        (m["base_matches"] || []).each do |bm|
          bm.reject!{|k, v| k == "guesses_log10"}
        end
        (m["base_matches"] || []).uniq!
        m.reject!{|k, v| k == "sub_display" }
      end
      result.uniq!
    end
    result
  end
end
