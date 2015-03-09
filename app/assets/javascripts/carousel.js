jQuery(document).ready(function ($) {
	var _SlideshowTransitions = [{ $Duration: 1200, $Opacity: 2 }];

    var options = {
        $AutoPlay: false,
        $AutoPlaySteps: 1,
        $AutoPlayInterval: 3000,
        $PauseOnHover: 1,
        $ArrowKeyNavigation: true,
        $SlideDuration: 500,
        $MinDragOffsetToSlide: 20,
        $SlideSpacing: 0,
        $DisplayPieces: 1,
        $ParkingPosition: 0,
        $UISearchMode: 1,
        $PlayOrientation: 1,
        $DragOrientation: 3,
        $SlideshowOptions: {
            $Class: $JssorSlideshowRunner$,
            $Transitions: _SlideshowTransitions,
            $TransitionsOrder: 1,
            $ShowLink: true
        },
        $BulletNavigatorOptions: {
            $Class: $JssorBulletNavigator$,
            $ChanceToShow: 2,
            $AutoCenter: 1,
            $Steps: 1,
            $Lanes: 1,
            $SpacingX: 10,
            $SpacingY: 10,
            $Orientation: 1
        },
        $ArrowNavigatorOptions: {
            $Class: $JssorArrowNavigator$,
            $ChanceToShow: 2,
            $Steps: 1
        }
    };
	
	var $containers = $(".ad-images")
	$containers.each(function(index, container){
	    var jssor_slider1 = new $JssorSlider$($(container).attr("id"), options);

	    function ScaleSlider() {
	        var parentWidth = jssor_slider1.$Elmt.parentNode.clientWidth;
			console.log(parentWidth)
	        if (parentWidth)
	            jssor_slider1.$ScaleWidth(Math.min(parentWidth - 30, 720));
	        else
	            window.setTimeout(ScaleSlider, 30);
	    }
	    ScaleSlider();

	    $(window).bind("load", ScaleSlider);
	    $(window).bind("resize", ScaleSlider);
	    $(window).bind("orientationchange", ScaleSlider);
	});
});