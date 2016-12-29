	// Allow string interpolation http://javascript.crockford.com/remedial.html
	String.prototype.supplant = function (o) {
      return this.replace(/{([^{}]*)}/g,
        function (a, b) {
            var r = o[b];
            return typeof r === 'string' || typeof r === 'number' ? r : a;
        }
      );
    }
	
	// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter
	function findIDorLabel(search_value) {
		/*
		var result = nodes.filter(function( obj ) {
 			obj.id == search_value || obj.label == search_value;
		});
		*/
		search_value = search_value.toLowerCase()
		match = null;
		for (var key in network.body.data.nodes._data) {
  			if (network.body.data.nodes._data[key].id.toLowerCase() == search_value ||
			  network.body.data.nodes._data[key].label.toLowerCase() == search_value) {
			  match = network.body.data.nodes._data[key].id;
			  break;
			};
		};
		return match;
	}

	function doSearch() {
		search_textbox = document.getElementById('node_search');
		match_item = findIDorLabel(search_textbox.value);
		node_location =  network.getPositions([match_item]);
		node_reference = node_location[match_item];
		
		var options = {
			// position: {x:positionx,y:positiony}, // not relevant for focus
			scale: 1.0,
			offset: {x:0,y:0},
			animation: true // default duration is 1000ms and default easingFunction is easeInOutQuad.
		};
		
		network.focus(match_item, options)
	}

	var urlNetworkViews = "/network_views";
	var urlNetworkNodes = "/network_nodes/{id}";
	var urlNodeDetail = "/node_detail/{id}";

	var urlNodeStats = "/node_stats";
	var urlEnvironmentStats = "/environment_stats";
	var urlRoleStats = "/role_stats";

	// Generic AJAX method
	function getData(request_url, request_callback) {
		$.ajax({
			dataType: 'json',
			url: request_url,
			success: request_callback
		});
	}

    // Requires call back due to fact that call is asynchronous
	// TODO: change URL dependant on current running port
    var response = null;
	function getNetworkNodes(view_id) {
		url = urlNetworkNodes.supplant({id: view_id});
		getData(url, gotNetworkNodes);
	}

	function getStats(urlStats, callback) {
		getData(urlStats, callback);		
	}

	function gotNetworkNodes(r) {
		response = r;
		displayNetwork();
	}
	
	var network_placeholder = null;
	var network_created = null;

	function displayNetwork() {
		// create a network
		var container = document.getElementById(network_placeholder);
		var data = {
			nodes: response.nodes,
			edges: response.edges
		};
		
		var options = {
			height: '600px'
		};
		network = new vis.Network(container, data, options);
		// network.setOptions(options);
		// network.setSize('100%', '800px')

		if (network_created != null) {
			network_created(network);
		}
	}
