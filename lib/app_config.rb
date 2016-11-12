require 'helpers'

# Global settings
module ChefNetworkViewerSettings
  @_settings = Hash.new({})
	
  def self.chef
    @_settings[:chef]
  end
	
  def self.client_files(client_file_folder)		
    return File.join(client_file_folder, 'client.rb') if File.exist?(File.join(client_file_folder, 'client.rb'))
    return File.join(client_file_folder, 'knife.rb') if File.exist?(File.join(client_file_folder, 'knife.rb'))
    nil
  end

  def self.set_client_config
    client_file = client_files(ApplicationHelper.app_root)
    client_file || client_files(File.join(ENV['HOME'], '.chef'))
  end

  def self.set_defaults()
    @_settings[:chef][:client] = set_client_config
  end
	
  set_defaults
end
