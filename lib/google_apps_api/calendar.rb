#!/usr/bin/ruby

module GoogleAppsApi #:nodoc:

  module Calendar
    class Api < GoogleAppsApi::BaseApi
      attr_reader :token

      def initialize(*args)
        super(:calendar, *args)
      end
      
      def set_calendar_for_user(calendar, user, *args)
        options = args.extract_options!
        
        existing_acl = "none"
        need_to_create = false
        
        cal = retrieve_calendar_for_user(calendar, user)
        if cal
          existing_acl = cal.details[:accesslevel]
        else
          need_to_create = true
        end
        
        acl = options.delete(:accesslevel) || existing_acl

        if need_to_create
          raise "Must set accesslevel for a newly added calendar" unless acl
          owner_acl = CalendarAcl.new(:calendar => calendar, :scope => user, :role => "owner")
          set_calendar_acl(owner_acl)
          add_calendar_to_user(calendar, user)
          
        end
        
        if acl == "none" 
          remove_calendar_from_user(calendar, user) unless existing_acl == "none"
        else

          if acl != existing_acl
            set_calendar_acl(CalendarAcl.new(:calendar => calendar, :scope => user, :role => acl))
          end
          update_calendar_for_user(calendar, user, options) unless options.empty?
          
        end
      end

      def add_calendar_to_user(calendar, user, *args)
        req = <<-DESCXML
          <entry xmlns='http://www.w3.org/2005/Atom'> 
            <id>#{calendar.full_id_escaped}</id>
          </entry>
        DESCXML
        
        options = args.extract_options!.merge(:username => user.full_id_escaped, :body => req.strip)
        request(:add_calendar_to_user, options)
      end

      
      def remove_calendar_from_user(calendar, user, *args)
        options = args.extract_options!.merge(:username => user.full_id_escaped, :calendar => calendar.full_id_escaped)
        request(:remove_calendar_from_user, options)
      end


      def update_calendar_for_user(calendar, user, *args)

        username = user.full_id_escaped

        cal = nil
        cal = retrieve_calendar_for_user(calendar, user) 
        
        cal_id = cal.full_id_escaped

        options = args.extract_options!.merge(:username => username, :calendar => cal_id)
        
        details = cal.details.merge(options)


        req = <<-DESCXML
        <entry xmlns='http://www.w3.org/2005/Atom' xmlns:gCal='http://schemas.google.com/gCal/2005' xmlns:gd='http://schemas.google.com/g/2005'>
          <id>http://www.google.com/calendar/feeds/#{username}/allcalendars/full/#{cal_id}</id>
      
          <title type='text'>#{details[:title]}</title>
          <summary type='text'>#{details[:summary]}</summary>
          <gCal:timezone value='#{details[:timezone]}'/>
          <gCal:hidden value='#{details[:hidden].to_s}'/>
          <gCal:color value='#{details[:color]}'/>
          <gCal:selected value='#{details[:selected].to_s}'/>
          <gd:where valueString='#{details[:where]}'/>
        </entry>

        DESCXML
        
        options[:body] = req.strip
        request(:update_calendar_for_user, options)
      end

      # lists all calendards for a user
      def retrieve_calendars_for_user(user, *args)
        options = args.extract_options!.merge(:username => user.full_id_escaped)
        request(:retrieve_calendars_for_user, options)
      end

      # lists all calendards for a user
      def retrieve_calendar_for_user(calendar, user, *args)
        options = args.extract_options!.merge(:calendar => calendar.full_id_escaped, :username => user.full_id_escaped)
        retries = options[:retries] || 5

        while (retries > 0)
          begin
            return request(:retrieve_calendar_for_user, options)
          rescue GDataError => g
            retries -= 1
            sleep 0.5
          end
        end
        
        return nil
      end


      # returns array of acls for a given calendar
      def retrieve_acls_for_calendar(calendar, *args)
        options = args.extract_options!.merge(:calendar => calendar.full_id_escaped)
        request(:retrieve_acls_for_calendar, options)
      end
      

      # generally, use set_calendar_acl, it works for both creates and updates
      # this will throw an exception "Version Conflict" if it already exists
      def create_calendar_acl(acl, *args)
        req = <<-DESCXML
        <?xml version="1.0" encoding="UTF-8"?>
        <entry xmlns='http://www.w3.org/2005/Atom' xmlns:gAcl='http://schemas.google.com/acl/2007'>
          <category scheme='http://schemas.google.com/g/2005#kind'
            term='http://schemas.google.com/acl/2007#accessRule'/>
          <gAcl:scope type='#{acl.scope.kind}' value='#{acl.scope.full_id}'></gAcl:scope>
          <gAcl:role
            value='http://schemas.google.com/gCal/2005##{acl.role}'>
          </gAcl:role>
        </entry>
        DESCXML
        options = args.extract_options!.merge(:calendar => acl.calendar.full_id_escaped, :body => req.strip) 
        request(:create_calendar_acl, options)
      end

      # you can substitute set_calendar_acl with role set to none
      def remove_calendar_acl(acl, *args)
        options = args.extract_options!.merge(:calendar => acl.calendar.full_id_escaped, :scope => acl.scope.qualified_id_escaped)
        request(:remove_calendar_acl, options)
      end
      
      
      # updates a given acl for a given scope
      def set_calendar_acl(acl, *args)
        req = <<-DESCXML
        <?xml version="1.0" encoding="UTF-8"?>
        <entry xmlns='http://www.w3.org/2005/Atom' xmlns:gAcl='http://schemas.google.com/acl/2007'
        xmlns:gd='http://schemas.google.com/g/2005'
          gd:etag='W/"DU4ERH47eCp7ImA9WxRVEkQ."'>
          <category scheme='http://schemas.google.com/g/2005#kind'
            term='http://schemas.google.com/acl/2007#accessRule'/>
          <gAcl:scope type='#{acl.scope.kind}' value='#{acl.scope.full_id}'></gAcl:scope>
          <gAcl:role
            value='#{acl.role_schema}'>
          </gAcl:role>
        </entry>
        DESCXML
        
        options = args.extract_options!.merge(:calendar => acl.calendar.full_id_escaped, :scope => acl.scope.qualified_id_escaped, :body => req.strip) 
        request(:set_calendar_acl, options)
      end
      


    end

  end

  class CalendarAcl
    attr_accessor :calendar, :scope, :role

    def initialize(*args)
      options = args.extract_options!
      if (_xml = options[:xml])
        _xml = _xml.kind_of?(Nokogiri::XML::Document) ? _xml.children.first : _xml
        scope_kind = _xml.at_css('gAcl|scope').attribute("type").content
        scope_id = _xml.at_css('gAcl|scope').attribute("value").content

        @scope = Entity.new(scope_kind  => scope_id)
        @role = _xml.at_css('title').content
        @calendar = CalendarEntity.new(_xml.at_css('id').content.gsub(/^.*feeds\//,"").gsub(/\/acl.*$/,""))

      else

        @scope = options[:scope]
        @role = options[:role]
        @calendar = options[:calendar]
      end
    end
    
    def role_schema
      if @role == "none"
        "none"
      else
        "http://schemas.google.com/gCal/2005##{@role}"
      end
    end
  end


  #   def role_url
  #     "http://schemas.google.com/gCal/2005#{@role}"
  #   end
  # end


  class CalendarEntity < Entity
    attr_reader :details
    
    def initialize(*args)
      @details = {}
      
      options = args.extract_options!
      if options.has_key?(:xml)
        parse_calendar_xml(options[:xml])
        super(:calendar => @calendar_id)
      else
        @title = options.delete(:title)
        
        if args.first.kind_of?(String)
          super(:calendar => args.first)
        else
          super(options.merge(:kind => "calendar"))
        end
      end
    end
    
    def ==(other)
      super(other)
    end
    
    # 
    # # updates with details.
    # def refresh_details!(c_api, *args)
    #   c_api.retrieve_calendar_details(self, *args)
    # end
    # 
    def get_acls(c_api, *args)
      c_api.retrieve_acls_for_calendar(self, *args)
    end
    
    private 
    def parse_calendar_xml(xml)
      entry = xml.kind_of?(Nokogiri::XML::Document) ? xml.children.first : xml

      @kind = "calendar"

      case entry.attribute("kind").content
      when "calendar#calendar"
        @calendar_id = entry.at_css('id').content.gsub(/^.*calendars\//,"")
        @details[:title] = entry.at_css('title').content
        @details[:summary] = entry.at_css('summary')
        @details[:summary] = @details[:summary] ? @details[:summary].content : ""
        @details[:timezone] = entry.at_css('gCal|timezone').attribute("value").content
        @details[:accesslevel] = entry.at_css('gCal|accesslevel').attribute("value").content
        @details[:where] = entry.at_css('gd|where')
        @details[:where] = @details[:where] ? @details[:where].attribute("valueString").content : ""
        @details[:color] = entry.at_css('gCal|color').attribute("value").content

        @details[:hidden] = entry.at_css('gCal|hidden').attribute("value").content  == "true"
        @details[:selected] = entry.at_css('gCal|selected').attribute("value").content == "true"
      when "calendar#acl"
        @calendar_id = entry.at_css('id').content.gsub(/^.*feeds\//,"").gsub(/\/acl.*$/,"")
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
