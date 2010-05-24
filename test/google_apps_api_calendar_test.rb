require 'test_helper'

class GoogleAppsApiCalendarTest < Test::Unit::TestCase
  include GoogleAppsApi

  context "given users" do
    setup do
      @gapps_config =YAML::load_file("private/gapps-config.yml")["apps_ocelot"].symbolize_keys!
      @u1 = UserEntity.new("__user1@ocelot.cul.columbia.edu")
      @u2 = UserEntity.new("__user2@ocelot.cul.columbia.edu")
      @u3 = UserEntity.new("__user3@ocelot.cul.columbia.edu")
    end

    context "and a calendar api " do
      setup do
        @c_api = Calendar::Api.new(@gapps_config)
      end

      should "have a token" do
        assert @c_api.token
      end
      
      should "be associated with only one calendar" do
        all_cals= @u1.get_calendars(@c_api)
        assert_kind_of Array, all_cals
        assert_equal all_cals.length, 1
      
        base_cal = all_cals.first
      
        assert_kind_of CalendarEntity, base_cal
        assert_equal base_cal.full_id, @u1.full_id # entity_for_base_calendar
        assert_equal base_cal, @u1.entity_for_base_calendar  # entity_for_base_calendar
      
      end
      
      should "be able to retrieve a calendar's acl" do
        u1_cal = @u1.get_calendars(@c_api).detect { |c| c == @u1.entity_for_base_calendar }
        assert u1_cal
      
        acls = u1_cal.get_acls(@c_api)
        assert_kind_of Array, acls
      
        dom_acl = acls.detect { |a| a.scope == Entity.new(:kind => "domain", :id => "ocelot.cul.columbia.edu")}
        assert dom_acl
        assert_equal dom_acl.role, "read"
      end
      
      
      should " be able to create, update, remove a calendar's acl" do
        u1_cal = @u1.entity_for_base_calendar
        acls = u1_cal.get_acls(@c_api)  
      
        u3_freebusy_u1 = CalendarAcl.new(:calendar => u1_cal, :scope => @u3, :role => "freebusy")
        u3_owner_u1 = CalendarAcl.new(:calendar => u1_cal, :scope => @u3, :role => "owner")
      
        @c_api.remove_calendar_acl(u3_freebusy_u1)
      
        acls_before_create = u1_cal.get_acls(@c_api)        
        assert_nil acls_before_create.detect { |a| a.scope == @u3}
      
        @c_api.set_calendar_acl(u3_freebusy_u1)
      
        acls_after_create = u1_cal.get_acls(@c_api)        
        assert acls_after_create.detect { |a| a.scope == @u3 && a.role == "freebusy"}
      
        @c_api.set_calendar_acl(u3_owner_u1)
      
        acls_after_update = u1_cal.get_acls(@c_api)        
        assert acls_after_update.detect { |a| a.scope == @u3 && a.role == "owner"}
      
      
        @c_api.remove_calendar_acl(u3_freebusy_u1)
      
        acls_after_delete = u1_cal.get_acls(@c_api)        
        assert_nil acls_after_delete.detect { |a| a.scope == @u3}
      
      end
      
      should " be able to delete a calendar's acl by updating to none" do
        u1_cal = @u1.entity_for_base_calendar
      
        u3_freebusy_u1 = CalendarAcl.new(:calendar => u1_cal, :scope => @u3, :role => "freebusy")
        u3_none_u1 = CalendarAcl.new(:calendar => u1_cal, :scope => @u3, :role => "none")
      
        @c_api.set_calendar_acl(u3_freebusy_u1)
      
        acls_after_create = @c_api.retrieve_acls_for_calendar(u1_cal)        
        assert acls_after_create.detect { |a| a.scope == @u3 && a.role == "freebusy"}
      
        @c_api.set_calendar_acl(u3_none_u1)
      
        acls_after_delete = @c_api.retrieve_acls_for_calendar(u1_cal)        
        assert_nil acls_after_delete.detect { |a| a.scope == @u3}
      end
      
      should " be able to add and remove a subscription if the person is the owner" do
        u1_cal = @u1.entity_for_base_calendar
        acls = u1_cal.get_acls(@c_api)  
      
        u3_owner_u1 = CalendarAcl.new(:calendar => u1_cal, :scope => @u3, :role => "owner")
        u3_editor_u1 = CalendarAcl.new(:calendar => u1_cal, :scope => @u3, :role => "editor")
        u3_none_u1 = CalendarAcl.new(:calendar => u1_cal, :scope => @u3, :role => "none")
      
        @c_api.set_calendar_acl(u3_owner_u1)
        @c_api.add_calendar_to_user(u1_cal, @u3)
        
      
        assert @c_api.retrieve_calendar_for_user(u1_cal, @u3)
      
        @c_api.set_calendar_acl(u3_editor_u1)

        assert @c_api.retrieve_calendar_for_user(u1_cal, @u3)
      
        @c_api.set_calendar_acl(u3_none_u1)
        @c_api.remove_calendar_from_user(u1_cal, @u3)
      
        assert_nil @c_api.retrieve_calendar_for_user(u1_cal, @u3)
      end
      
      
      should "be able to retrieve a calendar's title and other details" do
        u1_cal = @u1.entity_for_base_calendar
        u1_cal = @c_api.retrieve_calendar_for_user(u1_cal, @u1)
      
        assert u1_cal.details.has_key?(:title)
        assert u1_cal.details[:title], "__user1@ocelot.cul.columbia.edu"
      
      end
      
      
      
      should "be able to update a calendar's title and selectedness" do
      
      
      
        u1_cal = @u1.get_base_calendar(@c_api)
      
        @c_api.update_calendar_for_user(u1_cal, @u1, :summary => "test", :title => "User 1 Calendar", :selected => false)
      
        u1_cal = @u1.get_base_calendar(@c_api)
      
        assert_equal u1_cal.details[:title], "User 1 Calendar"
        assert_equal u1_cal.details[:timezone], "UTC"
        assert_equal u1_cal.details[:color], "#2952A3"
        assert_equal u1_cal.details[:summary], "test"
        assert_equal u1_cal.details[:accesslevel], "owner"
        assert_equal u1_cal.details[:where], ""
      
        assert_false u1_cal.details[:selected]
        assert_false u1_cal.details[:hidden]
      
        @c_api.update_calendar_for_user(u1_cal, @u1, :title => "__user1@ocelot.cul.columbia.edu", :summary => "", :selected => true)
      
        u1_cal = @u1.get_base_calendar(@c_api)
      
      
        assert_equal u1_cal.details[:title], "__user1@ocelot.cul.columbia.edu"
        assert_equal u1_cal.details[:timezone], "UTC"
        assert_equal u1_cal.details[:color], "#2952A3"
        assert_equal u1_cal.details[:summary], ""
        assert_equal u1_cal.details[:accesslevel], "owner"
        assert_equal u1_cal.details[:where], ""
      
        assert u1_cal.details[:selected]
        assert_false u1_cal.details[:hidden]
      
      
      
      end

      should "be able to update a calendar's selectedness and hiddenness for another user" do
        u1_cal = @u1.entity_for_base_calendar
      
      
        u3_owner_u1 = CalendarAcl.new(:calendar => u1_cal, :scope => @u3, :role => "owner")
        u3_freebusy_u1 = CalendarAcl.new(:calendar => u1_cal, :scope => @u3, :role => "freebusy")
        u3_none_u1 = CalendarAcl.new(:calendar => u1_cal, :scope => @u3, :role => "none")
      
        @c_api.set_calendar_acl(u3_owner_u1)
        @c_api.add_calendar_to_user(u1_cal, @u3)
      
        @c_api.set_calendar_acl(u3_freebusy_u1)
      
      
        @c_api.update_calendar_for_user(u1_cal, @u3, :hidden => true, :selected => false)
        u1_cal_u3 = @c_api.retrieve_calendar_for_user(u1_cal, @u3)
        
        assert_false u1_cal_u3.details[:selected]
        assert u1_cal_u3.details[:hidden]
        
        @c_api.update_calendar_for_user(u1_cal, @u3, :hidden => false, :selected => true)
        
        sleep 1
        
        u1_cal_u3 = @c_api.retrieve_calendar_for_user(u1_cal, @u3)
      
        assert u1_cal_u3
        assert u1_cal_u3.details[:selected]
        assert_false u1_cal_u3.details[:hidden]
      
      
        @c_api.set_calendar_acl(u3_none_u1)
        @c_api.remove_calendar_from_user(u1_cal, @u3)
      
      end


      should "be able to update a calendar's details via set_calendar" do
        u1_cal = @u1.entity_for_base_calendar
      
        @c_api.remove_calendar_from_user(u1_cal, @u3)
      
        @c_api.set_calendar_for_user(u1_cal, @u3, :accesslevel => "editor", :hidden => true, :selected => false)
  
        u1_cal_u3 = @c_api.retrieve_calendar_for_user(u1_cal, @u3)

        assert u1_cal_u3
        assert_equal u1_cal_u3.details[:accesslevel], "editor"
        assert_false u1_cal_u3.details[:selected]
        assert u1_cal_u3.details[:hidden]
        
        @c_api.set_calendar_for_user(u1_cal, @u3, :hidden => false, :selected => true)
        u1_cal_u3 = @c_api.retrieve_calendar_for_user(u1_cal, @u3)
        
        assert u1_cal_u3.details[:selected]
        assert_false u1_cal_u3.details[:hidden]
        
        @c_api.set_calendar_for_user(u1_cal, @u3, :accesslevel => "none")
        
      
      end
      

      should "be able to set a title for a calendar via set_calendar" do
        @c_api.set_calendar_for_user(@u1.entity_for_base_calendar, @u1, :title => "User 1 Calendar")
        
        assert_equal @u1.get_base_calendar(@c_api).details[:title], "User 1 Calendar"

        @c_api.set_calendar_for_user(@u1.entity_for_base_calendar, @u1, :title => "__user1@ocelot.cul.columbia.edu")


        assert_equal @u1.get_base_calendar(@c_api).details[:title], "__user1@ocelot.cul.columbia.edu"

      end

    end

  end
end
