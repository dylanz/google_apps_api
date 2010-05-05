require 'test_helper'

class GoogleAppsApiProvisioningTest < Test::Unit::TestCase
  include GoogleAppsApi
  
  context "given a connection to apps.cul" do
    setup do
      gapps_config =YAML::load_file("private/gapps-config.yml")["apps_ocelot"].symbolize_keys!
      @api = Provisioning::Api.new(gapps_config)
    end

    should "have a token" do
      assert @api.token
    end
    
    should "be able to retrieve user" do
      resp = @api.retrieve_user("jws2135")
      
      assert_kind_of UserEntry, resp
      
      assert_equal resp.username, "jws2135"
    end
    
    should "throw an error if given an invalid user" do
      assert_raises GDataError do
        resp = @api.retrieve_user("xx_jws2135")
      end
    end
    

    should "be able to retrieve all users" do
      assert_kind_of Array, @api.retrieve_all_users
    end



    should "be able to create and delete a  user" do
      uid = random_letters(9, "_t_")
      
      assert_raises GDataError do
       @api.retrieve_user(uid)
      end
      
      ue = UserEntry.new()
      @api.create_user(uid, :given_name => random_letters(5), :family_name => random_letters(5), :password => random_letters(10))
     
      assert_kind_of UserEntry, @api.retrieve_user(uid)
      
      @api.delete_user(uid)


      assert_raises GDataError do
       @api.retrieve_user(uid)
      end
      
      
    end




    should "be able to update a user" do
      uid = "jws2135"

      @api.update_user(uid, :given_name => "Jimmy", :family_name => "Stuart")
      
      assert_equal "Jimmy", @api.retrieve_user(uid).given_name

      @api.update_user(uid, :given_name => "James", :family_name => "Stuart")
      
      assert_equal "James", @api.retrieve_user(uid).given_name
      
    end
    
      
  end
  
end
