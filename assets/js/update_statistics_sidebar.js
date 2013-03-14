function scrollToPageHeader() {
	location.href = "#page-header";
}
$(document).ready(function(){
	scrollToPageHeader();
	$('#sr').removeClass('active');
	$('#cs').removeClass('active');
	$('#et').removeClass('active');
	$('#us').addClass('active');
	$('#ab').removeClass('active');	

	$('#up').addClass('active');
	$('#ed').removeClass('active');
	$('#bu').removeClass('active');
	$('#re').removeClass('active');
	$('#rs').removeClass('active');	

	$('a.teamcnav').click(function(e) {
		// prevent the default action when a nav button link is clicked
		e.preventDefault();
		
		$actionid = $(this).parent('li').attr('id');
		
		$('#up').removeClass('active');
		$('#ed').removeClass('active');
		$('#bu').removeClass('active');
		$('#re').removeClass('active');
		$('#rs').removeClass('active');	
		
		if($actionid == "up"){
			$('#up').addClass('active');
		}else if($actionid == "ed"){
			$('#ed').addClass('active');
		}else if($actionid == "bu"){
			$('#bu').addClass('active');
		}else if($actionid == "re"){
			$('#re').addClass('active');
		}else if($actionid == "rs"){
			$('#rs').addClass('active');
		}
		// hide page contents and show loading gif
		$('#loading').show();
		$('#content').hide();
		$('#content').load($(this).attr('href'), function () { // called when done loading
			$('#loading').hide();
			$('#content').show();
			scrollToPageHeader();
		});
	});
});