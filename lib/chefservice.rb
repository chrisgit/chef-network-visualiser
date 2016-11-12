#  Show network by_environment
class EnvironmentNetwork
  DIR = 'images/'
  EDGE_LENGTH_MAIN = 150;

  def initialize(chef_api)
    @chef_api = chef_api
  end
  
  def clouds
    environments = @chef_api.search(:environment, 'name:*')
    name_description = environments.map {|env| {'name' => env.name, 'description' => env.description} }.sort_by {|i| i['name']}
    name_description
  end
  
  def cloud_detail(cloud_id)
    nodes = []
    edges = []
    chef_nodes = @chef_api.partial_search(:node, "chef_environment:#{cloud_id}",  ['ipaddress', 'chef_environment', 'roles', 'expanded_run_list'])
    roles = chef_nodes.map {|node| node.automatic_attributes['roles'].nil? ? 'no role' : node.automatic_attributes['roles'].first }.uniq
    roles.each do | role |
      role_description = 'role'
      if role != 'no role'
        role_detail = @chef_api.search(:role, "name:#{role}")
        role_description = role_detail.length == 0 ? 'role not found' : role_detail.first.description
      end
      nodes << {id: role, label: role, image: DIR + 'Network-Pipe-icon.png', shape: 'image', title: role_description}
    end
    
    chef_nodes.each do |chef_node|
      short_name = chef_node.chef_id.split('.').first
      nodes << {id: short_name, label: short_name, image: DIR + 'Hardware-My-Computer-3-icon.png', shape: 'image', title: chef_node.chef_id, chef_id: chef_node.chef_id }
      role = chef_node.automatic['roles'].nil? ? 'no role' : chef_node.automatic['roles'].first
      edges << {from: role, to: short_name, length: EDGE_LENGTH_MAIN}
    end
    
    return {nodes: nodes, edges: edges}
  end
  
end

# Show network by_role
class RoleNetwork
  DIR = 'images/'
  EDGE_LENGTH_MAIN = 150;

  def initialize(chef_api)
    @chef_api = chef_api
  end
  
  def clouds
    roles = @chef_api.search(:role, 'name:*')
    name_description = roles.map {|role| {'name' => role.name, 'description' => role.description} }.sort_by {|i| i['name']}
    name_description
  end
  
  def cloud_detail(cloud_id)
    nodes = []
    edges = []

    # Primary selection is Environemnt, secondary selection is Role
    chef_nodes = @chef_api.partial_search(:node, "role:#{cloud_id}",  ['ipaddress', 'chef_environment', 'roles', 'expanded_run_list'])
    
    environments = chef_nodes.map {|node| node.automatic_attributes['chef_environment'] }.uniq
    environments.each do | environment |
      environment_detail = @chef_api.search(:environment, "name:#{environment}")
      environment_description = environment_detail.length == 0 ? 'no environment found' : environment_detail.first.description
      nodes << {id: environment, label: environment, image: DIR + 'Network-Pipe-icon.png', shape: 'image', title: environment_description}
    end

    chef_nodes.each do |chef_node|
      short_name = chef_node.chef_id.split('.').first
      nodes << {id: short_name, label: short_name, image: DIR + 'Hardware-My-Computer-3-icon.png', shape: 'image', title: chef_node.chef_id, chef_id: chef_node.chef_id }
      environment = chef_node.automatic['chef_environment'].nil? ? 'no environment found' : chef_node.automatic['chef_environment']
      edges << {from: environment, to: short_name, length: EDGE_LENGTH_MAIN}
    end
    
    return {nodes: nodes, edges: edges}
  end

end

# Show network by custom setting
class CustomNetwork
  DIR = 'images/'
  EDGE_LENGTH_MAIN = 150;
  
  EDGE_LINKS = {
          'WAFServer' => ['WebServer'],
          'WebServer' => ['TelephonyServer', 'MonitoringServer'],
          'TelephonyServer' => ['DatabaseServer'],
          'DatabaseServer' => []
        }


  def initialize(chef_api)
    @chef_api = chef_api
  end
  
  def clouds
    [ {'name' => 'Cloud9'}, {'name' => 'Cloud11'}, {'name' => 'Cloud17'}, {'name' => 'Cloud98'}, {'name' => 'Cloud444'} ]
  end
  
  def cloud_detail(cloud_id)
    nodes = []
    edges = []
    chef_environments = @chef_api.search(:environment, "name:*#{cloud_id}")
    unique_environments = summarise_nvm_environments(chef_environments)
    # Base nodes, the environments, marked as network pipes
    unique_environments.each do | environment, description |
      nodes << {id: environment, label: environment, image: DIR + 'Network-Pipe-icon.png', shape: 'image', title: description} 
    end
    
    # Base edges, kinda soft configured, could also iterate through the EGDE links and do a lookup into unique_environments, this might be better ...
    unique_environments.each do | environment, description |
      next unless EDGE_LINKS.key?(environment)
      EDGE_LINKS[environment].each do |link|
        # Should test to see if NODE exists before setting up a link, currently I've hard coded so I know that the NODE exists
        edges << {from: environment, to: link, length: EDGE_LENGTH_MAIN}
      end
    end

    chef_nodes = @chef_api.partial_search(:node, "chef_environment:*#{cloud_id}",  ['ipaddress', 'chef_environment'])
    chef_nodes.each do |chef_node|
      short_name = chef_node.chef_id.split('.').first
      nodes << {id: short_name, label: short_name, image: DIR + 'Hardware-My-Computer-3-icon.png', shape: 'image', title: chef_node.chef_id, chef_id: chef_node.chef_id }
      basename = chef_node.automatic['chef_environment'].split('-').first
      edges << {from: basename, to: short_name, length: EDGE_LENGTH_MAIN}
    end
    
    return {nodes: nodes, edges: edges}
  end
  
  private
  # Summerise, take name from DatabaseServer-Testing-Cloud3 and reduce to DatabaseServer
  # unique_environments = environments.map{|e| {name: e.chef_id, description: e.description}}.group_by{|e| e[:name].split('-').first}
  def summarise_nvm_environments(environments)
    resources = environments.each_with_object({}) do |environment,summary| 
      next if summary.key?(environment.env_cookbook_name) 
      summary[environment.env_cookbook_name] = environment.description
    end
  end
end
