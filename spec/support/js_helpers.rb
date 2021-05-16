require 'mini_racer'
require 'json'

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
end
