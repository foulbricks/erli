angular.module("erli").

controller("loginController", [
	"$scope",
	function($scope){
		
	}
]).

controller("userFormController", [
	"$scope",
	function($scope){
		$scope.firstName = angular.element("#user_first_name").val();
		$scope.lastName = angular.element("#user_last_name").val();
		$scope.email = angular.element("#user_email").val();
	}
]).

controller("buildingFormController", [
	"$scope",
	function($scope){
		$scope.name = angular.element("#building_name").val();
	}
]).

controller("CalendarController", [
	"$scope", "moment",
	function($scope, moment){
		$scope.calendarView = "month";
		$scope.calendarDay = new Date();
		
		$scope.setCalendarToToday = function(){
			$scope.calendarDay = new Date();
		}
		
		$scope.setCalendarView = function(view){
			$scope.calendarView = view;
		}
	}
]);