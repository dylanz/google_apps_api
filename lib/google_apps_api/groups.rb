#!/usr/bin/ruby

module GoogleAppsApi #:nodoc:
  module Groups
    class Api < GoogleAppsApi::BaseApi
      attr_reader :token

      def initialize(*args)
        super(:provisioning, *args)
      end

      def retrieve_group(group, *args)
        username = group.kind_of?(GroupEntity) ? group.id : group

        options = args.extract_options!.merge(:username => username)
        request(:retrieve_user, options)
      end

      class GroupEntity < Entity
        attr_accessor :group_id, :groupName, :emailPermission, :description

        def initialize(*args)
          options = args.extract_options!
          if (_xml = options[:xml])

            require 'ruby-debug'; debugger

            xml = _xml.at_css("entry") || _xml
            @kind = "user"
            @id = xml.at_css("apps|login").attribute("id").content
            @domain = xml.at_css("id").content.gsub(/^.+\/feeds\/([^\/]+)\/.+$/,"\\1")

            @group_name = xml.at_css("apps|name").attribute("groupName").content

            @given_name = xml.at_css("apps|name").attribute("givenName").content
            @family_name = xml.at_css("apps|name").attribute("familyName").content
            @suspended = xml.at_css("apps|login").attribute("suspended").content
            @ip_whitelisted = xml.at_css("apps|login").attribute("ipWhitelisted").content
            @admin = xml.at_css("apps|login").attribute("admin").content
            @change_password_at_next_login = xml.at_css("apps|login").attribute("changePasswordAtNextLogin").content
            @agreed_to_terms = xml.at_css("apps|login").attribute("agreedToTerms").content
            @quota_limit = xml.at_css("apps|quota").attribute("limit").content
          else
            if args.first.kind_of?(String)
              super(:user => args.first)
            else
              super(options.merge(:kind => "group"))
            end
          end
        end

        def entity_for_base_calendar
          CalendarEntity.new(self.full_id)
        end

        def get_base_calendar(c_api, *args)
          c_api.retrieve_calendar_for_user(self.entity_for_base_calendar, self, *args)
        end

        def get_calendars(c_api, *args)
          c_api.retrieve_calendars_for_user(self, *args)
        end
      end
    end
  end
end
