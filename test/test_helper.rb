require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'ruby-debug'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'google_apps_api'

class Test::Unit::TestCase
  
  def assert_false(object, message="")
    assert_equal(false, object, message)
  end
  
  
  def random_letters(num, prefix = "", suffix = "")
    prefix + (0...num).map{65.+(rand(25)).chr}.join + suffix
  end
end
