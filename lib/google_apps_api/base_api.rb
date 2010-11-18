module GoogleAppsApi
  class BaseApi
    attr_reader :domain


    def initialize(api_name, *args)
      api_config = GoogleAppsApi.config[api_name] || {}
      options = args.extract_options!.merge!(api_config)
      raise("Must supply admin_user") unless options[:admin_user]
      raise("Must supply admin_password") unless options[:admin_password]
      @domain = options[:domain] || raise("Must supply domain")
      @actions_hash = options[:action_hash] || raise("Must supply action hash")
      @actions_subs = options[:action_subs] || raise("Must supply action subs")
      @actions_hash[:next] = [:get, '']
      @actions_subs[:domain] = @domain

      @token = login(options[:admin_user], @domain, options[:admin_password], options[:service])
      @headers = {'Content-Type'=>'application/atom+xml', 'Authorization'=> 'GoogleLogin auth='+@token}.merge(options[:headers] || {})

    end


    def entity(*args)
      entity.merge(:domain => @domain)
    end


    private

    def login(username, domain, password, service)
      @gsession_id = nil
      request_body = '&Email='+CGI.escape(username + "@" + domain)+'&Passwd='+CGI.escape(password)+'&accountType=HOSTED&service='+ service + '&source=columbiaUniversity-google_apps_api-0.1'
      res = request(:domain_login, :headers =>  {'Content-Type'=>'application/x-www-form-urlencoded'}, :body => request_body)


      return /^Auth=(.+)$/.match(res.to_s)[1]
    end



    def request(action, *args)
      options = args.extract_options!
      options = {:headers => @headers}.merge(options)
      options[:headers] = (options[:headers] || {}).merge(options.delete(:merge_headers) || {})
      action_hash = @actions_hash[action] || raise("invalid action #{action} called")

      subs_hash = @actions_subs.merge(options)
      subs_hash.each { |k,v| subs_hash[k] = action_gsub(v, subs_hash) if v.kind_of?(String)}

      method = action_hash[:method]
      path = action_gsub(action_hash[:path], subs_hash) + options[:query].to_s
      is_feed = action_hash[:feed]
      format = options[:return_format] || action_hash[:format] || :xml
      format = format.constantize unless [:xml, :text].include?(format) || format.kind_of?(Class)

      if options[:debug]
        puts "method: #{method}"
        puts "path: #{path}"
        puts "body: #{options[:body]}"
        puts "headers: #{options[:headers]}"
        puts "---\n"
      end

      response = http_request(method, path, options[:body], options[:headers])

      if format == :text
        puts response.body.content if options[:debug]
        return response.body.content
      else
        begin
          xml = Nokogiri::XML(response.body.content) { |c| c.strict.noent}

          test_errors(xml)
          puts xml.to_s if options[:debug]


          if format == :xml || !is_feed
            format.kind_of?(Class) ? format.new(:xml => xml) : xml
          else
            entries = entryset(xml.css('feed>entry'), format)


            while (next_feed = xml.at_css('feed>link[rel=next]'))
              response = http_request(:get, next_feed.attribute("href").to_s, nil, options[:headers])
              xml = Nokogiri::XML(response.body.content) { |c| c.strict}
              entries += entryset(xml.css('feed>entry'),format)
            end

            entries
          end


        rescue Nokogiri::XML::SyntaxError  => e
          puts response.body.content if options[:debug]

          error = GDataError.new()
          error.code = "SyntaxError"
          error.input = "path: #{path}"
          error.reason = "#{response.body.content}"
          raise error, error.inspect
        end
      end
    end

    def http_request(method, path, body, headers, redirects = 0)
      @hc ||= HTTPClient.new

      path_with_gsession = path

      if @gsession_id && redirects == 0
        operator = path.include?("?") ? "&" : "?"
        path_with_gsession += "#{operator}gsessionid=#{@gsession_id.to_s}"
      end

      response = case method
      when :delete
        @hc.send(method, path_with_gsession, headers)
      else
        @hc.send(method, path_with_gsession, body, headers)
      end

      if response.status_code == 302 && (redirects += 1) < 10
        new_loc = response.header["Location"].to_s
        gsession_match = new_loc.match(/gsessionid=([\w\-_]+)/)
        @gsession_id = gsession_match[1].to_s if gsession_match
        response = http_request(method, new_loc, body, headers, redirects)
      end
      return response
    end

    def action_gsub(str, sub_hash)
      str.gsub(/\:([^\:]+)\:/) { |key| sub_hash[key.gsub(/\:/,"").to_sym] }
    end


    # parses xml response for an API error tag. If an error, constructs and raises a GDataError.
    def test_errors(xml)
      error = xml.at_xpath("AppsForYourDomainErrors/error")
      if  error
        gdata_error = GDataError.new
        gdata_error.code = error.attribute("errorCode").content
        gdata_error.input = error.attribute("invalidInput").content
        gdata_error.reason = error.attribute("reason").content
        msg = "error code : "+gdata_error.code+", invalid input : "+gdata_error.input+", reason : "+gdata_error.reason
        raise gdata_error, msg
      end
    end

    def entryset(entries, return_class)
      return_class ? entries.collect { |en| return_class.new(:xml => en)} : entries
    end

    def escapeXML(text)
      CGI.escapeHTML(text.to_s)
    end

  end

  class Entry

    private

    def escapeXML(text)
      CGI.escapeHTML(text.to_s)
    end

  end




  class Entity
    VALID_ENTITY_TYPES = [:user, :calendar, :domain, :contact]

    attr_reader :kind, :id, :domain
    def initialize(*args)
      options = args.extract_options!

      @kind = options.delete(:kind)
      @id = options.delete(:id)
      @domain = options.delete(:domain)

      if (kind = options.keys.detect { |k| VALID_ENTITY_TYPES.include?(k.to_sym)})
        @kind = kind.to_s

        value = CGI::unescape(options[kind])

        if value.include?("@")
          @id, @domain = value.split("@",2)
        else
          @id = value
        end
      end


      raise(ArgumentError, "Kind and Id must be specified") unless @kind && @id
    end

    def id_escaped
      CGI::escape(@id)
    end

    def full_id
      @id + (@domain.nil? ? "" : "@" + @domain)
    end

    def full_id_escaped
      CGI::escape(full_id)
    end

    def qualified_id
      @kind + ":" + full_id
    end

    def qualified_id_escaped
      CGI::escape(qualified_id)
    end


    def ==(other)
      other.kind_of?(Entity) && @kind == other.kind && @id == other.id && @domain == other.domain
    end
  end

	class GDataError < RuntimeError
		attr_accessor :code, :input, :reason

		def initialize()
		end

		def to_s
		  "#{code}: #{reason}"
		end

		def inspect
		  "#{code}: #{reason}"

		end
	end
end
