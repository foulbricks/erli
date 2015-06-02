angular.module("erli").

constant("moment", window.moment).

factory("calendarHelperService", [
	"$filter", "moment",
	function($filter, moment){
		var helper = {};
		
		helper.getMonthView = function(currentDay, useISOWeek, events){
			var dateOffset = isISOWeek() ? 1 : 0;
			
			function getWeekDayIndex(){
				var day = startOfMonth.day() - dateOffset;
				if(day < 0) day = 6;
				return day;
			}
			
			var startOfMonth = moment(currentDay).startOf("month");
			var numberOfDaysInMonth = moment(currentDay).endOf("month").date();
			
			var grid = [];
			var buildRow = new Array(7);
			
			for(var i = 1; i <= numberOfDaysInMonth; i++){
				if(i == 1){
					var weekdayIndex = getWeekDayIndex(startOfMonth);
					var prefillMonth = startOfMonth.clone();
					while(weekdayIndex > 0){
						weekdayIndex--;
						prefillMonth = prefillMonth.subtract(1, "day");
						buildRow[weekdayIndex] = {
							label: prefillMonth.date(),
							date: prefillMonth.clone(),
							inMonth: false,
							weekend: false
						}
					}
				}

				buildRow[getWeekDayIndex(startOfMonth)] = {
					label: startOfMonth.date(),
					inMonth: true,
					isToday: moment().startOf("day").isSame(startOfMonth),
					date: startOfMonth.clone(),
					weekend: startOfMonth.day() == 6 || startOfMonth.day() == 0,
					events: events[startOfMonth.format("YYYY-MM-DD")]
				};
				
				if(i == numberOfDaysInMonth){
					var weekdayIndex = getWeekDayIndex(startOfMonth);
					var postfillMonth = startOfMonth.clone();
					while(weekdayIndex < 6){
						weekdayIndex++;
						postfillMonth = postfillMonth.add(1, "day");
						buildRow[weekdayIndex] = {
							label: postfillMonth.date(),
							date: postfillMonth.clone(),
							inMonth: false,
							weekend: false
						}
					}
				}
				
				if(getWeekDayIndex(startOfMonth) === 6 || i == numberOfDaysInMonth){
					grid.push(buildRow);
					buildRow = new Array(7);
				}
				
				startOfMonth = startOfMonth.add(1, "day");
			}
			
			return grid;
			
		}
		
	    helper.getDayView = function(events, currentDay) {
			return events[currentDay.format("YYYY-MM-DD")];;
	    }
		
		helper.getMonthNames = function(short){
			return short ? moment.monthsShort() : moment.months();
		}
		
		helper.getWeekNames = function(short){
			return short ? moment.weekdaysShort() : [moment.weekdays(1), moment.weekdays(2), moment.weekdays(3), moment.weekdays(4), moment.weekdays(5), moment.weekdays(6), moment.weekdays(0)];
		}
		
		function isISOWeekBasedOnLocale() {
			return moment().startOf("week").day() === 1
		}
		
		function isISOWeek(userValue){
			if(angular.isDefined(userValue)) return userValue;
			return isISOWeekBasedOnLocale();
		}
		
		return helper;
	}
]).

factory("calendarEventsService", [
	"$http",
	function($http){
		var event = {};
		
		event.list = function(filter){
			if(typeof filter != "undefined"){
				return $http.get("/events?" + filter);
			}
			else {
				return $http.get("/events")
			}
		}
		
		return event;
	}
]);