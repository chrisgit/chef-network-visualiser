# Extend Ridley objects to contain more detail
module Ridley
  # Extend the Ridley ChefObject
  class ChefObject
    def url
      "#{url_prefix}/#{chef_id}"
    end

    def url_prefix
      "/#{chef_type}"
    end
  end
end
