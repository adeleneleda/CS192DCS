$(document).ready(function(){
	$('a.view_grades').click(function(e) {
		// prevent the default action when a nav button link is clicked
		e.preventDefault();
		$('#loading').show();
		$('#content').hide();
		// ajax query to retrieve the HTML view without refreshing the page.
		$('#content').load($(this).attr('href'), function () {
			$('#loading').hide();
			$('#content').show();
		});
	});
	
	$(".studentinfocell").change(function() {
		var callback = site_url + 'updatestatistics/updateStudentInfo';
		var changed_cell = $(this);
		
		$.ajax({
			type: 'post',
			url: callback,
			data: {
				personid: $(this).attr('id'),
				changedfield_name: $(this).attr("data-changedfieldname"),
				changedfield_value: $(this).val()
			},
			dataType: 'html',
			success: function (retVal) {
				if (retVal == 'true') {
					$(changed_cell).css('background-color','#AAFFCC').css("color","#555555");
					$(changed_cell).prop("title", null);
					setTimeout(function() { $(changed_cell).css("background-color","white"); }, 250);
				} else {
					// alert(retVal);
					$(changed_cell).prop("title", retVal);
					$(changed_cell).css("background-color","#CF0220").css("color","white");
				}
			},
			error: function(){
				alert("Call to database failed.");
				$(changed_cell).css("background-color","#CF0220").css("color","white");
			}
		});
	});
});