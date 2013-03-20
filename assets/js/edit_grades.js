$(document).ready(function(){

	$("#save-success").hide();
	$("#save-error").hide();

	$("#grades_submit").click( function() {
		$changed_cells = new Array();
		$data = "";
		
		$(".gradecell").each(function() {
			if($(this).val() != $(this).prop("defaultValue")){
				$changed_cells.push({studentclassid: $(this).attr('id'), grade: $(this).val()});
			}
		});
		
		$data = $changed_cells.toString();

		$('#content').hide();
		$('#loading').show();		
		
		var callback = site_url + 'updatestatistics/saveChanges';
		
		$.ajax({
			type: 'post',
			url: callback,
			data: {changed_grades: $changed_cells
			},
			dataType: 'html',
			success: function (retVal) {
				$('#loading').hide();
				$('#content').show();
				if(retVal == 'true'){
					$("#save-success").show();
					var fade_out = function() {
					  $("#save-success").fadeOut();
					};
					$(".gradecell").each(function() {$(this).css("background-color","white").css("color","#555555");});
					setTimeout(fade_out, 2000);
				}
				else{
					$("#save-error").show();
					var fade_out = function() {
					  $("#save-error").fadeOut();
					};

					setTimeout(fade_out, 2000);
				}
				scrollToPageHeader();
			},
			error: function(){
				alert("Call to database failed.");
			}
		});
    });
	
	$(".gradecell").change(function() {
		var callback = site_url + 'updatestatistics/validateGrade';
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
					if($(changed_cell).val() == $(changed_cell).prop("defaultValue")){
						$(changed_cell).css("background-color","white").css("color","#555555");
					} else {
						$(changed_cell).css('background-color','#CCFFAA').css("color","#555555");
					}
					$(changed_cell).qtip('hide');
					$(changed_cell).qtip('disable');
				} else {
					$(changed_cell).qtip({
						content: retVal,
						show: { solo: true, ready: true },
						position: {
							corner: {
								tooltip: 'bottomMiddle', // Use the corner...
								target: 'topMiddle' // ...and opposite corner
							}
						},
						style: {
							tip: true,
							name: 'cream',
						}
					});
					$(changed_cell).css("background-color","#CF0220").css("color","white");
				}
			},
			error: function(){
				alert("Call to database failed.");
				$(changed_cell).css("background-color","#CF0220").css("color","white");
			}
		});
	});
	
    $.tablesorter.addParser({
        id: 'input',
        is: function(s) {
            return false;
        },
        format: function(s, table, cell) {
			return $('input', cell).val();
		},
        type: 'text'
    });

    $("table").tablesorter({
        headers: {
			3: {sorter:'input'},
        },
		theme : "bootstrap",
		widthFixed: true,
		headerTemplate : '{content} {icon}',
		widgets : [ "uitheme" ]
	});
});

$(function() {
  $.extend($.tablesorter.themes.bootstrap, {
    // these classes are added to the table. To see other table classes available,
    // look here: http://twitter.github.com/bootstrap/base-css.html#tables
    table      : 'table table-bordered',
    header     : 'bootstrap-header', // give the header a gradient background
    footerRow  : '',
    footerCells: '',
    icons      : '', // add "icon-white" to make them white; this icon class is added to the <i> in the header
    sortNone   : 'bootstrap-icon-unsorted',
    sortAsc    : 'icon-chevron-up',
    sortDesc   : 'icon-chevron-down',
    active     : '', // applied when column is sorted
    hover      : '', // use custom css here - bootstrap class may not override it
    filterRow  : '', // filter row class
    even       : '', // odd row zebra striping
    odd        : ''  // even row zebra striping
  });
});