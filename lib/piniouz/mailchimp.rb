require 'gibbon'
require 'launchy'

module Piniouz

  class Mailchimp

    attr_reader :conf

    def initialize(conf)
      @conf = conf
    end

    def api
      @api ||= ::Gibbon::API.new(self.conf['api_key'])
    end

    # get last campaign infos
    def last_campaign
      # @todo !!!
      raise "not implemented"
    end

    def create_campaign(subject, html)
      Piniouz.log("Creating mailchimp campaign: #{subject}")

      options = self.conf['campaign_options'].merge({
        :subject => subject,
      })

      result = self.api.campaigns.create({
        :type    => "regular",
        :options => options,
        :content => {
          :html => html,
        },
      })

      Piniouz.log("result: #{result}")

      web_url = "https://us9.admin.mailchimp.com/campaigns/wizard/confirm?id=#{result['web_id']}"

      puts
      puts "Campaign '#{result['title']}' created, you can review it and send it here:"
      puts

      puts "**********************************************************************"
      puts "* #{web_url}"
      puts "**********************************************************************"

      Launchy.open(web_url)
    end

  end # class Mailchimp

end # module Piniouz
