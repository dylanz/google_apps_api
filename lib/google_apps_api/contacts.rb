# #!/usr/bin/ruby
# 
# # require 'cgi'
# # require 'rexml/document'
# # 
# 
# include REXML
# 
# 
# 
# module GoogleAppsApi #:nodoc:
#   module SharedContacts 
#     class Api < GoogleAppsApi::BaseApi
#       attr_reader :token
# 
#       def initialize(*args)  
#         action_list = {
#           :domain_login => [:post, ":auth:/accounts/ClientLogin"],
#           :retrieve_all => [:get, ":feed_basic:/full"],
#           :create_contact => [:post, ":feed_basic:/full"]
#         }
# 
#         options = args.extract_options!
#         options.merge!(:action_hash => action_list, :auth => "https://www.google.com", :feed => "https://www.google.com", :service => "cp")
#         options[:feed_basic] = options[:feed]+ "/m8/feeds/contacts/#{options[:domain]}"
# 
#         super(options)
#       end
# 
#       def create_contact(*args)
#         options = args.extract_options!
#         msg = RequestMessage.new
#         msg.add_contact(options)
#         response  = request(:create_contact, :body => msg.to_s)
#         return response.to_s
#       end
# 
#     end
# 
#     class RequestMessage < GoogleAppsApi::RequestMessage #:nodoc:
# 
#       def add_contact(*args)
#         options = args.extract_options!
#         base = self.elements["atom:entry"]
#         base.add_element("atom:title", {"type" => "text"}).text = options[:name] 
#         base.add_element("atom:content", {"type" => "text"}).text = "Notes"
#         (options[:email] || {}).each_pair do |email_type, address|
#           base.add_element("gd:email", {"rel" => "http://schemas.google.com/g/2005##{email_type.to_s}", "address" => address})
#         end
#       end
#     end
#   end
# end