require 'pinboard'

module Piniouz

  class Pinboard

    # default category tag
    DEFAULT_CAT_TAG = 'misc'

    attr_reader :conf

    def initialize(conf)
      @conf = conf
    end

    def client
      @client ||= ::Pinboard::Client.new(:token => "#{self.conf['username']}:#{self.conf['auth_token']}")
    end

    def anchor
      # @todo Check previous saved anchor

      # one week ago
      @anchor ||= Time.now.utc - (60 * 60 * 24 * 7)
    end

    # Returns a Hash: { '<tag>': [ <pin>, <pin>...], ... }
    def fetch_pins
      result = { }

      Piniouz.log("Fetching pins from pinboard api")

      posts = self.client.posts({
        :tag    => "#{self.conf['master_tag']}",
        :fromdt => self.anchor,
      })

      category_tags = self.conf['cat_tags'].keys

      posts.each do |post|
        pin_category = (post.tag & category_tags).first
        pin_category ||= self.conf['default_cat_tag'] || DEFAULT_CAT_TAG

        pin = Piniouz::Pin.new(post.href, post.description, post.extended)

        Piniouz.log("#{pin_category} Pin at #{post.time}: #{pin.inspect}")

        result[pin_category] ||= [ ]
        result[pin_category] << pin
      end

      result
    end

    def format_context(pins)
      categories = pins.to_a.map do |(cat_id, pins)|
        {
          'name' => self.conf['cat_tags'][cat_id],
          'pins' => pins.map(&:to_hash)
        }
      end

      {
        'categories' => categories,
      }
    end

  end # class Pinboard

end # module Piniouz
