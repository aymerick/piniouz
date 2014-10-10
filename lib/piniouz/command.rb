require 'time'

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

    def compute_anchor!(last_campaign = nil)
      # use last_campaign as an anchor
      last_create_time = last_campaign ? Time.parse(last_campaign['create_time']) : nil

      Piniouz.log("Last newsletter created at: #{last_create_time}")

      now = Time.now.utc
      last_week  = now - (60 * 60 * 24 * 7)

      # compute anchor
      anchor = last_create_time || last_week

      one_month = (60 * 60 * 24 * 7 * 31)
      if (now - anchor) > one_month
        # don't go too far in the past
        anchor = now - one_month

        puts "WARNING: last mail was sent more than one month ago... so this one will be a monthly newsletter"
      end

      raise "\n\nERROR: Previous newsletter was sent less than a week ago: #{anchor}\n\n" if (anchor > last_week)

      anchor
    end

    def compute_issue_number(last_campaign = nil)
      if !last_campaign
        1
      else
        /#.+$/.match(last_campaign['subject'])[0].gsub('#', '').to_i + 1
      end
    end

    # create newsletter
    def create
      Piniouz.log("Creating newsletter: #{self.options.inspect}")

      # fetch last campaign
      mailchimp = Mailchimp.new(self.conf_file['mailchimp'])
      last_campaign = mailchimp.fetch_last_campaign

      Piniouz.log("Last campaign: #{last_campaign.inspect}")

      # compute anchor
      anchor = self.compute_anchor!(last_campaign)

      # fetch pinboard feeds
      pinboard = Pinboard.new(self.conf_file['pinboard'])
      pins = pinboard.fetch_pins(anchor)

      Piniouz.log("Fetched pins: #{pins.inspect}")

      if pins.size == 0
        puts "No new pins since #{anchor}"
      else
        # build newsletter HTML
        template = Template.new({ })
        ctx = self.conf_file['newsletter'].merge(pinboard.format_context(pins))

        html = template.build(ctx)
        Piniouz.log("html: #{html}")

        # create newsletter on mailchimp
        subject = "#{self.conf_file['newsletter']['name']} Weekly ##{self.compute_issue_number(last_campaign)}"
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
