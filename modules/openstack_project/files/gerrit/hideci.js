// this regex matches the hash part of review pages
var hashRegex = /^\#\/c\/[\/\d]+$/
// this regex matches CI comments
var ciRegex = / CI$/
// this regex matches "Patch set #"
var psRegex = /^Patch Set (\d+):/

ci_update_table = function() {
    var patchsets = []; 

    $("div.commentPanel").each(function() {
	// Find every comment...
        var pstext = $(this).find("div.commentPanelMessage").find("p")[0].innerHTML;
	// ...that starts with "Patch Set"
	var match = psRegex.exec(pstext);
	if (match !== null) {
	    // Extract the number, and make sure our array of patchset info extends that far
	    var psnum = parseInt(match[1]);
	    while (patchsets.length < psnum) {
		patchsets.push({});
	    }
	    // Search this comment for results
	    var result_list = [];
	    $(this).find("li.comment_test").each(function(i, li) {
		var result = {};
		result["name"] = $(li).find("span.comment_test_name").find("a")[0].innerHTML;
		result["link"] = $(li).find("span.comment_test_name").find("a")[0];
		result["result"] = $(li).find("span.comment_test_result")[0];
		result_list.push(result);
	    });

	    // If this comment has results
	    if (result_list.length > 0) {
		// Get the name of the system
		var name = this.getAttribute("name");
		// an item in patchsets is a hash of systems
		var systems = patchsets[psnum-1];
		var system;
		// Get or create the system object for this system
		if (name in systems) {
		    system = systems[name];
		} else {
		    // A system object has an ordered list of jobs (so
		    // we preserve what was in the comments), and a
		    // hash of results (so later runs of the same job
		    // on the same patchset override previous results).
		    system = {"jobs": [], "results": {}}
		    systems[name] = system;
		}
		$.each(result_list, function(i, result) {
		    // For each result, add the name of the job to the
		    // ordered list if it isn't there already
		    if (system["jobs"].indexOf(result["name"]) < 0) {
			system["jobs"].push(result["name"]);
		    }
		    // Then set or override the result
		    system["results"][result["name"]] = result;
		});
	    }
	}
    });

    if (patchsets.length > 0) {
        // Create a table and insert it after the approval table
	var table = $("table.test_result_table")[0];
	if (!table) {
	    var outer_table = document.createElement("table");
	    $(outer_table).insertBefore($("div.approvalTable"));
	    var outer_table_row = document.createElement("tr");
	    $(outer_table).append(outer_table_row);
	    var td = document.createElement("td");
	    $(outer_table_row).append(td);
	    $(td).css({"vertical-align":"top"});
	    $(td).append($("div.approvalTable"));
            table = document.createElement("table");
	    $(table).addClass("test_result_table").addClass("infoTable").css({"margin-top":"1em", "margin-bottom":"1em"});
	    td = document.createElement("td");
	    $(outer_table_row).append(td);
	    $(td).css({"vertical-align":"top"});
	    $(td).append(table);
	    // Hide existing comments
	    ci_toggle_visibility();
	} else {
	    $(table).empty();
	}
        var patchset = patchsets[patchsets.length-1];
        $.each(patchset, function(name, system) {
    	    // Add a header for each system
    	    var header = $("<tr>").append($('<td class="header" colspan="2">'+name+'</td>'));
    	    $(table).append(header)
    	    // Add the results
    	    $.each(system["jobs"], function(i, name) {
    		var result = system["results"][name]
    		var tr = $("<tr>");
    		tr.append($("<td>").append($(result["link"]).clone()));
    		tr.append($("<td>").append($(result["result"]).clone()));
    		$(table).append(tr)
    	    });
        });
    }
};

ci_page_loaded = function() {
    if (hashRegex.test(window.location.hash)) {
        $("#toggleci").show();
	ci_update_table();
    } else {
        $("#toggleci").hide();
    }
};

ci_toggle_visibility = function() {
    // CI comments in New Screen
    $("div").filter(function() {
        return ciRegex.test(this.innerHTML);
    }).parent().parent().parent().toggle();

    // CI comments in Old Screen
    $("div").filter(function() {
        return ciRegex.test(this.getAttribute('name'));
    }).toggle();
};

window.onload = function() {
    var input = document.createElement("input");
    input.id = "toggleci";
    input.type = "button";
    input.className = "gwt-Button";
    input.value = "Toggle CI";
    input.onclick = ci_toggle_visibility;
    document.body.appendChild(input);

    MutationObserver = window.MutationObserver || window.WebKitMutationObserver;
    var observer = new MutationObserver(function(mutations, observer) {
	var span = $("span.rpcStatus");
	$.each(mutations, function(i, mutation) {
	    if (mutation.target === span[0] &&
	      	(!(span.is(":visible:")))) {
		ci_page_loaded();
	    }
	});
    });
    observer.observe(document, {
	subtree: true,
	attributes: true
    });

    //ci_page_loaded();
};

