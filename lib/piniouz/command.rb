module Piniouz

  class Command

    attr_reader :name, :options

    def initialize(name, options = { })
      @name = name
      @options = options
    end

    # run command
    def run
      # beurk
      self.__send__(self.name)
    end

    # create newsletter
    def create
      Piniouz.log("Creating newsletter: #{self.options.inspect}")

      # fetch pinboard feeds
      pinboard = Pinboard.new(self.conf_file['pinboard'])
      pins = pinboard.fetch_pins

      Piniouz.log("Fetched pins: #{pins.inspect}")

      if pins.size == 0
        puts "No new pins since #{pinboard.anchor}"
      else
        # build newsletter HTML
        template = Template.new({ })
        ctx = self.conf_file['newsletter'].merge(pinboard.format_context(pins))

        html = template.build(ctx)
        Piniouz.log("html: #{html}")

        # create newsletter on mailchimp
        mailchimp = Mailchimp.new(self.conf_file['mailchimp'])

        # @todo Concatenate self.conf_file['newsletter']['name'] with new campaign number (and so check mailchimp.last_campaign)
        subject = "@todo"

        mailchimp.create_campaign(subject, html)
      end
    end

    def conf_file
      @conf_file ||= begin
        file_path = if !self.options[:conf_file].nil?
          raise "Conf file does not exists: #{self.options[:conf_file]}" unless File.exists?(self.options[:conf_file])
          self.options[:conf_file]
        elsif File.exists?(Piniouz.default_user_conf_file)
          Piniouz.default_user_conf_file
        elsif File.exists?(Piniouz.default_conf_file)
          Piniouz.default_conf_file
        else
          raise "No conf file found"
        end

        result = TOML.load_file(file_path)

        Piniouz.log("Parsed conf file at '#{file_path}': #{result}")

        result
      end
    end

  end # class Command

end # module Piniouz
