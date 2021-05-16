require 'mini_racer'
require 'json'
require 'digest'

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
    js_ctx.eval(%Q{matching.omnimatch("#{password.gsub('"', '\"')}")})
  end

  def js_matcher(matcher, password)
    cached_eval(%Q{matching['#{matcher}']("#{password.gsub('"', '\"')}")})
  end

  def cached_eval(js_str)
    tmp_hash = Digest::MD5.base64digest js_str.to_s
    cache_name = Pathname(File.expand_path("../../../tmp/#{tmp_hash}.json", __FILE__))
    if File.exists?(cache_name)
      JSON.parse(File.read(cache_name))
    else
      uncached_result = js_ctx.eval(js_str)
      if !File.exists?(Pathname(File.expand_path("../../../tmp", __FILE__)))
        Dir.mkdir Pathname(File.expand_path("../../../tmp", __FILE__))
      end
      File.write(cache_name, uncached_result)
      uncached_result
    end
  end
end
