    var nodes = null;
    var edges = null;
    var network = null;

	// Allow string interpolation http://javascript.crockford.com/remedial.html
	String.prototype.supplant = function (o) {
      return this.replace(/{([^{}]*)}/g,
        function (a, b) {
            var r = o[b];
            return typeof r === 'string' || typeof r === 'number' ? r : a;
        }
      );
    }
	
	function doSearch() {
		search_textbox = document.getElementById('search_text');
		search_for = search_textbox.value;
		node_location =  network.getPositions([search_for]);
		node_reference = node_location[search_for];
		
		var options = {
			// position: {x:positionx,y:positiony}, // not relevant for focus
			scale: 1.0,
			offset: {x:0,y:0},
			animation: true // default duration is 1000ms and default easingFunction is easeInOutQuad.
		};
		
		network.focus(search_for, options)
	}

	function getData(request_url, request_callback) {
		$.ajax({
			dataType: 'json',
			url: request_url,
			success: request_callback
		});
	}

	var urlClouds = "/clouds";
	var urlCloudNode = "/cloud_nodes/{id}";
	var urlNodeDetail = "/node_detail/{id}";
    // Requires call back due to fact that call is asynchronous
	// TODO: change URL dependant on current running port
    var response = null;
	function getCloudNodes(cloud_to_get) {
		url = urlCloudNode.supplant({id: cloud_to_get});
		getData(url, gotCloudNodes);
	}
	
	function gotCloudNodes(r) {
		response = r;
		draw();
	}

	function showNode(params) {
		clicked_node_id = params.nodes[0]
		matched_node = null
		nodes = response.nodes
		for (var i = 0; i < nodes.length; i++) {
			if (nodes[i].id == clicked_node_id) {
				matched_node = nodes[i]
				break
			}
		}
		
        // was matched_node.id but now we only return short name
		url = urlNodeDetail.supplant({id: matched_node.chef_id})
		getData(url, gotNodeDetail)
		return matched_node.add_data ? matched_node.add_data : 'You clicked node id:' + matched_node.id
	}

	function gotNodeDetail(r) {
		node_template = document.getElementById('node-template');
		node_detail = document.getElementById('node-detail');
		<!-- http://jsfiddle.net/superhacker/pRSjH/5/ -->
		rendered_table = Mustache.render(node_template.innerHTML, r);
		node_detail.innerHTML = rendered_table;
	}
	
	function draw() {
		// create a network
		var container = document.getElementById('mynetwork');
		var data = {
			nodes: response.nodes,
			edges: response.edges
		};
		
		var options = {};
		network = new vis.Network(container, data, options);
		
		network.on("selectNode", function (params) {
			params.event = "[original event]";
			showNode(params);
		});
	}
	
	function updateSelectedCloud(environment) {
      $('#environment_selected').text($(environment).text());
	}
	
	function gotCloud(r) {
		environment_template = document.getElementById('environment-template');
		unordered_list = Mustache.render(environment_template.innerHTML, r);
		$('#environment_list').append( unordered_list );
		$("#environment_list li a").click(function() {
			updateSelectedCloud(this);
			getCloudNodes(this.text)
		});
	}
	
	function getClouds()
	{
		getData(urlClouds, gotCloud);
	}

	jQuery(document).ready(function($){
		getClouds();
	
		$("#search_text").keypress(function(e) {
			if(e.which == 13) {
				doSearch();
			}
		});
	});
		