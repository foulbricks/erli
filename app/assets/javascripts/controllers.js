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

controller("expenseFormController", [
	"$scope",
	function($scope){
		$scope.name = angular.element("#expense_name").val();
	}
]).

controller("bolloFormController", [
	"$scope",
	function($scope){
		$scope.identifier = angular.element("#bollo_identifier").val();
		$scope.price = angular.element("#bollo_price").val();
	}
]).

controller("contractFormController", [
	"$scope",
	function($scope){
		$scope.name = angular.element("#contract_name").val();
		$scope.istat = angular.element("#contract_istat").val();
	}
]).

controller("setupFormController", [
	"$scope",
	function($scope){

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