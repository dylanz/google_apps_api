include REXML

module GoogleAppsApi
  class BaseApi


    def initialize(api_name, *args)
      api_config = GoogleAppsApi.config[api_name] || {}
      options = args.extract_options!.merge!(api_config)
      raise("Must supply admin_user") unless options[:admin_user] 
      raise("Must supply admin_password") unless options[:admin_password]
      raise("Must supply domain") unless options[:domain]
      @actions_hash = options[:action_hash] || raise("Must supply action hash")
      @actions_subs = options[:action_subs] || raise("Must supply action subs")
      @actions_hash[:next] = [:get, '']
      @actions_subs[:domain] = options[:domain]

      @token = login(options[:admin_user], options[:domain], options[:admin_password], options[:service])
      @headers = {'Content-Type'=>'application/atom+xml', 'Authorization'=> 'GoogleLogin auth='+@token}.merge(options[:headers] || {})

    end

    def method_missing(method, *args, &block)
      if @actions_hash.has_key?(method.to_sym)
        request(method.to_sym, *args)
      end
    end

    private

    def setup_action(*args)
      options = args.extract_options!
      actions = options[:action_hash]

      actions.each_pair do |k,v|
        actions[k] = {:method => v[0], :path => (v[1].to_s.gsub!(/\:([^\:]+)\:/) { |sub| options[sub.gsub(/\:/,"").to_sym] })}
      end

      return actions
    end

    def login(username, domain, password, service)
      request_body = '&Email='+CGI.escape(username + "@" + domain)+'&Passwd='+CGI.escape(password)+'&accountType=HOSTED&service='+ service + '&source=columbiaUniversity-google_apps_api-0.1'
      res = request(:domain_login, :headers =>  {'Content-Type'=>'application/x-www-form-urlencoded'}, :body => request_body)


      return /^Auth=(.+)$/.match(res.to_s)[1]
    end

    def request(action, *args)
      options = args.extract_options!
      options = {:headers => @headers}.merge(options)
      action_hash = @actions_hash[action] || raise("invalid action #{action} called")
      
      subs_hash = @actions_subs.merge(options)
      subs_hash.each { |k,v| subs_hash[k] = action_gsub(v, subs_hash) if v.kind_of?(String)}

      method = action_hash[:method]
      path = action_gsub(action_hash[:path], subs_hash) + options[:query].to_s
      is_feed = action_hash[:feed]
      feed_class = action_hash[:class].constantize if action_hash[:class]
      format = action_hash[:format] || :xml
      response = http_request(method, path, options[:body], options[:headers])

      if format == :text
        return response.body.content
      else
        begin 
          xml = Nokogiri::XML(response.body.content) { |c| c.strict}
          test_errors(xml)
          if is_feed
            entries = entryset(xml.css('feed>entry'),feed_class)

          
            while (next_feed = xml.at_css('feed>link[rel=next]'))
              response = http_request(:get, next_feed.attribute("href").to_s, nil, options[:headers])
              xml = Nokogiri::XML(response.body.content) { |c| c.strict}
              entries += entryset(xml.css('feed>entry'),feed_class)
            end
              
            entries
          else
            feed_class ? feed_class.new(xml) : xml
          end
        

        rescue Nokogiri::XML::SyntaxError  => e
          error = GDataError.new()
          error.code = "SyntaxError"
          error.input = "path: #{path}"
          error.reason = "XML expected, syntax error"
          raise error, e.to_s
        end
      end
    end

    def http_request(method, path, body, headers, redirects = 0)
      @hc ||= HTTPClient.new
      
      response = case method
      when :delete
        @hc.send(method, path, headers)
      else
        @hc.send(method, path, body, headers)
      end
      
      if response.status_code == 302 && (redirects += 1) < 10
        response = http_request(method, response.header["Location"], body, headers, requests)
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

    def entryset(entries, feed_class)
      feed_class ? entries.collect { |en| feed_class.new(en)} : entries
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
  
	class GDataError < RuntimeError
		attr_accessor :code, :input, :reason
		
		def initialize()
		end
	end
end
