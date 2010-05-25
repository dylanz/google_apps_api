require 'test_helper'

class GoogleAppsApiContactsTest < Test::Unit::TestCase
  include GoogleAppsApi
  
  context "given a connection to apps.cul" do
    setup do
      gapps_config =YAML::load_file("private/gapps-config.yml")["apps_cul"].symbolize_keys!
      @co_api = Contacts::Api.new(gapps_config)
    end

    should "have a token" do
      assert @co_api.token
    end
    # 
    # should "be able to retrieve user" do
    #   resp = @api.retrieve_user("jws2135")
    #   
    #   assert_kind_of UserEntity, resp
    #   
    #   assert_equal resp.id, "jws2135"
    # end
    # 
    # should "throw an error if given an invalid user" do
    #   assert_raises GDataError do
    #     resp = @api.retrieve_user("xx_jws2135")
    #   end
    # end
    # 
    # 
    should "be able to retrieve all contacts" do
      cons =  @co_api.retrieve_all_contacts(:debug => true)
      assert_kind_of Array, cons
      
    end

    # should "be able to remove all contacts" do
    #   cons =  @co_api.retrieve_all_contacts
    #   
    #   cons.each do |con|
    #     @co_api.remove_contact(con, :debug => true)
    #   end
    # end

    # 
    # should "be able to create a contact" do
    #   contact = ContactEntity.new(:id => "_new_", :name => "Bizarre Test", :emails => {:work => "james.stuart+bizarretest@columbia.edu", :home => "james.stuart+bizarretest@gmail.com"}, :primary_email => :work)
    #   res =  @co_api.create_contact(contact, :debug => true)
    # 
    #   assert_kind_of ContactEntity, res
    # 
    #   puts res.inspect
    #   
    #   # @co_api.remove_contact(res, :debug => true)
    # 
    # end
    # 
    

    # 
    # 
    # 
    # should "be able to create and delete a  user" do
    #   uid = random_letters(9, "_t_")
    #   
    #   assert_raises GDataError do
    #    @api.retrieve_user(uid)
    #   end
    #   
    #   @api.create_user(uid, :given_name => random_letters(5), :family_name => random_letters(5), :password => random_letters(10))
    #  
    #   assert_kind_of UserEntity, @api.retrieve_user(uid)
    #   
    #   @api.delete_user(uid)
    # 
    # 
    #   assert_raises GDataError do
    #    @api.retrieve_user(uid)
    #   end
    #   
    #   
    # end
    # 
    # 
    # 
    # 
    # should "be able to update a user" do
    #   uid = "jws2135"
    # 
    #   @api.update_user(uid, :given_name => "Jimmy", :family_name => "Stuart")
    #   
    #   assert_equal "Jimmy", @api.retrieve_user(uid).given_name
    # 
    #   @api.update_user(uid, :given_name => "James", :family_name => "Stuart")
    #   
    #   assert_equal "James", @api.retrieve_user(uid).given_name
    #   
    # end
    # 
      
  end
  
end
