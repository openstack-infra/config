// this regex matches the hash part of review pages
var hashRegex = /^\#\/c\/[\/\d]+$/
// this regex matches CI comments
var ciRegex = / CI$/

window.onload = function() {
    var input = document.createElement("input");
    input.id = "toggleci";
    input.type = "button";
    input.className = "gwt-Button";
    input.value = "Toggle CI";
    input.onclick = function() {
        // CI comments in New Screen
        $("div").filter(function() {
            return ciRegex.test(this.innerHTML);
        }).parent().parent().parent().toggle();

        // CI comments in Old Screen
        $("div").filter(function() {
            return ciRegex.test(this.getAttribute('name'));
        }).toggle();
    }
    document.body.appendChild(input);
    if (!hashRegex.test(window.location.hash)) {
        $("#toggleci").hide();
    }
};

window.onhashchange = function() {
    if (hashRegex.test(window.location.hash)) {
        $("#toggleci").show();
    } else {
        $("#toggleci").hide();
    }
};
