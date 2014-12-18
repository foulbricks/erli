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
}).

directive("calendar", [
	"moment",
	function(moment){
		return {
			templateUrl: "templates/calendar.html",
			restrict: "A",
			scope: {
				view: "=calendarView",
				currentDay: "=calendarCurrentDay",
				control: "=calendarControl",
				useIsoWeek: "=calendarUseIsoWeek",
				autoOpen: "=calendarAutoOpen"
			},
			controller: function($scope){
				var self = this;
				self.titleFunctions = {}
				
				self.changeView = function(view, newDay){
					$scope.view = view;
					$scope.currentDay = newDay;
				}
				
				$scope.control = $scope.control || {};
				
				$scope.control.prev = function(){
					$scope.currentDay = moment($scope.currentDay).subtract(1, $scope.view).toDate();
				}
				
				$scope.control.next = function(){
					$scope.currentDay = moment($scope.currentDay).add(1, $scope.view).toDate();
				}
				
				$scope.control.getTitle = function(){
					if(!self.titleFunctions[$scope.view]) return "";
					return self.titleFunctions[$scope.view]($scope.currentDay);
				}
			}
			
		}
	}
]).

directive("calendarMonth", [
	"$sce", "$timeout", "calendarHelperService",
	function($sce, $timeout, calendarHelperService){
		return {
			templateUrl: "templates/month.html",
			restrict: "A",
			require: "^calendar",
			scope: {
				currentDay: "=calendarCurrentDay",
				useIsoWeek: "=calendarUseIsoWeek",
				autoOpen: "=calendarAutoOpen"
			},
			link: function postLink(scope, element, attrs, calendarController){
				var firstRun = false;
				
				scope.$sce = $sce;
				
				calendarController.titleFunctions.month = function(currentDay){
					return moment(currentDay).format("MMMM YYYY");
				}
				
				function updateView(){
					scope.view = calendarHelperService.getMonthView(scope.currentDay, scope.useIsoWeek);
					if(scope.autoOpen && !firstRun){
						scope.view.forEach(function(week, rowIndex){
							if(day.inMonth && moment(scope.currentDay).startOf("day").isSame(day.date.startOf("day"))){
								//scope.dayClicked(rowIndex, cellIndex);
								$timeout(function(){
									firstRun = false;
								});
							}
						});
					}
				}
					
				scope.$watch("currentDay", updateView);
				scope.weekDays = calendarHelperService.getWeekNames(false);
				
			}
		}
	}

]);