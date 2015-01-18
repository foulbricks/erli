"use strict"

angular.module("erli", ["mgcrea.ngStrap", "ngAnimate"]).

config(["$httpProvider", 
	function(provider){
		provider.defaults.headers.common["X-CSRF-Token"] = $('meta[name=csrf-token]').attr('content');
	}
]).

run(["moment", function(moment){
	moment.locale("it");
}]);

$(document).on("ready page:load", function(args){
	angular.bootstrap(document.body, ["erli"]);
});