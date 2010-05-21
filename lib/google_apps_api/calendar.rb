 #!/usr/bin/ruby

module GoogleAppsApi #:nodoc:

  module Calendar
    class Api < GoogleAppsApi::BaseApi
      attr_reader :token

      def initialize(*args)
        super(:calendar, *args)
      end

      # def retrieve_user_settings(username, *args)
      #     options = args.extract_options!.merge(:username => username)
      #     xml_response = request(:retrieve_user_settings, options) 
      #   end
  
      # def add_calendar_to_user(calendar, user, *args)
      #   
      #   options = args.extract_options!.merge(:username => "_sc_api%40ocelot.cul.columbia.edu", :body => calendar.add_message)
      #   debugger
      #   request(:add_calendar_to_user, options)
      # end

      # def delete_calendar_from_user(calendar, user, *args)
      #   options = args.extract_options!.merge(:username => user.to_url, :calendar => calendar.to_url)
      #   request(:delete_calendar_from_user, options)
      # end

      def retrieve_calendars_for_user(user, *args)
        options = args.extract_options!.merge(:username => user.full_id_escaped)
        request(:retrieve_calendars_for_user, options)
      end
      
      # def retrieve_calendar_acl_for_user(calendar, scope_type, scope_id, *args)
      #   options = args.extract_options!.merge(:calendar => CGI::escape(calendar) ,:scope_type => CGI::escape(scope_type), :scope_id => CGI::escape(scope_id))
      #   begin
      #     request(:retrieve_calendar_acl_for_user, options)
      #   rescue GDataError => g
      #     if g.reason.include?("not found on the ACL")
      #       return CalendarAclEntry.new(:role => :none, :scope_type => scope_type, :scope_id => scope_id, :calendar_id => calendar)
      #     else
      #       raise g
      #     end
      #   end
      # end
      # 
      # def retrieve_acls_for_calendar(calendar, *args)
      #   options = args.extract_options!.merge(:calendar => calendar.to_url)
      #   request(:retrieve_acls_for_calendar, options)
      # end
      # 
      #     
      # def create_calendar_entry_acl(ce, *args)
      #   req = <<-DESCXML
      #   <?xml version="1.0" encoding="UTF-8"?>
      #   <entry xmlns='http://www.w3.org/2005/Atom' xmlns:gAcl='http://schemas.google.com/acl/2007'>
      #     <category scheme='http://schemas.google.com/g/2005#kind'
      #       term='http://schemas.google.com/acl/2007#accessRule'/>
      #     <gAcl:scope type='#{ce.entity.scope}' value='#{escapeXML(ce.entity.name_without_domain)}'></gAcl:scope>
      #     <gAcl:role
      #       value='http://schemas.google.com/gCal/2005##{escapeXML(ce.role)}'>
      #     </gAcl:role>
      #   </entry>
      #   DESCXML
      #   debugger
      #   options = args.extract_options!.merge(:calendar => ce.to_url, :body => req.strip) 
      #   request(:create_calendar_acl_for_user, options)
      # end
      # 
      # def remove_calendar_acl_for_user(calendar, username, *args)
      #   options = args.extract_options!.merge(:calendar => CGI::escape(calendar), :username => CGI::escape(username))
      #   request(:remove_calendar_acl_for_user, options)
      # end
      # 
      # def update_calendar_acl_for_user(calendar, role, username, *args)
      #   role_value = role.to_s == "none" ? "none" : "http://schemas.google.com/gCal/2005##{escapeXML(role.to_s)}"
      #   
      #   req = <<-DESCXML
      #   <?xml version="1.0" encoding="UTF-8"?>
      #   <entry xmlns='http://www.w3.org/2005/Atom' xmlns:gAcl='http://schemas.google.com/acl/2007'
      #   xmlns:gd='http://schemas.google.com/g/2005'
      #     gd:etag='W/"DU4ERH47eCp7ImA9WxRVEkQ."'>
      #     <category scheme='http://schemas.google.com/g/2005#kind'
      #       term='http://schemas.google.com/acl/2007#accessRule'/>
      #     <gAcl:scope type='user' value='#{escapeXML(username)}'></gAcl:scope>
      #     <gAcl:role
      #       value='#{role_value}'>
      #     </gAcl:role>
      #   </entry>
      #   DESCXML
      #   
      #   options = args.extract_options!.merge(:calendar => CGI::escape(calendar), :username => CGI::escape(username), :body => Nokogiri::XML(req.strip)) 
      #   request(:update_calendar_acl_for_user, options)
      # end
      # 


    end

  end

  # class CalendarAclEntry
  #   attr_accessor :calendar_id, :scope_type, :scope_id, :role, :edit_link
  #   
  #   def initialize(*args)
  #     options = args.extract_options!
  #     if (_xml = options[:xml])
  #       _xml = _xml.kind_of?(Nokogiri::XML::Document) ? _xml.children.first : _xml
  #        debugger unless _xml.at_xpath('gAcl:scope')
  #       @scope_type = _xml.at_xpath('gAcl:scope').attribute("type").content
  #       @scope_id = _xml.at_xpath('gAcl:scope').attribute("value").content
  #       @role = _xml.at_xpath('gAcl:role').attribute('value').content.gsub(/^.*2005\#/, "").to_sym
  # 
  #       @calendar_id = _xml.at_css('id').content.gsub(/^.*feeds\//,"").gsub(/\/acl.*$/,"")
  #       @edit_link = _xml.at_css('link[rel=edit]').attribute('href').value
  #       
  #     else
  #       @scope_type = options[:scope_type]
  #       @scope_id = options[:scope_id]
  #       @role = options[:role]
  #       @calendar_id = options[:calendar_id]
  #       @edit_link = options[:edit_link]
  #     end
  #   end
  #   
  #   
  #   def add_message
  #     
  #   end
  #   
  #   def to_s
  #     
  #   end
  #   
  #   private
  #   
  #   def role_url
  #     "http://schemas.google.com/gCal/2005#{@role}"
  #   end
  # end


  class CalendarEntity < Entity
    def initialize(*args)
      options = args.extract_options!
      if (_xml = options[:xml])
        @kind = "calendar"
        
        entry_kind = _xml.attribute("kind")
        raise "invalid xml passed" unless entry_kind
        
        case entry_kind.content
        when "calendar#calendar"
          # @user_id = _xml.at_css('id').content.gsub(/^.*feeds\//,"").gsub(/\/.*$/,"")

          # @role  = _xml.at_css('gCal|accesslevel').attribute("value").content
          @title = _xml.at_css('title').content
        
          super(:calendar => _xml.at_css('id').content.gsub(/^.*calendars\//,""))
        when "calendar#acl"
          # scope_type = _xml.at_css('gAcl|scope').attribute("type").content
          # scope_id = _xml.at_css('gAcl|scope').attribute("value").content
          # @entity = Entity.new(scope_type, scope_id)
          # @role = _xml.at_css('title').content
          super(:calendar => _xml.at_css('id').content.gsub(/^.*feeds\//,"").gsub(/\/acl.*$/,""))
        end
      else
        super(*args)
      end
    end
  end


  # acl names: none, read, freebusy, editor, owner, root
  # class CalendarEntry
  #   attr_accessor :calendar_id, :title, :entity, :role
  #   def initialize(*args)
  #     options = args.extract_options!
  #     if (_xml = options[:xml])
  #       kind = _xml.attribute("kind")
  #       raise "invalid xml passed" unless kind
  #       
  #       case kind.content
  #       when "calendar#calendar"
  #         user_id = _xml.at_css('id').content.gsub(/^.*feeds\//,"").gsub(/\/.*$/,"")
  # 
  #         @entity = Entity.new("user", user_id)
  #         @role  = _xml.at_css('gCal|accesslevel').attribute("value").content
  #       
  #         @calendar_id = _xml.at_css('id').content.gsub(/^.*calendars\//,"")
  #         @title = _xml.at_css('title').content
  #       when "calendar#acl"
  #         scope_type = _xml.at_css('gAcl|scope').attribute("type").content
  #         scope_id = _xml.at_css('gAcl|scope').attribute("value").content
  #         @entity = Entity.new(scope_type, scope_id)
  #         @role = _xml.at_css('title').content
  #         @calendar_id = _xml.at_css('id').content.gsub(/^.*feeds\//,"").gsub(/\/acl.*$/,"")
  #       end
  #     else
  #       @calendar_id = options[:calendar_id]
  #       @title = options[:title]
  #       @entity = options[:entity]
  #       @role = options[:role]
  #       
  #     end
  # 
  #     raise "Calendar ID required" unless @calendar_id
  # 
  #   end
  # 
  #   def to_s
  #     @calendar_id
  #   end
  # 
  #   def to_url
  #     CGI::escape(CGI::unescape(@calendar_id))
  #   end
  # 
  #   def add_message
  #     req = <<-DESCXML
  #     <entry xmlns='http://www.w3.org/2005/Atom'> 
  #       <id>#{CGI::escape(calendar_id.to_s)}</id>
  #     </entry>
  #     DESCXML
  #     
  #     req.strip
  #   end
  # end


end
