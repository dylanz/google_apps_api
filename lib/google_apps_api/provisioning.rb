#!/usr/bin/ruby

module GoogleAppsApi #:nodoc:
  module Provisioning
    class Api < GoogleAppsApi::BaseApi
      attr_reader :token


      def initialize(*args)
        super(:provisioning, *args)
      end

      def retrieve_user(user, *args)
        username = user.kind_of?(UserEntity) ? user.id : user
        options = args.extract_options!.merge(:username => username)
        request(:retrieve_user, options)
      end

      def retrieve_groups_for_user(user, *args)
        username = user.kind_of?(UserEntity) ? user.id : user
        options = args.extract_options!.merge(:username => user)
        request(:retrieve_groups_for_user, options)
      end

      def retrieve_all_users(*args)
        options = args.extract_options!
        request(:retrieve_all_users, options)
      end

      def create_user(username, *args)
        options = args.extract_options!
        options.each { |k,v| options[k] = escapeXML(v)}

        res = <<-DESCXML
        <?xml version="1.0" encoding="UTF-8"?>
        <atom:entry xmlns:atom="http://www.w3.org/2005/Atom"
        xmlns:apps="http://schemas.google.com/apps/2006">
        <atom:category scheme="http://schemas.google.com/g/2005#kind"
        term="http://schemas.google.com/apps/2006#user"/>
        <apps:login userName="#{escapeXML(username)}"
        password="#{options[:password]}" suspended="false"/>
        <apps:name familyName="#{options[:family_name]}" givenName="#{options[:given_name]}"/>
        </atom:entry>

        DESCXML

        request(:create_user, options.merge(:body => res.strip))
      end


      def update_user(username, *args)
        options = args.extract_options!
        options.each { |k,v| options[k] = escapeXML(v)}

        res = <<-DESCXML
        <?xml version="1.0" encoding="UTF-8"?>
        <atom:entry xmlns:atom="http://www.w3.org/2005/Atom"
        xmlns:apps="http://schemas.google.com/apps/2006">
        <atom:category scheme="http://schemas.google.com/g/2005#kind"
        term="http://schemas.google.com/apps/2006#user"/>
        <apps:name familyName="#{options[:family_name]}" givenName="#{options[:given_name]}"/>
        </atom:entry>

        DESCXML
        request(:update_user, options.merge(:username => username, :body => res.strip))
      end


      def delete_user(username, *args)
        options = args.extract_options!.merge(:username => username)
        request(:delete_user, options)
      end


    end

  end


  class UserEntity < Entity
    attr_accessor :given_name, :family_name, :username, :suspended, :ip_whitelisted, :admin, :change_password_at_next_login, :agreed_to_terms, :quota_limit, :domain

    def initialize(*args)
      options = args.extract_options!
      if (_xml = options[:xml])
        xml = _xml.at_css("entry") || _xml
        @kind = "user"
        @id = xml.at_css("apps|login").attribute("userName").content
        @domain = xml.at_css("id").content.gsub(/^.+\/feeds\/([^\/]+)\/.+$/,"\\1")

        @family_name = xml.at_css("apps|name").attribute("familyName").content
        @given_name = xml.at_css("apps|name").attribute("givenName").content
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
          super(options.merge(:kind => "user"))
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
