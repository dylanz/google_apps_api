#!/usr/bin/ruby
include REXML



module GoogleAppsApi #:nodoc:

  module Calendar
    class Api < GoogleAppsApi::BaseApi
      attr_reader :token

      def initialize(*args)
        super(:calendar, *args)
      end

      def retrieve_user_settings(username)
        xml_response = request(:retrieve_user_settings, :username => username) 
      end

      def add_calendar_to_user(calendar, user)
        CalendarEntry.new(request(:add_calendar_to_user, :username => user, :body => calendar.add_message))
      end

      def delete_calendar_from_user(calendar, user)
        request(:delete_calendar_from_user, :username => user, :id => calendar.id)
      end
    end





  end

  class CalendarEntry
    attr_accessor :id, :title, :edit_link
    def initialize(xml = nil)
      if xml
        @id = xml.at_css('id').content.gsub(/^.*calendars\//,"")
        @title = xml.at_css('title').content
        @edit_link = xml.at_css('link[rel=edit]').attribute('href').value
      end
    end

    def to_s
      title
    end

    def inspect
      "<CalendarEntry: #{title} : #{id}, #{edit_link}>"
    end

    def add_message
      Nokogiri::XML::Builder.new { |xml|
        xml.entry(:xmlns => "http://www.w3.org/2005/Atom") {
          xml.id_ {
            xml.text id.to_s
          }
        }
      }.to_xml
    end
  end


end
