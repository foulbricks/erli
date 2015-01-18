$(function(){
	$(".default-building").on("change", function(){
		$(this).submit();
	});
});
$(".table-collapsed .child-table").hide();
$(".table-collapsed a.toggle-table").on("click", function(e){
	e.preventDefault();
	var $this = $(this);
	var $small = $this.find("small");
	if($small.hasClass("glyphicon-plus")){
		$small.removeClass("glyphicon-plus");
		$small.addClass("glyphicon-minus");
	}
	else if ($small.hasClass("glyphicon-minus")){
		$small.removeClass("glyphicon-minus");
		$small.addClass("glyphicon-plus");
	}
	$this.parent().parent().next().toggle("slow");
});

$("[bs-modal], [bs-popover]").on("click", function(e){ e.preventDefault(); });

$(document).on("submit", "form[name=leaseForm]", function(e){
	e.preventDefault();
	var form = $("form[name=leaseForm]");
	$.ajax({
		type: form.attr("method"),
		url: form.attr("action"),
		data: form.serialize(),
		success: function(data) {
			if(data.errors){
				var errorsList = $(".leaseFormErrors").html("");
				data.errors.forEach(function(err){
					errorsList.append("<li>" + err + "</li>");
				});
			}
			else {
				$(".leaseFormErrors").html("");
				window.location = "/leases"
			}
		}
	})
});

$(document).on("submit", "form[name=apartmentExpenseForm]", function(e){
	e.preventDefault();
	var form = $("form[name=apartmentExpenseForm]");
	$.ajax({
		type: form.attr("method"),
		url: form.attr("action"),
		data: form.serialize(),
		success: function(data) {
			if(data.errors){
				var errorsList = $(".leaseFormErrors").html("");
				data.errors.forEach(function(err){
					errorsList.append("<li>" + err + "</li>");
				});
			}
			else {
				$(".leaseFormErrors").html("");
				window.location = "/apartment_expenses"
			}
		}
	})
});



$(document).on("click", ".extra-file", function(event){
	event.preventDefault();
	var p = $(this).parent().prev().clone();
	var input = p.find("input");
	input.each(function(){
		var $this = $(this);
		var inputId = ($this.attr("id") || "").replace(/\d/, function(m){ return parseInt(m) + 1 });
		var inputName = $this.attr("name").replace(/\d/, function(m){ return parseInt(m) + 1 });
		if(inputId){
			$this.attr("id", inputId)
		}
		$this.attr("name", inputName);
	});
	$(this).parent().before(p)
});