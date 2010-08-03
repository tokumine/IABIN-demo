$(document).ready(function() {
	$(".show_pas").click(function(e){
		$(".pa_list").hide();
		e = $(this).offset();
		h = $(this).height();
		var pa_list = $(this).parent().children(".pa_list");
		
		//$("#export_form").css("top",e.pageY+5);
		pa_list.css("top",e.top+h);
		pa_list.css("left",e.left);
		pa_list.fadeIn("normal");		
		pa_list.delay(2000).fadeOut("normal");
		return false;		
	});
	
	$(".pa_list").mouseleave(function(){
		$(this).delay(1000).fadeOut("normal");
	});
	
	$(".pa_list").mouseover(function(){
		$(this).clearQueue();
	});
})