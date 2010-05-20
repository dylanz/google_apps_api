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
      @p_api = Provisioning::Api.new(@gapps_config)
      @u1 = @p_api.retrieve_user("__user1")
      @u2 = @p_api.retrieve_user("__user2")
    end

    context "and a calendar api " do
      setup do
        @c_api = Calendar::Api.new(@gapps_config)
      end

      should "have a token" do
        assert @c_api.token
      end

      should "be associated with only one calendar" do
        all_cals= @c_api.retrieve_calendars_for_user(@u1)
        assert_kind_of Array, all_cals
        assert_equal all_cals.length, 1

        base_cal = all_cals.first

        assert_kind_of CalendarEntry, base_cal
        assert_equal base_cal.entity.name, @u1.to_url
        assert_equal base_cal.role, "owner"
      end

      # 
      # should "be able to add and remove another calendar" do
      #   rc_cal = CalendarEntry.new(:calendar_id => "nco2104@ocelot.cul.columbia.edu", :title => "Nada O'Neal")
      #   
      #   existing_cals = @c_api.retrieve_calendars_for_user(@u1)
      #   assert_equal existing_cals.length, 1
      #   
      # 
      #   @c_api.add_calendar_to_user(rc_cal, @u1)
      # 
      #   @c_api.delete_calendar_from_user(rc_cal, @u1)
      # 
      # 
      #   existing_cals = @c_api.retrieve_calendars_for_user(@u1)
      #   assert_equal existing_cals.length, 1
      # 
      #   
      # end

      should "be able to retrieve a calendar's acl" do
        cals = @c_api.retrieve_calendars_for_user(@u1)
        u1_cal = cals.detect { |c| c.calendar_id == @u1.to_url }

        assert u1_cal

        acls = @c_api.retrieve_acls_for_calendar(u1_cal)        
        assert_nil acls.detect { |a| a.entity == @u2.to_entity }
        
        
        u2_freebusy_u1 = CalendarEntry.new(:entity => @u2.to_entity, :calendar_id => u1_cal.calendar_id, :role => "freebusy")
        
        @c_api.create_calendar_entry_acl(u2_freebusy_u1)
        

        acls_after = @c_api.retrieve_acls_for_calendar(u1_cal)        
        assert_nil acls_after.detect { |a| a.entity == @u2.to_entity }
        
      end
      
        
    end
    
    
    # should "be able to add and remove other calendars" do
    #   rc_cal = CalendarEntry.new(:id => "rc13@ocelot.cul.columbia.edu", :title => "Robert Cartolano")
    # 
    #   hol_cal = CalendarEntry.new(:id => "en.usa%23holiday%40group.v.calendar.google.com", :title => "US Holidays")
    # 
    #   puts  @api.retrieve_calendars_for_user("rc13@ocelot.cul.columbia.edu").inspect
    #   res = @api.delete_calendar_from_user("rc13@ocelot.cul.columbia.edu", "andrew0@ocelot.cul.columbia.edu")
    #   cals = @api.retrieve_calendars_for_user("andrew0@ocelot.cul.columbia.edu")
    #   count = cals.length
    # 
    #   
    #   res = @api.create_calendar_acl_for_user("rc13@ocelot.cul.columbia.edu", :editor, "andrew0@ocelot.cul.columbia.edu", :debug => true)
    #   # res = @api.add_calendar_to_user(rc_cal, "andrew0@ocelot.cul.columbia.edu", :debug => true)
    #   assert_kind_of CalendarAclEntry, res
    #   
    #   assert_equal count + 1, @api.retrieve_calendars_for_user("andrew0@ocelot.cul.columbia.edu").length
    # 
    # 
    #   res = @api.delete_calendar_from_user("rc13@ocelot.cul.columbia.edu",  "andrew0@ocelot.cul.columbia.edu")
    #   
    #   debugger
    #   
    #   res = @api.update_calendar_acl_from_user("rc13@ocelot.cul.columbia.edu", :none, "andrew0@ocelot.cul.columbia.edu")
    # 
    #   assert_equal count , @api.retrieve_calendars_for_user("andrew0@ocelot.cul.columbia.edu").length
    # 
    # end
    # 
    # 
    # should "be able to change format of a response" do
    #   assert_kind_of Array, @api.retrieve_calendars_owned_by_user("andrew0@ocelot.cul.columbia.edu", :return_format => GoogleAppsApi::CalendarEntry)      
    # 
    #   assert_kind_of Nokogiri::XML::Document, @api.retrieve_calendars_owned_by_user("andrew0@ocelot.cul.columbia.edu", :return_format => :xml)      
    # 
    #   assert_kind_of String, @api.retrieve_calendars_owned_by_user("andrew0@ocelot.cul.columbia.edu", :return_format => :text)      
    # 
    # end
    # 
    # 
    # should "be able to retrieve a specific calendar acl" do
    #   rem = @api.remove_calendar_acl_for_user("rc13@ocelot.cul.columbia.edu",  "andrew0@ocelot.cul.columbia.edu")
    #         
    #   acl = @api.retrieve_calendar_acl_for_user("rc13@ocelot.cul.columbia.edu", "user", "andrew0@ocelotlot.cul.columbia.edu")
    #   assert_equal acl.role, :none
    # 
    # 
    #   # @api.set_calendar_acl_for_user("rc13@ocelot.cul.columbia.edu", :freebusy, "andrew0@ocelot.cul.columbia.edu")
    #   # 
    #   # acls= @api.retrieve_calendar_acls("rc13@ocelot.cul.columbia.edu")
    #   # assert_equal :freebusy,  acls.detect { |acl| acl.calendar_id.include?("andrew0")}.role
    #   # 
    #   # 
    #   # @api.set_calendar_acl_for_user("rc13@ocelot.cul.columbia.edu", :editor, "andrew0@ocelot.cul.columbia.edu")
    #   # 
    #   # acls= @api.retrieve_calendar_acls("rc13@ocelot.cul.columbia.edu")
    #   # assert_equal :freebusy,  acls.detect { |acl| acl.calendar_id.include?("andrew0")}.role
    #   # 
    #   
    # end
    # 
    # 
    # should "be able to create and remove a calendar acl" do
    # 
    #   @api.delete_calendar_from_user("rc13@ocelot.cul.columbia.edu", "andrew0@ocelot.cul.columbia.edu")
    #   acls= @api.retrieve_calendar_acls("rc13@ocelot.cul.columbia.edu")
    #   calendars = @api.retrieve_calendars_for_user("andrew0@ocelot.cul.columbia.edu")
    # 
    #   assert_false acls.any? { |acl| acl.calendar_id.include?("andrew0")}
    #   assert_false calendars.any? { |cal| cal.id.include?("rc13")}
    #   
    #   
    #   @api.create_calendar_acl_for_user("rc13@ocelot.cul.columbia.edu", :editor, "andrew0@ocelot.cul.columbia.edu")
    #   
    # 
    #   acls= @api.retrieve_calendar_acls("rc13@ocelot.cul.columbia.edu")
    #   calendars = @api.retrieve_calendars_for_user("andrew0@ocelot.cul.columbia.edu")
    #   
    #   assert acls.any? { |acl| acl.scope_id.include?("andrew0")}
    #   assert calendars.any? { |cal| cal.id.include?("rc13")}
    # 
    #   @api.remove_calendar_acl_for_user("rc13@ocelot.cul.columbia.edu",  "andrew0@ocelot.cul.columbia.edu")
    # 
    # 
    # 
    # end
    
  end

  # context "given a calendar entry" do
  #   setup do
  #     @andrew_cal = CalendarEntry.new
  #     @andrew_cal.id = "rc13@ocelot.cul.columbia.edu"
  #     @andrew_cal.title = "Andrew Johnston"
  #   end
  #   
  #   should "generate an add message" do
  #     assert_kind_of String, @andrew_cal.add_message
  #   end
  #   
  # end

end
