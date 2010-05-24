#!/usr/bin/ruby

module GoogleAppsApi #:nodoc:
  module Contacts
    class Api < GoogleAppsApi::BaseApi
      attr_reader :token

      def initialize(*args)  
        super(:contacts, *args)
      end

      def retrieve_all_contacts(*args)
        request(:retrieve_all_contacts, args.extract_options!)
      end
      
      def create_contact(contact, *args)
        
        req = <<-DESCXML
        <atom:entry xmlns:atom='http://www.w3.org/2005/Atom'
            xmlns:gd='http://schemas.google.com/g/2005'>
          <atom:category scheme='http://schemas.google.com/g/2005#kind'
            term='http://schemas.google.com/contact/2008#contact' />
          <gd:name>
             <gd:givenName>#{contact.given_name}</gd:givenName>
             <gd:familyName>#{contact.family_name}</gd:familyName>
             <gd:fullName>#{contact.real_name}</gd:fullName>
          </gd:name>
        DESCXML
        
        contact.emails.each_pair do |loc, email|
          req += <<-DESCXML
          <gd:email rel='http://schemas.google.com/g/2005##{loc}'
            primary='#{contact.primary_email == loc ? 'true' : 'false'}'
            address='#{email}' displayName='#{contact.real_name}' />
          DESCXML
        end
        
        req += "</atom:entry>"
        
        options = args.extract_options!.merge(:body => req.strip)
        
        request(:create_contact, options)
        
      end
    end
  
  end

  class ContactEntity < Entity
    attr_reader :given_name, :family_name, :full_name, :emails, :primary_email

    def initialize(*args)
      @emails = {}

      options = args.extract_options!
      if options.has_key?(:xml)
   
      else
        if args.first.kind_of?(String)
          super(:contact => args.first)
        else
          @given_name = options.delete(:given_name)
          @family_name = options.delete(:family_name)
          @full_name = options.delete(:full_name)
          @emails = options.delete(:emails) || {}
          
          super(options.merge(:kind => "contact"))
        end
      end
    end
  
    def real_name
      full_name.to_s != "" ? full_name.to_s : (given_name.to_s + " " + family_name.to_s)
    end
  
    def ==(other)
      super(other)
    end
  
  end

end