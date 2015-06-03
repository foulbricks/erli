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
							trigger: "click",
							container: "body"
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
				autoOpen: "=calendarAutoOpen",
				eventFilter: "=calendarFilter"
			},
			controller: ["$scope", function($scope){
				var self = this;
				self.titleFunctions = {}
				self.controlFunctions = {}
				
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
				
				$scope.control.showControls = function(){
					if(!self.controlFunctions[$scope.view]) return true;
					return self.controlFunctions[$scope.view]();
				}
			}]
		}
	}
]).

directive("calendarMonth", [
	"$sce", "$timeout", "calendarHelperService", "calendarEventsService", "$rootScope", "$popover",
	function($sce, $timeout, calendarHelperService, calendarEventsService, $rootScope, $popover){
		return {
			templateUrl: "templates/month.html",
			restrict: "A",
			require: "^calendar",
			scope: {
				currentDay: "=calendarCurrentDay",
				useIsoWeek: "=calendarUseIsoWeek",
				autoOpen: "=calendarAutoOpen",
				eventFilter: "=calendarFilter"
			},
			link: function postLink(scope, element, attrs, calendarController){
				var firstRun = false;
				
				scope.$sce = $sce;
				
				scope.keys = $rootScope.Utils.keys;
				scope.loaded = {};
				
				calendarController.titleFunctions.month = function(currentDay){
					return moment(currentDay).format("MMMM YYYY");
				}
				calendarController.showControls = true;
				
				function updateView(){
					calendarEventsService.list(scope.eventFilter).success(function(results){
						scope.view = calendarHelperService.getMonthView(scope.currentDay, scope.useIsoWeek, results);
						scope.loaded = {};
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
					});
				}
				
				scope.loadPopover = function(events, day, $event){
					$event.preventDefault();
					var color = scope.keys(events)[0]
					var el = angular.element("#events-" + day.format("YYYY-MM-DD") + "-" + color.replace("#", ""));
					var dayStr = day.format("DD/MM/YYYY");
					var html = "";
					events = events[color];
					events.forEach(function(event){
						var e = JSON.parse(event);
						html += "<p>"
						html += ("<strong>" + e.title + "</strong>");
						if(e.description){
							html += ("<br />" + e.description);
						}
						html += "</p>";
					});
					
					if(!scope.loaded[el.attr("id")]){
						var p = $popover(el, {
							content: html,
							title: "Eventi di " + dayStr,
							placement: "bottom",
							autoClose: 1,
							trigger: "click",
							container: "body",
							html: true
						});
						p.$promise.then(function(y){
							p.show();
							scope.loaded[el.attr("id")] = true;
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
	"$sce", "$timeout", "calendarHelperService", "calendarEventsService", "$rootScope", "$http",
	function($sce, $timeout, calendarHelperService, calendarEventsService, $rootScope, $http){
		return {
			templateUrl: "templates/day.html",
			restrics: "A",
			require: "^calendar",
			scope: {
				currentDay: "=calendarCurrentDay",
				eventFilter: "=calendarFilter"
			},
			link: function postLink(scope, element, attrs, calendarController){
				
				calendarController.titleFunctions.day = function(currentDay) {
					return moment(currentDay).format('dddd DD MMMM, YYYY');
				};

				function updateView() {
					calendarEventsService.list(scope.eventFilter).success(function(results){
						scope.view = calendarHelperService.getDayView(results, moment(scope.currentDay));
						scope.events = [];
						if(scope.view){
							var evs = [];
							for(var i = 0; i < scope.view.length; i++){
								evs = [];
								var obj = scope.view[i][$rootScope.Utils.keys(scope.view[i])[0]];
								for(var k = 0; k < obj.length; k++){
									evs.push(JSON.parse(obj[k]));
								}
								scope.events.push(evs);
							}
						}
						else {
							scope.events = [];
						}
						
					});
				}
				
				scope.clearEvent = function($event, id, type){
					$event.preventDefault();
					$http.get("/events/" + id + "/clear?type=" + type).success(function(){
						updateView();
					});
				}

				scope.$watch('currentDay', updateView);
				
			}
		}
	}
]).

directive("calendarAgenda", [
	"calendarHelperService", "calendarEventsService", "$rootScope", "$http",
	function(calendarHelperService, calendarEventsService, $rootScope, $http){
		return {
			templateUrl: "templates/agenda.html",
			restrics: "A",
			require: "^calendar",
			scope: {
				currentDay: "=calendarCurrentDay",
				eventFilter: "=calendarFilter"
			},
			link: function postLink(scope, element, attrs, calendarController){
				
				calendarController.titleFunctions.agenda = function(currentDay) {
					return "Agenda";
				};
				
				calendarController.controlFunctions.agenda = function(){
					return false;
				}

				function updateView() {
					calendarEventsService.list(scope.eventFilter).success(function(results){
						scope.events = [];
						var evs = [], day = "";
						$rootScope.Utils.keys(results).forEach(function(key){
							day = moment(key).format('dddd DD MMMM, YYYY');
							evs = [day, []];
							results[key].forEach(function(eventObject){
								var obj = eventObject[$rootScope.Utils.keys(eventObject)[0]];
								for(var k = 0; k < obj.length; k++){
									evs[1].push(JSON.parse(obj[k]));
								}
							});
							scope.events.push(evs);
						});
					});
				}
				
				scope.clearEvent = function($event, id, type){
					$event.preventDefault();
					$http.get("/events/" + id + "/clear?type=" + type).success(function(){
						updateView();
					});
				}

				scope.$watch('currentDay', updateView);
				
			}
		}
	}
]).

directive("calendarTrash", [
	"calendarHelperService", "calendarEventsService", "$rootScope", "$http",
	function(calendarHelperService, calendarEventsService, $rootScope, $http){
		return {
			templateUrl: "templates/trash.html",
			restrics: "A",
			require: "^calendar",
			scope: {
				currentDay: "=calendarCurrentDay",
				eventFilter: "=calendarFilter"
			},
			link: function postLink(scope, element, attrs, calendarController){
				
				calendarController.titleFunctions.trash = function(currentDay) {
					return "Cestino";
				};
				
				calendarController.controlFunctions.trash = function(){
					return false;
				}

				function updateView() {
					if(scope.eventFilter){
						var f = [scope.eventFilter, "active=false"].join("&");
					}
					else {
						var f = "active=false";
					}
					calendarEventsService.list(f).success(function(results){
						scope.events = [];
						results.forEach(function(event){
							event.start = moment(event.start, "YYYY-MM-DD HH:mm").format('dddd DD MMMM, YYYY');
							event.finish = moment(event.finish, "YYYY-MM-DD HH:mm").format('dddd DD MMMM, YYYY');
							scope.events.push(event);
						});
					});
				}
				
				scope.reinstateEvent = function($event, id, type){
					$event.preventDefault();
					$http.get("/events/" + id + "/reinstate?type=" + type).success(function(){
						updateView();
					});
				}
				
				scope.destroyEvent = function($event, id, type){
					$event.preventDefault();
					$http.delete("/events/" + id + "?type=" + type).success(function(){
						updateView();
					});
				}

				scope.$watch('currentDay', updateView);
				
			}
		}
	}
]);