$(document).ready(function(){
	$('a.view_grades').click(function(e) {
		// prevent the default action when a nav button link is clicked
		e.preventDefault();
		$('#loading').show();
		$('#content').hide();
		$('#content').load($(this).attr('href'), function () {
			$('#loading').hide();
			$('#content').show();
			scrollToPageHeader();
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
					setTimeout(function() {
						$(changed_cell).css("background-color","white");
						// $("#students").trigger('update'); // re-sort table
						// $(changed_cell).focus();
					}, 250);
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

    $("#students").tablesorter({
        headers: {
            0: {sorter:'input'},
			1: {sorter:'input'},
			2: {sorter:'input'},
			3: {sorter:'input'},
			4: {sorter:'input'},
			5: {sorter:false},
        },
		theme : "bootstrap",
		widthFixed: true,
		headerTemplate : '{content} {icon}',
		widgets : [ "uitheme", "filter" ],
		widgetOptions : {
			filter_childRows : false,
			filter_columnFilters : true,
			filter_cssFilter : 'tablesorter-filter',
			filter_functions : null,
			filter_hideFilters : false,
			filter_ignoreCase : true,
			filter_searchDelay : 300,
			filter_startsWith : false,
			filter_useParsedData : true
		}
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