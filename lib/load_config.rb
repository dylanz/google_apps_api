module GoogleAppsApi

  def self.load_yaml_configs
    result = {}
    Dir.glob(File.dirname(__FILE__) + "/config/*.yml").each do |file|
        result.merge!(YAML::load(File.open(file)))
    end
    
    return result
  end

  @@config = GoogleAppsApi::load_yaml_configs
  
  mattr_reader :config
  
  
end