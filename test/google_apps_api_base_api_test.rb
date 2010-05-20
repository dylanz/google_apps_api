require 'test_helper'

class GoogleAppsApiBaseApiTest < Test::Unit::TestCase
  include GoogleAppsApi
  
  context "given an example entity" do
    setup do
      @en = Entity.new(:kind => "user", :id => "test1", :domain => "ocelot.cul.columbia.edu")
    end


    should "reject items without all arguments" do
      assert_raises ArgumentError do
        Entity.new(:id => "test1", :domain => "oc")
      end

      assert_raises ArgumentError do
        Entity.new(:kind => "user", :domain => "oc")
      end

      assert_raises ArgumentError do
        Entity.new(:kind => "user", :id => "test1")
      end
    end
    
    should "accept a user argument" do
      u_en = Entity.new(:user => "test1", :domain => "ocelot.cul.columbia.edu")
      
      assert_equal @en, u_en
    end

    should "split domains out" do
      u_en = Entity.new(:user => "test1@ocelot.cul.columbia.edu")
      
      assert_equal @en, u_en
    end


    should "split encoded domains out" do
      u_en = Entity.new(:user => "test1%40ocelot.cul.columbia.edu")
      
      assert_equal @en, u_en
    end

    should "be able to display the encoded and non-encoded versions" do
      assert_equal "test1@ocelot.cul.columbia.edu", @en.full_id
      assert_equal "test1%40ocelot.cul.columbia.edu", @en.full_id_escaped
    end
    
  end
  
end
