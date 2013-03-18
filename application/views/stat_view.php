<script type="text/javascript">
	$(document).ready(function(){
        $.jqplot.config.enablePlugins = true;
		<?
		$grades = array();
		$count = array();
		foreach($stat as $grade){
			array_push($grades, $grade['gradename']);
			array_push($count, $grade['count']);
		}?>
        var s1 = <?echo json_encode($count)?>;
        var ticks = <?echo json_encode($grades)?>;
        
        var plot1 = $.jqplot('chart1', [s1], {
            // Only animate if we're not using excanvas (not in IE 7 or IE 8)..
			animate: !$.jqplot.use_excanvas,
            seriesDefaults:{
                renderer:$.jqplot.BarRenderer,
                pointLabels: { show: true },
				rendererOptions:{ 
					fontSize: '20pt'
				},
            },
            axes: {
                xaxis: {
					label:'Grades',
					labelRenderer: $.jqplot.CanvasAxisLabelRenderer,
                    renderer: $.jqplot.CategoryAxisRenderer,
                    ticks: ticks,
					tickOptions:{ 
						fontSize: '10pt'
					},
					tickRenderer:$.jqplot.CanvasAxisTickRenderer,
                },
				yaxis: {
					label:'Number of Students',
					labelRenderer: $.jqplot.CanvasAxisLabelRenderer,
					<?$var = max($count)+(5*((int)(max($count)/50) + 1));?>
					max: <?= ($var < 8) ? $var + (8 - $var) : 8*(((int)($var / 8)) + 1)?>,
					min: 0,
					tickInterval : <?= ($var < 8) ? 1 : (8*(((int)($var / 8)) + 1)) / 8 ?>,
					tickOptions:{ 
						fontSize: '10pt'
					},
					tickRenderer:$.jqplot.CanvasAxisTickRenderer,
                },
            },
            highlighter: { show: false },
        });
    
        $('#chart1').bind('jqplotDataClick', 
            function (ev, seriesIndex, pointIndex, data) {
                $('#info1').html('series: '+seriesIndex+', point: '+pointIndex+', data: '+data);
            }
        );
    });
	
	$.ajax({
	  type: "POST",
	  url: "<?= ($tag == 0) ? base_url("coursestatistics/getIOD/0") : base_url("coursestatistics/getIOD/1")?>",
	  data: { classid: "<?= $classid?>", courseid: "<?= $courseid?>"},
	  dataType: "json",
	  success: function(msg){
		$('#loading').hide();
		$('#IODdiv').show();
		$('#IODval').text(msg);
		$('#csv_iod').val(msg);
		$('#download').removeClass("disabled");
		$('#download').removeAttr("disabled");
	  }
	});
	
	$(document).ready(function() {
		$('#download').attr("disabled","disabled");
		$('#sr').removeClass('active');
		$('#cs').addClass('active');
		$('#et').removeClass('active');
		$('#us').removeClass('active');
		$('#ab').removeClass('active');
		document.location.href="#focus_here";
		$('#course_dropdown').change(function(){
			$.ajax({
			  type: "POST",
			  url: "<?= base_url("coursestatistics/course_ajax") ?>",
			  data: { courseid: $('#course_dropdown').val()},
			  beforeSend: function(){
				$('.dropdown').attr("disabled","disabled");
			  },
			  success: function(msg){
				var obj = jQuery.parseJSON(msg);
				populateSectionDropDown(obj.sections);
				populateInstructorDropDown(obj.instructors);
				populateYearDropDown(obj.years);
				$('.dropdown').removeAttr("disabled");
			  }
			});
		});
		$('#startsem_dropdown').change(function(){
			$.ajax({
			  type: "POST",
			  url: "<?= base_url("coursestatistics/acadterm_ajax") ?>",
			  data: { courseid: $('#course_dropdown').val(), startsem: $('#startsem_dropdown').val(), startyear: $('#startterm_dropdown').val(), endsem: $('#endsem_dropdown').val(), endyear: $('#endterm_dropdown').val()},
			  beforeSend: function(){
				$('.dropdown').attr("disabled","disabled");
			  },
			  success: function(msg){
				var obj = jQuery.parseJSON(msg);
				populateSectionDropDown(obj.sections);
				populateInstructorDropDown(obj.instructors);
				$('.dropdown').removeAttr("disabled");
			  }
			});
		});
		$('#startterm_dropdown').change(function(){
			$.ajax({
			  type: "POST",
			  url: "<?= base_url("coursestatistics/acadterm_ajax") ?>",
			  data: { courseid: $('#course_dropdown').val(), startsem: $('#startsem_dropdown').val(), startyear: $('#startterm_dropdown').val(), endsem: $('#endsem_dropdown').val(), endyear: $('#endterm_dropdown').val()},
			  beforeSend: function(){
				$('.dropdown').attr("disabled","disabled");
			  },
			  success: function(msg){
				var obj = jQuery.parseJSON(msg);
				populateSectionDropDown(obj.sections);
				populateInstructorDropDown(obj.instructors);
				$('.dropdown').removeAttr("disabled");
			  }
			});
		});
		$('#endsem_dropdown').change(function(){
			$.ajax({
			  type: "POST",
			  url: "<?= base_url("coursestatistics/acadterm_ajax") ?>",
			  data: { courseid: $('#course_dropdown').val(), startsem: $('#startsem_dropdown').val(), startyear: $('#startterm_dropdown').val(), endsem: $('#endsem_dropdown').val(), endyear: $('#endterm_dropdown').val()},
			  beforeSend: function(){
				$('.dropdown').attr("disabled","disabled");
			  },
			  success: function(msg){
				var obj = jQuery.parseJSON(msg);
				populateSectionDropDown(obj.sections);
				populateInstructorDropDown(obj.instructors);
				$('.dropdown').removeAttr("disabled");
			  }
			});
		});
		$('#endterm_dropdown').change(function(){
			$.ajax({
			  type: "POST",
			  url: "<?= base_url("coursestatistics/acadterm_ajax") ?>",
			  data: { courseid: $('#course_dropdown').val(), startsem: $('#startsem_dropdown').val(), startyear: $('#startterm_dropdown').val(), endsem: $('#endsem_dropdown').val(), endyear: $('#endterm_dropdown').val()},
			  beforeSend: function(){
				$('.dropdown').attr("disabled","disabled");
			  },
			  success: function(msg){
				var obj = jQuery.parseJSON(msg);
				populateSectionDropDown(obj.sections);
				populateInstructorDropDown(obj.instructors);
				$('.dropdown').removeAttr("disabled");
			  }
			});
		});
		$('#instructor_dropdown').change(function(){
			$.ajax({
			  type: "POST",
			  url: "<?= base_url("coursestatistics/instructor_ajax") ?>",
			  data: { courseid: $('#course_dropdown').val(), startsem: $('#startsem_dropdown').val(), startyear: $('#startterm_dropdown').val(), endsem: $('#endsem_dropdown').val(), endyear: $('#endterm_dropdown').val(), instructorid: $('#instructor_dropdown').val()},
			  beforeSend: function(){
				$('.dropdown').attr("disabled","disabled");
			  },
			  success: function(msg){
				var obj = jQuery.parseJSON(msg);
				populateSectionDropDown(obj.sections);
				populateYearDropDown(obj.years);
				$('.dropdown').removeAttr("disabled");
			  }
			});
		});
		$('#section_dropdown').change(function(){
			
		});
	});

	function populateSectionDropDown(sections) {
		var optionstr = '<option selected="selected" value="">Any</option>';
		for(i=0; i<sections.length; i++) {
			optionstr += '<option value="'+sections[i].section+'">'+sections[i].section+'</option>';
		}
		$('#section_dropdown').html(optionstr);
	}
	
	function populateInstructorDropDown(instructors) {
		var optionstr = '<option selected="selected" value="-1">Any</option>';
		for(i=0; i<instructors.length; i++) {
			optionstr += '<option value="'+instructors[i].instructor+'">'+instructors[i].instructor+'</option>';
		}
		$('#instructor_dropdown').html(optionstr);
	}
	
	function populateYearDropDown(years) {
		var optionstr = '';
		for(i=0; i<years.length; i++) {
			optionstr += '<option value="'+years[i].year+'">'+years[i].year+'</option>';
		}
		$('#startterm_dropdown').html(optionstr);
		$('#endterm_dropdown').html(optionstr);
	}
	
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

  // call the tablesorter plugin and apply the uitheme widget
  $(".tablesorter").tablesorter({
    theme : "bootstrap", // this will 

    widthFixed: true,

    headerTemplate : '{content} {icon}', // new in v2.7. Needed to add the bootstrap icon!

    // widget code contained in the jquery.tablesorter.widgets.js file
    // use the zebra stripe widget if you plan on hiding any rows (filter widget)
    widgets : [ "uitheme", "zebra", "filter"],

    widgetOptions : {
      // using the default zebra striping class name, so it actually isn't included in the theme variable above
      // this is ONLY needed for bootstrap theming if you are using the filter widget, because rows are hidden
      zebra : ["even", "odd"],

      // reset filters button
      filter_reset : ".reset",

      // set the uitheme widget to use the bootstrap theme class names
      uitheme : "bootstrap"

    }
  });
});
</script>

<style type="text/css">
	table thead tr .header {
        background-color:#008500;
		background-image:-moz-linear-gradient(top, #4D9900, #008500);
		background-image:-webkit-gradient(linear, 0 0, 0 100%, from(#4D9900), to(#008500));
		background-image:-webkit-linear-gradient(top, #4D9900, #008500);
		background-image:-o-linear-gradient(top, #4D9900, #008500);
		background-image:linear-gradient(to bottom, #4D9900, #008500);
		background-repeat:repeat-x;
		color:white;
</style>

<div class="page-header">
	<h1><img src="<?= base_url('assets/img/glyphicons_041_charts.png')?>"></img> Course Statistics</h1>
</div>
<div class="row">
	<div class="span3">
		<h3>Search Course</h3>
		<form id="search_dropdown" method="post" action="<?= base_url('coursestatistics/index')?>">
		
		<div class="well form-search">
			<select name='courseid' id="course_dropdown" class="dropdown">
				<?	$default_coursename = "CS 11";
					foreach ($dropdown as $indiv_drop) {
					if($selected['courseid'] == $indiv_drop['courseid']){
						echo "<option  selected=\"selected\" value = ".$indiv_drop['courseid'].">".$indiv_drop['coursename']."</option>";
						$default_coursename = $indiv_drop['coursename'];
					}
					else{
						echo "<option  value = ".$indiv_drop['courseid'].">".$indiv_drop['coursename']."</option>";
					}
				}?>
			</select>
        </div>
		<div id="advanced_search_div" class="well" >
			<legend>Advanced Search</legend>
			<div class="control-group">
				<label class="control-label" for="select01"><b>Start Academic Term</b></label>
				<table width="100%">
				<thead>
				<tr>
					<td width="50%">Semester</td>
					<td width="50%">Year</td>
				</tr>
				</thead>
				<tbody>
				<tr>
					<td>
						<div class="controls">
							<select style="width:90%" name = 'startsem' id="startsem_dropdown" class="dropdown">
							<option <? if($selected['startsem'] == '1st')  echo 'selected="selected"';?> value="1st">1st</option>
							<option <? if($selected['startsem'] == '2nd')  echo 'selected="selected"';?> value="2nd">2nd</option>
							<option <? if($selected['startsem'] == 'sum')  echo 'selected="selected"';?> value="sum">Summer</option>
							</select>
						</div>
					</td>
					<td>
						<div class="controls">
							<select style="width:100%" name = 'starttermid' id="startterm_dropdown" class="dropdown">
							<? 	$default_startterm = "Beginning of time";
								foreach ($year_info as $term) {
								if($selected['starttermid'] == $term['year']){
									echo "<option selected=\"selected\" value = ".$term['year'].">".$term['year']."</option>";
									$default_startterm = $term['year'];
								}else{
									echo "<option value = ".$term['year'].">".$term['year']."</option>";
								}	
							}?>
							</select>
						</div>
					</td>
				</tr>
				</tbody>
				</table>
			</div>
			<div class="control-group">
				<label class="control-label" for="select01"><b>End Academic Term</b></label>
				<table width="100%">
				<thead>
				<tr>
					<td width="50%">Semester</td>
					<td width="50%">Year</td>
				</tr>
				</thead>
				<tbody>
				<tr>
					<td>
						<div class="controls">
							<select style="width:90%" name = 'endsem' id="endsem_dropdown" class="dropdown">
							<option <? if($selected['endsem'] == '1st')  echo 'selected="selected"';?> value="1st">1st</option>
							<option <? if($selected['endsem'] == '2nd')  echo 'selected="selected"';?> value="2nd">2nd</option>
							<option <? if($selected['endsem'] == 'sum')  echo 'selected="selected"';?> value="sum">Summer</option>
							</select>
						</div>
					</td>
					<td>
						<div class="controls">
							<select style="width:100%" name = 'endtermid' id="endterm_dropdown" class="dropdown">
							<?	$default_endterm = "Current";
								foreach ($year_info as $term) {
								if($selected['endtermid'] == $term['year']){
									echo "<option selected=\"selected\" value = ".$term['year'].">".$term['year']."</option>";
									$default_endterm = $term['year'];
								}else{
									echo "<option value = ".$term['year'].">".$term['year']."</option>";
								}
							}?>
							</select>
						</div>
					</td>
				</tr>
				</tbody>
			</table>
			</div>
			<div class="control-group">
				<label class="control-label" for="select01"><b>Instructor</b></label>
				<div class="controls">
					<select name = 'instructor' id="instructor_dropdown" class="dropdown">
					<option value="-1">Any</option>
					<?	$default_instructor = "Any";
						foreach ($instructor_info as $instructor) {
						if($selected['instructorid'] == $instructor['instructorid']){
							echo "<option selected=\"selected\" value = ".$instructor['instructorid'].">". $instructor['lastname'] . " " .$instructor['firstname']."</option>";
							$default_instructor = $instructor['lastname'];
						}else{
							echo "<option value = ".$instructor['instructorid'].">". $instructor['lastname'] . " " .$instructor['firstname']."</option>";
						}
					}?>
					</select>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label" for="select01"><b>Section</b></label>
				<div class="controls">
					<select name = 'section' id="section_dropdown" class="dropdown">
					<option value="">Any</option>
					 <?	$default_section = "Any";
						foreach ($section_info as $section) {
						if($selected['sectionid'] == $section['section']){
							echo "<option selected=\"selected\" value = ".$section['section'].">". $section['section']."</option>";
							$default_section = $section['section'];
						}else{
							echo "<option value = ".$section['section'].">". $section['section']."</option>";
						}
					}?>
					</select>
				</div>
			</div>
			<button type="submit" class="btn-primary btn">Search</button>
		</div>
		</form>
	</div>
		
	<div class="span9">
		<a href="<?= base_url('coursestatistics')?>" class="btn btn-primary">Back to search results</a>
		<br/>
		<br/>
		<div align="center">
		<h3><?= $course?> - <?= $section1?></h3>
		</div>
		<div align="center">
		<h4><?= $ayterm?></h4>
		</div>
        <div id="chart1" style="margin-top:20px; margin-left:20px; width:98%; height:400px;"></div>
		<br/>
		<br/>
		<strong>Total Number of Students: <?= $stat2['count']?></strong>
		<br/>
		<br/>
		<div class="row">
			<div class="span6">
				<table class="table table-bordered table-striped table-hover">
				<thead>
					<tr>
						<th class="header">Grades</th>
						<th class="header"># of Students</th>
						<th class="header">Percentage</th>
					</tr>
				</thead>
					<tbody>
						<?foreach($stat as $grade){?>
						<tr>
						<td><?= $grade['gradename']?></td>
						<td><?= $grade['count']?></td>
						<td><?= $grade['percentage']?></td>
						</tr>
						<?}?>
					</tbody>
				</table>
				<hr>
				<?if($classlist != null){?>
				<strong>Class List</strong>
				<br/>
				<br/>
				<table class="table table-bordered table-striped table-hover">
				<thead>
					<tr>
						<th class="header">Student #</th>
						<th class="header">Name</th>
						<th class="header">Grade</th>
					</tr>
				</thead>
					<tbody>
						<?foreach($classlist as $student){?>
						<tr>
						<td><?= $student['studentno']?></td>
						<td><?= $student['name']?></td>
						<td><?= $student['gradevalue']?></td>
						</tr>
						<?}?>
					</tbody>
				</table>
				<?}?>
			</div>
			
			<div class="span3">
				<div class="well">
					<strong>Index of Discrimination</strong>
					<br/><br/>
					<div id="loading"><img src="<?= base_url('images/69.gif')?>"/></div>
					<div id="IODdiv" style="display:hidden;"><label id="IODval"></label></div>
					<br/><br/>
					<strong>Passing Rate</strong>
					<br/><br/><?= $stat2['percentage']?>
				</div>
				<form method="post" action="<?= base_url('coursestatistics/generate_csv')?>">
				<input type="hidden" name="csv_classid" value="<?= $classid?>">
				<input type="hidden" name="csv_courseid" value="<?= $courseid?>">
				<input type="hidden" name="csv_passingrate" value="<?= $stat2['percentage']?>">
				<input id="csv_iod" type="hidden" name="csv_iod" value="">
				<button id="download" class="btn btn-custom disabled" type="submit"><i class="icon-download-alt2"></i> Download CSV</button>
				</form>
			</div>
		</div>
		<br/>
	</div>
</div>
	
<!-- Don't touch this! -->

<!-- Additional plugins go here -->
	<link rel="stylesheet" type="text/css" href="<?= base_url('assets/css/jquery.jqplot.min.css') ?>"></link>
	<script class="include" type="text/javascript" src="<?= base_url('assets/js/jquery.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/js/jquery.jqplot.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.barRenderer.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.pieRenderer.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.categoryAxisRenderer.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.pointLabels.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.canvasTextRenderer.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.canvasAxisLabelRenderer.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.canvasAxisTickRenderer.min.js') ?>"></script>	
<!-- End additional plugins -->