require 'chef_zero/server'
require 'json'

def load_clients(client_files, chef_server)
	Dir[client_files].each do |file_to_load|
		client_json = File.open(file_to_load, 'r') { |file| file.read }
		client_hash = { 'clients' => JSON[client_json] }
		chef_server.load_data(client_hash)
	end
end

def load_nodes(node_files, chef_server)
	Dir[node_files].each do |file_to_load|
		node_json = File.open(file_to_load, 'r') { |file| file.read }
		node_hash = { 'nodes' => JSON[node_json] }
		chef_server.load_data(node_hash)
	end
end

def load_roles(role_files, chef_server)
	Dir[role_files].each do |file_to_load|
		role_json = File.open(file_to_load, 'r') { |file| file.read }
		role_hash = { 'roles' => JSON[role_json] }
		chef_server.load_data(role_hash)
	end
end

def load_environments(environment_files, chef_server)
	Dir[environment_files].each do |file_to_load|
      environment_json = File.open(file_to_load, 'r') { |file| file.read }
      environment_hash = { 'environments' => JSON[environment_json] }
      chef_server.load_data(environment_hash)
	end
end

# Load zero server
# Check with http://localhost:8889 
# Then http://localhost:8889/nodes then http://localhost:8889/roles etc
# Dig down futher ... i.e. http://localhost:8889/nodes/web_sever08
chef_zero_root = File.dirname(__FILE__)
chef_server = ChefZero::Server.new(port: 8889)
chef_server.clear_data
load_clients(File.join(chef_zero_root, 'clients', '*.json'), chef_server)
load_nodes(File.join(chef_zero_root, 'nodes', '*.json'), chef_server)
load_roles(File.join(chef_zero_root, 'roles', '*.json'), chef_server)
load_environments(File.join(chef_zero_root, 'environments', '*.json'), chef_server)
chef_server.start_background
#chef_server.start

module ChefNetworkViewer
	# Class used to communicate with the Chef server
	class ChefAPI
		def server
			@ridley ||= Ridley.new(
				server_url: 'http://127.0.0.1:8889',
				node_name: 'demo',
				client_name: 'demo',
				client_key: File.join(File.dirname(__FILE__), 'client.pem'))
		end
	end
end
