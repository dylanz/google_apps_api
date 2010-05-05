# require 'test_helper'
# 
# class GappsContactsTest < Test::Unit::TestCase
#  
#   context "given a connection to apps.cul" do
#     setup do
#       gapps_config =YAML::load_file("private/gapps-config.yml")["apps_ocelot"].symbolize_keys!
#       @api = GoogleAppsApi::SharedContacts::Api.new(gapps_config)
#     end
# 
#     should "have a token" do
#       assert @api.token
#     end
#     
#     should "be able to create user" do
#       @api.create_contact(:name => "Nada API O'Neal", :email => { "home" => "nco2104@columbia.edu", "work" => "nco2104@apps.cul.columbia.edu"})
#     end
# 
#     should "be able to retrieve user" do
#       assert @api.retrieve_all
#     end
# 
# 
# 
#   end
#   
# end
