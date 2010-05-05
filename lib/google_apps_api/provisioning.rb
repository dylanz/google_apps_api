#!/usr/bin/ruby

module GoogleAppsApi #:nodoc:
  module Provisioning
    class Api < GoogleAppsApi::BaseApi
      attr_reader :token


      def initialize(*args)
        super(:provisioning, *args)
      end

      def retrieve_user(username)
        request(:retrieve_user, :username => username) 
      end


      def retrieve_all_users
        request(:retrieve_all_users)
      end
      # 
      # # Returns a UserEntry array populated with 100 users, starting from a username
      # #   ex :  
      # #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
      # #     list= myapps.retrieve_page_of_users("jsmtih")
      # #     list.each{ |user| puts user.username}
      # def retrieve_page_of_users(start_username)
      #   param='?startUsername='+start_username
      #   response = request(:user_retrieve_all,param,@headers)
      #   user_feed = Feed.new(response.elements["feed"],  UserEntry)
      # end
      #  
      #  
      #     def contacts_retrieve_all()
      #       response = request(:contacts_retrieve_all,nil, @headers)
      #     end
      #  
      # Creates an account in your domain, returns a UserEntry instance
      #   params :
      #     username, given_name, family_name and password are required
      #     passwd_hash_function (optional) : nil (default) or "SHA-1"
      #     quota (optional) : nil (default) or integer for limit in MB
      #   ex :  
      #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
      #     user = myapps.create('jsmith', 'John', 'Smith', 'p455wD')
      #
      # By default, a new user must change his password at first login. Please use update_user if you want to change this just after the creation.
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

                
        request(:create_user, :body => res.strip)
      end
      # 
      # # Updates an account in your domain, returns a UserEntry instance
      # #   params :
      # #     username is required and can't be updated.
      # #     given_name and family_name are required, may be updated.
      # #     if set to nil, every other parameter won't update the attribute.
      # #       passwd_hash_function :  string "SHA-1", "MD5" or nil (default)
      # #       admin :  string "true" or string "false" or nil (no boolean : true or false). 
      # #       suspended :  string "true" or string "false" or nil (no boolean : true or false)
      # #       change_passwd :  string "true" or string "false" or nil (no boolean : true or false)
      # #       quota : limit en MB, ex :  string "2048"
      # #   ex :
      # #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
      # #     user = myapps.update('jsmith', 'John', 'Smith', nil, nil, "true", nil, "true", nil)
      # #     puts user.admin   => "true"
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
        request(:update_user, :username => username, :body => res.strip)
      end
      # 
      # # Renames a user, returns a UserEntry instance
      # #   ex :
      # #
      # #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
      # #     user = myapps.rename_user('jsmith','jdoe')
      # #
      # #   It is recommended to log out rhe user from all browser sessions and service before renaming.
      # #              Once renamed, the old username becomes a nickname of the new username.
      # #   Note from Google: Google Talk will lose all remembered chat invitations after renaming. 
      # #   The user must request permission to chat with friends again. 
      # #     Also, when a user is renamed, the old username is retained as a nickname to ensure continuous mail delivery in the case of email forwarding settings. 
      # #   To remove the nickname, you should issue an HTTP DELETE to the nicknames feed after renaming.
      # def rename_user(username, new_username)
      #   msg = RequestMessage.new
      #   msg.about_login(new_username)
      #   msg.add_path('https://'+@@google_host+@action[:user_rename][:path]+username)
      #   response  = request(:user_update,username,@headers, msg.to_s)
      # end
      #   
      # # Suspends an account in your domain, returns a UserEntry instance
      # #   ex :
      # #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
      # #     user = myapps.suspend('jsmith')
      # #     puts user.suspended   => "true"
      # def suspend_user(username)
      #   msg = RequestMessage.new
      #   msg.about_login(username,nil,nil,nil,"true")
      #   msg.add_path('https://'+@@google_host+@action[:user_update][:path]+username)
      #   response  = request(:user_update,username,@headers, msg.to_s)
      #   user_entry = UserEntry.new(response.elements["entry"])
      # end
      # 
      # # Restores a suspended account in your domain, returns a UserEntry instance
      # #   ex :
      # #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
      # #     user = myapps.restore('jsmith')
      # #     puts user.suspended   => "false"
      # def restore_user(username)
      #   msg = RequestMessage.new
      #   msg.about_login(username,nil,nil,nil,"false")
      #   msg.add_path('https://'+@@google_host+@action[:user_update][:path]+username)
      #   response  = request(:user_update,username,@headers, msg.to_s)
      #   user_entry = UserEntry.new(response.elements["entry"])
      # end
      # 
      # # Deletes an account in your domain
      # #   ex :
      # #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
      # #     myapps.delete('jsmith')
      def delete_user(username)
        response  = request(:delete_user, :username => username)
      end


    end


    # 
    # 
    # class RequestMessage < Document #:nodoc:
    #   # Request message constructor.
    #   # parameter type : "user", "nickname" or "emailList"  
    # 
    #   # creates the object and initiates the construction
    #   def initialize
    #     super '<?xml version="1.0" encoding="UTF-8"?>' 
    #     self.add_element "atom:entry", {"xmlns:apps" => "http://schemas.google.com/apps/2006",
    #       "xmlns:gd" => "http://schemas.google.com/g/2005",
    #       "xmlns:atom" => "http://www.w3.org/2005/Atom"}
    # 
    #       self.elements["atom:entry"].add_element "atom:category", {"scheme" => "http://schemas.google.com/g/2005#kind"}
    # 
    #     end
    # 
    #     # adds <atom:id> element in the message body. Url is inserted as a text.
    #     def add_path(url)
    #       self.elements["atom:entry"].add_element "atom:id"
    #       self.elements["atom:entry/atom:id"].text = url
    #     end
    # 
    #     # adds <apps:emailList> element in the message body.
    #     def about_email_list(email_list)
    #       self.elements["atom:entry/atom:category"].add_attribute("term", "http://schemas.google.com/apps/2006#emailList")
    #       self.elements["atom:entry"].add_element "apps:emailList", {"name" => email_list } 
    #     end
    # 
    #     # adds <apps:property> element in the message body for a group.
    #     def about_group(group_id, properties)
    #       self.elements["atom:entry/atom:category"].add_attribute("term", "http://schemas.google.com/apps/2006#emailList")
    #       self.elements["atom:entry"].add_element "apps:property", {"name" => "groupId", "value" => group_id } 
    #       self.elements["atom:entry"].add_element "apps:property", {"name" => "groupName", "value" => properties[0] } 
    #       self.elements["atom:entry"].add_element "apps:property", {"name" => "description", "value" => properties[1] } 
    #       self.elements["atom:entry"].add_element "apps:property", {"name" => "emailPermission", "value" => properties[2] } 
    #     end
    # 
    #     # adds <apps:property> element in the message body for a member.
    #     def about_member(email_address)
    #       self.elements["atom:entry/atom:category"].add_attribute("term", "http://schemas.google.com/apps/2006#user")
    #       self.elements["atom:entry"].add_element "apps:property", {"name" => "memberId", "value" => email_address } 
    #     end
    # 
    #     # adds <apps:property> element in the message body for an owner.
    #     def about_owner(email_address)
    #       self.elements["atom:entry/atom:category"].add_attribute("term", "http://schemas.google.com/apps/2006#user")
    #       self.elements["atom:entry"].add_element "apps:property", {"name" => "email", "value" => email_address } 
    #     end
    # 
    # 
    #     # adds <apps:login> element in the message body.
    #     # warning : if valued admin, suspended, or change_passwd_at_next_login must be the STRINGS "true" or "false", not the boolean true or false
    #     # when needed to construct the message, should always been used before other "about_" methods so that the category tag can be overwritten
    #     # only values permitted for hash_function_function_name : "SHA-1", "MD5" or nil
    #     def about_login(user_name, passwd=nil, hash_function_name=nil, admin=nil, suspended=nil, change_passwd_at_next_login=nil)
    #       self.elements["atom:entry/atom:category"].add_attribute("term", "http://schemas.google.com/apps/2006#user")
    #       self.elements["atom:entry"].add_element "apps:login", {"userName" => user_name } 
    #       self.elements["atom:entry/apps:login"].add_attribute("password", passwd) if not passwd.nil?
    #       self.elements["atom:entry/apps:login"].add_attribute("hashFunctionName", hash_function_name) if not hash_function_name.nil?
    #       self.elements["atom:entry/apps:login"].add_attribute("admin", admin) if not admin.nil?
    #       self.elements["atom:entry/apps:login"].add_attribute("suspended", suspended) if not suspended.nil?
    #       self.elements["atom:entry/apps:login"].add_attribute("changePasswordAtNextLogin", change_passwd_at_next_login) if not change_passwd_at_next_login.nil?
    #       return self
    #     end
    # 
    #     # adds <apps:quota> in the message body.
    #     # limit in MB: integer
    #     def about_quota(limit)
    #       self.elements["atom:entry"].add_element "apps:quota", {"limit" => limit }  
    #       return self
    #     end    
    # 
    #     # adds <apps:name> in the message body.
    #     def about_name(family_name, given_name)
    #       self.elements["atom:entry"].add_element "apps:name", {"familyName" => family_name, "givenName" => given_name } 
    #       return self
    #     end
    # 
    #     # adds <apps:nickname> in the message body.
    #     def about_nickname(name)
    #       self.elements["atom:entry/atom:category"].add_attribute("term", "http://schemas.google.com/apps/2006#nickname")
    #       self.elements["atom:entry"].add_element "apps:nickname", {"name" => name} 
    #       return self
    #     end
    # 
    #     # adds <gd:who> in the message body.
    #     def about_who(email)
    #       self.elements["atom:entry"].add_element "gd:who", {"email" => email } 
    #       return self
    #     end
    # 
    #   end
    # end
  end
  


  class UserEntry < Entry
    attr_accessor :given_name, :family_name, :username, :suspended, :ip_whitelisted, :admin, :change_password_at_next_login, :agreed_to_terms, :quota_limit
    
    def initialize(xml = nil)
      if xml
        @family_name = xml.at_xpath("//apps:name").attribute("familyName").content
        @given_name = xml.at_xpath("//apps:name").attribute("givenName").content
        @username = xml.at_xpath("//apps:login").attribute("userName").content
        @suspended = xml.at_xpath("//apps:login").attribute("suspended").content
        @ip_whitelisted = xml.at_xpath("//apps:login").attribute("ipWhitelisted").content
        @admin = xml.at_xpath("//apps:login").attribute("admin").content
        @change_password_at_next_login = xml.at_xpath("//apps:login").attribute("changePasswordAtNextLogin").content
        @agreed_to_terms = xml.at_xpath("//apps:login").attribute("agreedToTerms").content
        @quota_limit = xml.at_xpath("//apps:quota").attribute("limit").content
      end
    end

    def to_s
      username
    end

    def inspect
      "<UserEntry: #{username} : #{given_name} #{family_name}>"
    end

    def create_message(*args)

    end
    # 
    # def add_message
    #   Nokogiri::XML::Builder.new { |xml|
    #     xml.entry(:xmlns => "http://www.w3.org/2005/Atom") {
    #       xml.id_ {
    #         xml.text id.to_s
    #       }
    #     }
    #   }.to_xml
    # end
  end
end