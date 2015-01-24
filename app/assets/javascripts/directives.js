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

directive("erliTooltip", [
	"$tooltip", "$timeout",
	function($tooltip, $timeout){
		return {
			restrict: "A",
			scope: true,
			link: function(scope, element, attrs){
				scope.erli_enabled = false;
				element.bind("click", function(e){
					e.preventDefault();
					if(!scope.erli_enabled){
						var t = $tooltip(element, {
							template: attrs.tooltipUrl,
							title: attrs.title,
							placement: attrs.placement,
							autoClose: 1,
							trigger: "click"
						})
				
						t.$promise.then(function(y){
							t.show();
							scope.erli_enabled = true;
						});
					}
				});
			}
		}
	}
]).

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
			controller: ["$scope", function($scope){
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
				
				
			}]
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
				calendarController.showControls = true;
				
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
				
		        scope.drillDown = function(day) {
					calendarController.changeView('day', moment(scope.currentDay).clone().date(day).toDate());
		        };
				
			}
		}
	}

]).

directive("calendarDay", [
	"$sce", "$timeout", "calendarHelperService",
	function($sce, $timeout, calendarHelperService){
		return {
			templateUrl: "templates/day.html",
			restrics: "A",
			require: "^calendar",
			scope: {
				currentDay: "=calendarCurrentDay"
			},
			link: function postLink(scope, element, attrs, calendarController){
				
				calendarController.showControls = false;
				
			}
		}
	}
]);