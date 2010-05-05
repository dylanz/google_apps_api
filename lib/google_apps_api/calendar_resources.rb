#!/usr/bin/ruby
include REXML



module GoogleAppsApi #:nodoc:
  module CalendarResources
    class Api < BaseApi
      attr_reader :token

      def initialize(*args)
        begin
          action_list = {
            :domain_login => [:post, ":auth:/accounts/ClientLogin"],
            :retrieve_all_resources => [:get, ":feed_basic:/"],
          }
        end
      
      
        options = args.extract_options!
      
        domain = options[:domain]
      
        options.merge!(:action_hash => action_list, :auth => "https://www.google.com", :feed => "https://apps-apis.google.com", :service => "apps")
        options[:feed_basic] = options[:feed]+ "/a/feeds/calendar/resource/2.0/#{domain}"
      
        super(options)
      end
    end


  end

end
