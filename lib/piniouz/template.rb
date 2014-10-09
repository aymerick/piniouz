require 'mustache'

module Piniouz

  class Template

    TEMPLATE_FILE = "template.html"

    attr_reader :options

    def initialize(options = { })
      @options = options

      Mustache.template_path = File.expand_path(File.dirname(__FILE__))
    end

    def build(context)
      Mustache.render_file(TEMPLATE_FILE, context)
    end

  end # class Template

end # module Piniouz
