$(document).ready(function(){
	$(".gradecell").change(function() {
		var callback = site_url + 'updatestatistics/updateGrade';
		var changed_cell = $(this);
		
		$.ajax({
			type: 'post',
			url: callback,
			data: {
				studentclassid: $(this).attr('id'),
				grade: $(this).val()
			},
			dataType: 'html',
			success: function (retVal) {
				if (retVal == 'true') {
					$(changed_cell).css('background-color','#AAFFCC').css("color","#555555");
					$(changed_cell).prop("title", null);
					setTimeout(function() { $(changed_cell).css("background-color","white"); }, 250);
				} else {
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