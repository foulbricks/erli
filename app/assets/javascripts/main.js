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
				window.location = window.location.href.replace("#", "");
			}
		}
	})
});

$(document).on("click", ".extra-file", function(event){
	event.preventDefault();
	var p = $(this).parent().prev().clone();
	var input = p.find("input");
	var inputId = input.attr("id").replace(/\d/, function(m){ return parseInt(m) + 1 });
	var inputName = input.attr("name").replace(/\d/, function(m){ return parseInt(m) + 1 });
	input.attr("id", inputId).attr("name", inputName);
	$(this).parent().before(p)
});