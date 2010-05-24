require 'test_helper'

class GoogleAppsApiBaseApiTest < Test::Unit::TestCase
  include GoogleAppsApi
  
  context "given an example entity" do
    setup do
      @en = Entity.new(:kind => "user", :id => "test1", :domain => "ocelot.cul.columbia.edu")
      @c_en = Entity.new(:kind => "calendar", :id => "js235", :domain => "ocelot.cul.columbia.edu")
      @d_en = Entity.new(:kind => "domain", :id => "ocelot.cul.columbia.edu")
      @co_en = Entity.new(:kind => "contact", :id => "12345")
    end


    should "reject items without kind and id" do
      assert_raises ArgumentError do
        Entity.new(:id => "test1", :domain => "oc")
      end

      assert_raises ArgumentError do
        Entity.new(:kind => "user", :domain => "oc")
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
      assert_equal "ocelot.cul.columbia.edu", @d_en.full_id
      assert_equal "ocelot.cul.columbia.edu", @d_en.full_id_escaped
    end
    
    should "be able to create user entities" do
      assert_equal @en, UserEntity.new("test1@ocelot.cul.columbia.edu")
      assert_equal @en, UserEntity.new("test1%40ocelot.cul.columbia.edu")
      assert_equal @en, UserEntity.new(:id => "test1", :domain => "ocelot.cul.columbia.edu")
    end


    should "be able to create calendar entities" do
      assert_equal @c_en, CalendarEntity.new("js235@ocelot.cul.columbia.edu")
      assert_equal @c_en, CalendarEntity.new("js235%40ocelot.cul.columbia.edu")
      assert_equal @c_en, CalendarEntity.new(:id => "js235", :domain => "ocelot.cul.columbia.edu")
    end

    should "be able to derive a calendar entity from a user entity" do
      assert_equal @c_en, UserEntity.new("js235@ocelot.cul.columbia.edu").entity_for_base_calendar
    end
    
    should "be able to display the qualified id, escape and nonescaped" do
      assert_equal "user:test1@ocelot.cul.columbia.edu", @en.qualified_id
      assert_equal "user%3Atest1%40ocelot.cul.columbia.edu", @en.qualified_id_escaped
      assert_equal "domain:ocelot.cul.columbia.edu", @d_en.qualified_id
      assert_equal "domain%3Aocelot.cul.columbia.edu", @d_en.qualified_id_escaped
    end
  end
  
end
