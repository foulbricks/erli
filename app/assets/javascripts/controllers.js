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
		$scope.conguaglio = false;
		
		$scope.$watch("expense", function(){
			if($scope.expense){
				$http({
					method: "GET",
					url: "/expenses/" + $scope.expense + "/check_balance_date"
				}).success(function(result){
					$scope.conguaglio = result;
				});
			}
			else {
				$scope.conguaglio = false;
			}
		});
	}
]).

controller("buildingExpensesController", [
	"$scope", "$http",
	function($scope, $http){
		
	}
]).

controller("buildingExpenseFormController", [
	"$scope", "$tooltip",
	function($scope, $tooltip){
		
	}
]).

controller("companyFormController", [
	"$scope",
	function($scope){
		
	}
]).

controller("invoiceTableController", [
	"$scope",
	function($scope){
		
	}
]).

controller("adFormController", [
	"$scope",
	function($scope){
		$scope.description = angular.element("#ad_description").val();
		$scope.contact = angular.element("#ad_contact").val();
		
		$scope.incrementImageCount = function($event){
			$event.preventDefault();
			$scope.imageCount = $scope.imageCount + 1;
		}
	}
]).

controller("unpaidEmailFormController", [
	"$scope",
	function($scope){
		$scope.body = angular.element("#unpaid_email_body").val();
		
		$scope.incrementDocumentCount = function($event){
			$event.preventDefault();
			$scope.documentCount = $scope.documentCount + 1;
		}
	}
]).

controller("unpaidAlarmFormController", [
	"$scope",
	function($scope){
		$scope.body = angular.element("#unpaid_alarm_body").val();
	}
]).

controller("unpaidWarningFormController", [
	"$scope",
	function($scope){
		$scope.text = angular.element("#unpaid_warning_text").val();
	}
]).

controller("mavTableController", [
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

controller("mavUploadFormController", [
	"$scope",
	function($scope){
	}
]).

controller("eventFormController", [
	"$scope", "$http", "$rootScope", "$templateCache",
	function($scope, $http, $rootScope, $templateCache){
		$scope.hideModal;
		$scope.bindHideModalFunction = function(hideModalFunction){
		    $scope.hideModal = hideModalFunction;
		}

		$scope.tenants = [];
		
		$scope.toggleSelection = function toggleSelection(number) {
			var idx = $scope.weekdays.indexOf(number);

			// is currently selected
			if (idx > -1) {
				$scope.weekdays.splice(idx, 1);
			}

			// is newly selected
			else {
				$scope.weekdays.push(number);
			}
			$scope.weekdays.sort();
		};
		
		$scope.$watch("frequency", function(newVal){
			if(newVal == "daily"){
				$scope.frequencyType = "Giorni";
			}
			else if(newVal == "weekly"){
				$scope.frequencyType = "Settimane";
			}
			else if(newVal == "monthly"){
				$scope.frequencyType = "Mesi";
			}
			else if(newVal == "yearly"){
				$scope.frequencyType = "Anni";
			}
		});
		
		$scope.$watch("building", function(){
			if($scope.building){
				$http({
					method: "GET",
					url: "/buildings/" + $scope.building + "/apartments"
				}).success(function(result){
					$scope.apartments = result;
				});
			}
		});
		
		$scope.$watch("apartment", function(){
			if($scope.apartment){
				$http({
					method: "GET",
					url: "/apartments/" + $scope.apartment + "/tenants"
				}).success(function(result){
					$scope.tenants = result;
				});
			}
		});
		
		$scope.createEvent = function($event){
			$event.preventDefault();
			$http.post("/events", { event: 
				{
					apartment_id: $scope.apartment,
					building_id: $scope.building,
					user_id: $scope.tenant,
					title: $scope.titolo,
					description: $scope.description,
					start: $scope.start,
					finish: $scope.finish,
					color: $scope.button.color,
					label: $scope.label,
					repeat: $scope.repeat,
					frequency: $scope.frequency,
					frequency_number: $scope.frequency_number,
					frequency_weekdays: $scope.weekdays.toString()
				}
			}).success(function(response){
				$scope.hideModal();
				$rootScope.reloadCalendar(moment(response.success).toDate());
				if($scope.label){
					var text = $scope.label.toLowerCase().replace(/^\s+/, "").replace(/\s+$/, "");
					text.split(/\,\s*/).forEach(function(val) { 
						if(!angular.element(".label-filter option[value='" + val + "']").size()){
							angular.element(".label-filter").append("<option value='" + val + "'>" + val + "</option>");
						}
					});
				}
			});
		}
		
		$scope.updateEvent = function($event, id){
			$event.preventDefault();
			$http.put("/events/" + id, { event: 
				{
					apartment_id: $scope.apartment,
					building_id: $scope.building,
					user_id: $scope.tenant,
					title: $scope.titolo,
					description: $scope.description,
					start: $scope.start,
					finish: $scope.finish,
					color: $scope.button.color,
					label: $scope.label,
					repeat: $scope.repeat,
					frequency: $scope.frequency,
					frequency_number: $scope.frequency_number,
					frequency_weekdays: $scope.weekdays.toString()
				},
				modify: $scope.modify
			}).success(function(response){
				$scope.hideModal();
				$templateCache.remove("/events/" + id + "/edit");
				$rootScope.reloadCalendar();
				if($scope.label){
					var text = $scope.label.toLowerCase().replace(/^\s+/, "").replace(/\s+$/, "");
					text.split(/\,\s*/).forEach(function(val) { 
						if(!angular.element(".label-filter option[value='" + val + "']").size()){
							angular.element(".label-filter").append("<option value='" + val + "'>" + text + "</option>");
						}
					});
				}
			});
		}
		
	}
]).

controller("invoiceFormController", [
	"$scope",
	function($scope){
		$scope.expenseCount = 1;
		$scope.incrementExpenseCount = function($event){
			$event.preventDefault();
			$scope.expenseCount = $scope.expenseCount + 1;
		}
	}
]).

controller("CalendarController", [
	"$scope", "moment", "$rootScope", "$http",
	function($scope, moment, $rootScope, $http){
		$scope.calendarView = "month";
		$scope.calendarDay = new Date();
		
		$rootScope.reloadCalendar = function(date){
			var d = date || new Date($scope.calendarDay);
			$scope.calendarDay = d;
		}
		
		$scope.setCalendarToToday = function(){
			$scope.calendarDay = new Date();
		}
		
		$scope.setCalendarView = function(view){
			$scope.calendarView = view;
		}
		
		$scope.apartments = []
		$scope.tenants = []
		
		$scope.$watch("label", function(newVal, oldVal){
			if($scope.label){
				if($scope.filter){
					$scope.filter = [$scope.filter.replace(/\&label.*$/, ""), "label=" + $scope.label].join("&");
				}
				else {
					$scope.filter = "label=" + $scope.label;
				}
				$rootScope.reloadCalendar(new Date($scope.calendarDay));
			}
			else if(newVal != oldVal){
				if($scope.filter){
					$scope.filter = $scope.filter.split("&")[0]
					if(/label/.test($scope.filter)){
						$scope.filter = null;
					}
				}
				else {
					$scope.filter = null;
				}
				$rootScope.reloadCalendar(new Date($scope.calendarDay));
			}
		});

		$scope.$watch("building", function(newVal, oldVal){
			$scope.apartments = []
			$scope.tenants = []
			if($scope.building){
				$scope.filter = "building_id=" + $scope.building;
				$rootScope.reloadCalendar();
				$http({
					method: "GET",
					url: "/buildings/" + $scope.building + "/apartments"
				}).success(function(result){
					$scope.apartments = result;
				});
			}
			else if(newVal != oldVal){
				$scope.filter = null;
				$rootScope.reloadCalendar();
			}
			
			if($scope.label){
				$scope.filter = [$scope.filter, "label=" + $scope.label].filter(function(e){return e}).join("&");
				$rootScope.reloadCalendar();
			}
		});

		$scope.$watch("apartment", function(oldVal, newVal){
			$scope.tenants = []
			if($scope.apartment){
				$scope.filter = "apartment_id=" + $scope.apartment;
				$rootScope.reloadCalendar(new Date($scope.calendarDay));
				$http({
					method: "GET",
					url: "/apartments/" + $scope.apartment + "/tenants"
				}).success(function(result){
					$scope.tenants = result;
				});
			}
			else if(newVal != oldVal){
				if($scope.building){
					$scope.filter = "building_id=" + $scope.building;
				}
				else {
					$scope.filter = null;
				}
				$rootScope.reloadCalendar(new Date($scope.calendarDay));
			}
			
			if($scope.label){
				$scope.filter = [$scope.filter, "label=" + $scope.label].filter(function(e){return e}).join("&");
				$rootScope.reloadCalendar(new Date($scope.calendarDay));
			}
		});
		
		$scope.$watch("tenant", function(oldVal, newVal){
			if($scope.tenant){
				$scope.filter = "user_id=" + $scope.tenant;
				$rootScope.reloadCalendar(new Date($scope.calendarDay));
			}
			else if(newVal != oldVal){
				if($scope.apartment){
					$scope.filter = "apartment_id=" + $scope.apartment;
				}
				else if($scope.building){
					$scope.filter = "building_id=" + $scope.building;
				}
				else {
					$scope.filter = null;
				}
				$rootScope.reloadCalendar(new Date($scope.calendarDay));
			}
			
			if($scope.label){
				$scope.filter = [$scope.filter, "label=" + $scope.label].filter(function(e){return e}).join("&");
				$rootScope.reloadCalendar(new Date($scope.calendarDay));
			}
		});
	}
]);