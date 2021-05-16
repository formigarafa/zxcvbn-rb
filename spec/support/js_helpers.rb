require 'mini_racer'
require 'json'
require 'digest'
require 'base64'

module JsHelpers
  def js_ctx
    @js_ctx ||= begin
      ctx = MiniRacer::Context.new
      js_source_path = Pathname(File.expand_path('../js_source/', __FILE__))
      ctx.eval(js_source_path.join('zxcvbn.js').read)
      ctx
    end
  end

  def js_omnimatch(password)
    cached_eval(%Q{matching.omnimatch("#{password.gsub('"', '\"')}")})
  end

  def js_matcher(matcher, password)
    cached_eval(%Q{matching['#{matcher}']("#{password.gsub('"', '\"')}")})
  end

  def js_zxcvbn(password)
    cached_eval(%Q{zxcvbn("#{password.gsub('"', '\"')}")})
  end

  def js_most_guessable_match_sequence(password, matches)
    json_matches = matches.to_json
    js_ctx.eval(%Q{scoring.most_guessable_match_sequence("#{password.gsub('"', '\"')}", #{json_matches})})
  end

  def cached_eval(js_str)
    tmp_hash = Base64.urlsafe_encode64 Digest::MD5.digest(js_str.to_s), padding: false
    cache_name = Pathname(File.expand_path("../../../tmp/#{tmp_hash}.json", __FILE__))
    if File.exists?(cache_name)
      JSON.parse(File.read(cache_name))
    else
      uncached_result = js_ctx.eval(js_str)
      if !File.exists?(Pathname(File.expand_path("..", cache_name)))
        Dir.mkdir Pathname(File.expand_path("..", cache_name))
      end
      File.write(cache_name, uncached_result.to_json)
      uncached_result
    end
  end
end
