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

    # Returns a Hash: { '<tag>': [ <pin>, <pin>...], ... }
    def fetch_pins(anchor)
      result = { }

      Piniouz.log("Fetching new pinboard pins since #{anchor}")

      posts = self.client.posts({
        :tag    => "#{self.conf['master_tag']}",
        :fromdt => anchor,
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
      categories = [ ]

      # @todo This is so bad to rely on ordering of a hash... but I am so lazy right now
      self.conf['cat_tags'].keys.each do |cat_id|
        if pins[cat_id]
          categories << {
            'name' => self.conf['cat_tags'][cat_id],
            'pins' => pins[cat_id].map(&:to_hash),
          }
        end
      end

      {
        'categories' => categories,
      }
    end

  end # class Pinboard

end # module Piniouz
