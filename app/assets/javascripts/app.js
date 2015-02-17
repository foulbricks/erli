"use strict"

angular.module("erli", ["mgcrea.ngStrap", "ngAnimate", "ngSanitize"]).

config(["$httpProvider", 
	function(provider){
		provider.defaults.headers.common["X-CSRF-Token"] = $('meta[name=csrf-token]').attr('content');
	}
]).

run(["moment", "$rootScope", function(moment, $rootScope){
	moment.locale("it");
    $rootScope.Utils = {
       keys : Object.keys
    }
}]);

$(document).on("ready page:load", function(args){
	angular.bootstrap(document.body, ["erli"]);
});