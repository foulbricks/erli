angular.module("erli").

directive("compareTo", function(){
	return {
		require: "ngModel",
		scope: {
			otherModelValue: "=compareTo"
		},
		link: function(scope, element, attrs, ngModel){
			ngModel.$validators.compareTo = function(modelValue){
				if(!modelValue && !scope.otherModelValue){
					return true
				}
				else {
					return modelValue == scope.otherModelValue;
				}
			};
			
			scope.$watch("otherModelValue", function(){
				ngModel.$validate();
			});
		}
	}
});