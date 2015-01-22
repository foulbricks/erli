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

controller("bollosFormController", [
	"$scope",
	function($scope){
		$scope.from = angular.element("#bollo_range_from").val();
		$scope.to = angular.element("#bollo_range_to").val();
		$scope.price = angular.element("#bollo_range_price").val();
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
		$scope.iva = angular.element("#setup_iva").val();
		$scope.istat = angular.element("#setup_istat").val();
		$scope.balance_expenses = angular.element("#setup_balance_expenses").val();
		$scope.mav_expiration = angular.element("#setup_mav_expiration").val();
		$scope.invoice_generation = angular.element("#setup_invoice_generation").val();
		$scope.invoice_delivery = angular.element("#setup_invoice_delivery").val();
		$scope.unpaid_sentence = angular.element("#setup_unpaid_sentence").val();
		$scope.erli_mav_email = angular.element("#setup_erli_mav_email").val();
		$scope.erli_admin_email = angular.element("#setup_erli_admin_email").val();
	}
]).

controller("apartmentFormController", [
	"$scope",
	function($scope){
		$scope.name = angular.element("#apartment_name").val();
	}
]).

controller("tableFormController", [
	"$scope",
	function($scope){
		$scope.name = angular.element("#repartition_table_name").val();
		var ps = angular.element("input[type=text][id^=repartition_table_apartment_repartition_tables_attributes]");
		for(var i = 0; i < ps.length; i++){
			$scope[angular.element(ps[i]).attr("ng-model")] = angular.element(ps[i]).val();
		}
	}
]).

controller("dateFormController", [
	"$scope",
	function($scope){
		$scope.date = angular.element("#balance_date_value").val();
	}
]).

controller("leaseTableController", [
	"$scope", "$modal",
	function($scope, $modal){
		$scope.openModal = function(event, url){
			event.preventDefault();
			$modal({
				scope: $scope,
				template: url
			});
		}
	}
]).

controller("leaseFormController", [
	"$scope", "$modal",
	function($scope){
		$scope.end_date = angular.element("#lease_end_date").val();
		$scope.userCount = 1;
		$scope.incrementUserCount = function($event){
			$event.preventDefault();
			$scope.userCount = $scope.userCount + 1;
		}
	}
]).

controller("registrationFormController", [
	"$scope",
	function($scope){
	}
]).

controller("leaseAttachmentFormController", [
	"$scope",
	function($scope){
	}
]).

controller("apartmentExpensesController", [
	"$scope", "$http",
	function($scope, $http){
		
	}
]).

controller("apartmentExpenseFormController", [
	"$scope", "$http",
	function($scope, $http){
		
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