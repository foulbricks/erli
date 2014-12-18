"use strict"

angular.module("erli", []).

config(["$httpProvider", 
	function(provider){
		provider.defaults.headers.common["X-CSRF-Token"] = $('meta[name=csrf-token]').attr('content');
	}
]).

run(["moment", function(moment){
	moment.locale("en");
}]);

$(document).on("ready page:load", function(args){
	angular.bootstrap(document.body, ["erli"]);
});