#!/usr/bin/ruby

# require 'cgi'
# require 'rexml/document'
# 

include REXML



module GoogleAppsApi #:nodoc:
  module UserProfiles


    class Api < GoogleAppsApi::BaseApi

      attr_reader :token

      def initialize(*args)
        action_list = {
          :domain_login => [:post, ':auth:/accounts/ClientLogin' ],
          :retrieve_all => [:get, ':basic_path:/full?v=3.0'],
          :retrieve_user => [:get, ':basic_path:/full/'],
          :set_emails => [:put, ':basic_path:/full/'],
          :next => [:get, '' ]
        }

        options = args.extract_options!
        domain = options[:domain]

        options.merge!(:action_hash => action_list, :auth => "https://www.google.com", :feed => "https://www.google.com", :service => "cp")
        options[:basic_path] = options[:feed] + "/m8/feeds/profiles/domain/#{options[:domain]}"



        super(options)
      end

      def retrieve_all()
        response = request(:retrieve_all)
        return response.to_s
      end

      def retrieve_user(user)
        response = request(:retrieve_user, :query => user + "?v=3.0")
        return response.to_s        
      end

      def set_emails(user, *args)
        emails = args.extract_options!
        doc = Document.new(retrieve_user(user).to_s)
        doc.elements.each("entry/gd:email") do |e|

          e.parent.delete(e)
        end


        primary = emails.delete(:primary) || :other

        base = doc.elements["entry"]
        emails.each_pair do |loc, email|
          base.add_element("gd:email", "address" => email, "rel" => "http://schemas.google.com/g/2005##{loc.to_s}", "primary" => loc == primary ? "true" : "false")
        end

        response  = request(:set_emails,:query => user + "?v=3.0", :body => doc.to_s)

      end


      # class RequestMessage < Document #:nodoc:
      #   # Request message constructor.
      #   # parameter type : "user", "nickname" or "emailList"  
      # 
      #   # creates the object and initiates the construction
      #   def initialize(*args)
      #     options = args.extract_options!
      #     super '<?xml version="1.0" encoding="UTF-8"?>' 
      #     self.add_element "entry", { "xmlns:gd" => "http://schemas.google.com/g/2005",
      #       "xmlns:atom" => "http://www.w3.org/2005/Atom", "xmlns:batch" => 'http://schemas.google.com/gdata/batch', "xmlns:gContact" => "http://schemas.google.com/contact/2008"}
      #       # self.elements["entry"].add_element "atom:category", {"scheme" => "http://schemas.google.com/g/2005#kind", "term" => "http://schemas.google.com/contact/2008#contact"}
      #     end
      # 
      #     def add_contact(*args)
      #       options = args.extract_options!
      #       base = self.elements["atom:entry"]
      #       base.add_element("atom:title", {"type" => "text"}).text = options[:name] 
      #       base.add_element("atom:content", {"type" => "text"}).text = "Notes"
      #       (options[:email] || {}).each_pair do |email_type, address|
      #         base.add_element("gd:email", {"rel" => "http://schemas.google.com/g/2005##{email_type.to_s}", "address" => address})
      #       end
      #     end
      # 
      #     def update_contact(*args)
      #       options = args.extract_options!
      #     end
      #   end
      # 
      # end
    end
  end
end