# require 'test_helper'
# 
# class GappsCalendarResourcesTest < Test::Unit::TestCase
# 
#   context "given a connection to apps.cul" do
#     setup do
#       gapps_config =YAML::load_file("private/gapps-config.yml")["apps_ocelot"].symbolize_keys!
#       @api = GoogleAppsApi::CalendarResources::Api.new(gapps_config)
#     end
# 
#     should "have a token" do
#       assert @api.token
#     end
# 
# 
#     
#     should "be able to retrieve all resources" do
#       assert @api.retrieve_all_resources
#     end
#     
#     # 
#     # should "be able to create a  user" do
#     #   assert_raises GoogleAppsApi::GDataError do
#     #    @api.retrieve_user("not_a_real_user")
#     #   end
#     #   
#     #   @api.create_user("not_a_real_user", "Not", "Real", "test_password", nil)
#     #   
#     #   assert_equal @api.retrieve_user("not_a_real_user").username, "not_a_real_user"
#     #   
#     #   @api.delete_user("not_a_real_user")
#     # 
#     #   assert_raises GoogleAppsApi::GDataError do
#     #    @api.retrieve_user("not_a_real_user")
#     #   end
# 
# 
# 
#   end
# 
# end
