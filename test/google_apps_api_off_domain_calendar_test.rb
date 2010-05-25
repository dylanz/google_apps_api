require 'test_helper'

class GoogleAppsApiOffDomainCalendarTest < Test::Unit::TestCase
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

      should "be able to set off domain acls" do
        u1_cal = @u1.entity_for_base_calendar
        james_off = CalendarAcl.new(:calendar => u1_cal, :scope => UserEntity.new("apps.cul.columbia.edu_@domain.calendar.google.com"), :role => "read")

        @c_api.set_calendar_acl(james_off)
      end
    end
  end
end