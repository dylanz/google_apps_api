#!/usr/bin/ruby

module GoogleAppsApi #:nodoc:
  module Contacts
    class Api < GoogleAppsApi::BaseApi
      attr_reader :token

      def initialize(*args)  
        super(:contacts, *args)
      end

      def retrieve_all_contacts(*args)
        options = args.extract_options!
        request(:retrieve_all_contacts, options)
      end
      
      def remove_contact(contact, *args)
        options = args.extract_options!.merge(:contact => contact.id_escaped, :merge_headers => {"If-Match" => "*"})
        
        request(:remove_contact, options)
      end
      
      def create_contact(contact, *args)
        
        req = <<-DESCXML
        <atom:entry xmlns:atom='http://www.w3.org/2005/Atom'
            xmlns:gd='http://schemas.google.com/g/2005'>
          <atom:category scheme='http://schemas.google.com/g/2005#kind'
            term='http://schemas.google.com/contact/2008#contact' />
          <atom:title type='text'>#{contact.name}</atom:title>
        DESCXML
        
        contact.emails.each_pair do |loc, email|
          req += <<-DESCXML
          <gd:email rel='http://schemas.google.com/g/2005##{loc}'
            primary='#{contact.primary_email == loc ? 'true' : 'false'}'
            address='#{email}' displayName='#{contact.name}' />
          DESCXML
        end
        
        req += "</atom:entry>"
        
        options = args.extract_options!.merge(:body => req.strip)
        
        request(:create_contact, options)
        
      end
    end
  
  end

  class ContactEntity < Entity
    attr_reader :name, :emails, :primary_email

    def initialize(*args)
      @emails = {}

      options = args.extract_options!
      if (_xml = options[:xml])
        xml = _xml.at_css("entry") || _xml
        @kind = "contact"
        @id = xml.at_css("id").content.gsub(/^.+\/base\//,"")
        @domain = xml.at_css("id").content.gsub(/^.+\/contacts\/([^\/]+)\/.+$/,"\\1")
        @name = xml.at_css("title").content
      else
        if args.first.kind_of?(String)
          super(:contact => args.first)
        else
          @name = options.delete(:name)
          @emails = options.delete(:emails) || {}
          
          super(options.merge(:kind => "contact"))
        end
      end
    end
    
    def ==(other)
      super(other)
    end
  
  end

end