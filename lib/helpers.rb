# Class used to provide application level helper
class ApplicationHelper
  def self.app_root
    ::File.expand_path(::File.join(::File.dirname(__FILE__), '..'))
  end
end
