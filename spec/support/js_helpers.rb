# frozen_string_literal: true

require "mini_racer"
require "json"
require "digest"

module JsHelpers
  def js_ctx
    @js_ctx ||= begin
      ctx = MiniRacer::Context.new
      js_source_path = Pathname(File.expand_path("js_source", __dir__))
      ctx.eval(js_source_path.join("zxcvbn.js").read)
      ctx
    end
  end

  def js_omnimatch(password)
    cached_eval(%{matching.omnimatch("#{password.gsub('"', '\"')}")})
  end

  def js_matcher(matcher, password)
    cached_eval(%{matching['#{matcher}']("#{password.gsub('"', '\"')}")})
  end

  def js_zxcvbn(password)
    cached_eval(%{zxcvbn("#{password.gsub('"', '\"')}")})
  end

  def js_most_guessable_match_sequence(password, matches)
    json_matches = matches.to_json
    cached_eval(%{scoring.most_guessable_match_sequence("#{password.gsub('"', '\"')}", #{json_matches})})
  end

  def js_estimate_guesses(match, password)
    json_matches = match.to_json
    cached_eval(%{scoring.estimate_guesses(#{json_matches}, "#{password.gsub('"', '\"')}")})
  end

  def cached_eval(js_str)
    tmp_hash = Digest::MD5.hexdigest(js_str.to_s)
    cache_name = Pathname(File.expand_path("../../../tmp/#{tmp_hash}.json", __FILE__))
    if File.exist?(cache_name)
      JSON.parse(File.read(cache_name))
    else
      uncached_result = js_ctx.eval(js_str)
      FileUtils.mkdir_p(Pathname(File.expand_path("..", cache_name)))
      File.write(cache_name, uncached_result.to_json)
      uncached_result
    end
  end
end
