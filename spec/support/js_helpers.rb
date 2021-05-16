require 'mini_racer'
require 'json'

module JsHelpers
  def ctx
    @ctx ||= begin
      ctx = MiniRacer::Context.new
      js_source_path = Pathname(File.expand_path('../js_source/', __FILE__))
      ctx.eval(js_source_path.join('compiled.js').read)
      ctx
    end
  end

  def eval(js_str)
    ctx.eval(js_str)
  end
end
