# require 'test_helper'
# 
# class GappsUserProfilesTest < Test::Unit::TestCase
#  
#   context "given a connection to apps.cul" do
#     setup do
#       gapps_config =YAML::load_file("private/gapps-config.yml")["apps_ocelot"].symbolize_keys!
#       @api = GoogleAppsApi::UserProfiles::Api.new(gapps_config)
#     end
# 
#     should "have a token" do
#       assert @api.token
#     end
#     
# 
#     should "be able to retrieve all users" do
#       # raise @api.retrieve_all.to_s
#     end
#     
#     should "be able to retrieve one user" do
#       assert @api.retrieve_user("nco2104").to_s
#     end
#     
#     should "be able to set email" do
#       assert @api.set_emails("jws2135",:primary => :work, :home => "james.stuart+profilesapi@gmail.com", :work => "james.stuart+profilesapi@columbia.edu").to_s
#     end
# 
#   end
#   
# end
