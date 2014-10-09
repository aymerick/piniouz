require 'uri'

module Piniouz

  class Pin

    attr_accessor :url, :title, :description

    def initialize(url, title, description)
      @url = url
      @title = title
      @description = description
    end

    def origin
      URI(self.url).host.sub(/^www\./, '')
    end

    def to_hash
      {
        'url' => self.url,
        'title' => self.title,
        'description' => self.description,
        'origin' => self.origin,
      }
    end

  end # class Pin

end # module Piniouz
