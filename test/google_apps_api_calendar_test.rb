require 'test_helper'

class GoogleAppsApiCalendarTest < Test::Unit::TestCase
  include GoogleAppsApi

  def create_random_user(api)
    uid = random_letters(10, "_t_")
    api.create_user(uid, :given_name => random_letters(5), :family_name => random_letters(5), :password => random_letters(10))
  end



  context "given a connection to apps.cul and one user" do
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
        
        u3_cals = @u3.get_calendars(@c_api)
        assert u3_cals.include?(u1_cal)
        
        @c_api.set_calendar_acl(u3_editor_u1)
        
        u3_cals = @u3.get_calendars(@c_api)
        assert u3_cals.include?(@u1.entity_for_base_calendar)

        @c_api.set_calendar_acl(u3_none_u1)

        u3_cals = @u3.get_calendars(@c_api)
        assert_false u3_cals.include?(@u1.entity_for_base_calendar)
      end


      should "be able to retrieve a calendar's selectedness" do
        @u1.get_calendars(@c_api).first.get_detail(:title)
        u1_cal = @u1.entity_for_base_calendar
        @c_api.retrieve_calendar_details(u1_cal, :debug => true)

      end
      
    end

  end
end
