//= require carousel

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