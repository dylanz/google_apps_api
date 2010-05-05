require 'test_helper'

class GoogleAppsApiCalendarTest < Test::Unit::TestCase
  include GoogleAppsApi
  
  
  context "given a connection to apps.cul" do
    setup do
      gapps_config =YAML::load_file("private/gapps-config.yml")["apps_ocelot"].symbolize_keys!
      @api = Calendar::Api.new(gapps_config)
    end

    should "have a token" do
      assert @api.token
    end


    # should "be able to retrieve all calendars" do
    #   calendars = @api.retrieve_all_calendars
    #   
    #   assert calendars
    # end
    # 
    # should "be able to retrieve all calendars for self" do
    #   calendars = @api.retrieve_users_calendars(:username => "_sc_api@ocelot.cul.columbia.edu")
    #   puts calendars.class
    # end
    # 
    # 
    should "be able to retrieve own calendars" do
      calendars = @api.retrieve_users_own_calendars(:username => "nco2104@ocelot.cul.columbia.edu")

      
      calendars.each { |c| assert_kind_of CalendarEntry, c }
    end
    
    should "be able to retrieve all calendars subscribed to" do
      calendars = @api.retrieve_users_calendars(:username => "nco2104@ocelot.cul.columbia.edu")
      
      calendars.each { |c| assert_kind_of CalendarEntry, c }
      
    end


    should "be able to add and remove other calendars" do
      jws_cal = CalendarEntry.new
      jws_cal.id = "jws2135%40ocelot.cul.columbia.edu"
      jws_cal.title = "James Stuart"

      res = @api.delete_calendar_from_user(jws_cal, "nco2104@ocelot.cul.columbia.edu")
      
      count = @api.retrieve_users_calendars(:username => "nco2104@ocelot.cul.columbia.edu").length
      
      res = @api.add_calendar_to_user(jws_cal, "nco2104@ocelot.cul.columbia.edu")
      assert_kind_of CalendarEntry, res
      
      assert_equal count + 1, @api.retrieve_users_calendars(:username => "nco2104@ocelot.cul.columbia.edu").length
      
      res = @api.delete_calendar_from_user(res, "nco2104@ocelot.cul.columbia.edu")

      assert_equal count , @api.retrieve_users_calendars(:username => "nco2104@ocelot.cul.columbia.edu").length

    end


  end

  context "given a calendar entry" do
    setup do
      @jws_cal = CalendarEntry.new
      @jws_cal.id = "jws2135%40ocelot.cul.columbia.edu"
      @jws_cal.title = "James Stuart"
    end
    
    should "generate an add message" do
      assert_kind_of String, @jws_cal.add_message
    end
    
  end

end
