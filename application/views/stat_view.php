<script type="text/javascript">
		$(document).ready(function() {
			$('#sr').removeClass('active');
			$('#cs').addClass('active');
			$('#et').removeClass('active');
			$('#us').removeClass('active');
			$('#ab').removeClass('active');
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
	}
</style>

<div class="page-header">
	<h1><img src="<?= base_url('assets/img/glyphicons_041_charts.png')?>"></img> Course Statistics</h1>
</div>

<div class="row">
	<div class="span3">
		<h3>Search Course</h3>
		<form id="search_dropdown" method="post" action="<?= base_url('coursestatistics/index')?>">
		
		<div class="well form-search">
			<select name='courseid' id="selectError" style="width:180px">
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
			<button type="submit" class="btn-primary btn"><i class="icon-white icon-search2"></i></button>
        </div>
		<div id="advanced_search_div" class="well" >
			<legend>Advanced Search</legend>
			<div class="control-group">
				<label class="control-label" for="select01">Start Academic Term</label>
				<div class="controls">
					<select name = 'starttermid' id="select01">
					<?/*<option>Beginning of Time</option>
					<option>2010 1st Sem</option>
					<option>2010 2nd Sem</option>
					<option>2010 Summer</option>
					<option>2011 1st Sem</option>*/?>
					<option value="0">Beginning of time</option>
					<? 	$default_startterm = "Beginning of time";
						foreach ($term_info as $term) {
						if($selected['starttermid'] == $term['termid']){
							echo "<option selected=\"selected\" value = ".$term['termid'].">".$term['name']."</option>";
							$default_startterm = $term['name'];
						}else{
							echo "<option value = ".$term['termid'].">".$term['name']."</option>";
						}	
					}?>
					
					</select>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label" for="select01">End Academic Term</label>
				<div class="controls">
					<select name = 'endtermid' id="select01">
					<option value="10000000">Current</option>
					<?	$default_endterm = "Current";
						foreach ($term_info as $term) {
						if($selected['endtermid'] == $term['termid']){
							echo "<option selected=\"selected\" value = ".$term['termid'].">".$term['name']."</option>";
							$default_endterm = $term['name'];
						}else{
							echo "<option value = ".$term['termid'].">".$term['name']."</option>";
						}
					}?>
					</select>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label" for="select01">Instructor</label>
				<div class="controls">
					<select name = 'instructor' id="select01">
					<option value="select instructorid from instructors">Any</option>
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
				<label class="control-label" for="select01">Section</label>
				<div class="controls">
					<select name = 'section' id="select01">
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
		</div>
		</form>
	</div>
		
	<div class="span9">
		<a href="<?= base_url('coursestatistics')?>" class="btn btn-primary">Back to search results</a>
		<br>
		<br>
        <div id="chart1" style="margin-top:20px; margin-left:20px; width:98%; height:400px;"></div>
		<br/>
		<strong>Total Number of Students: 97</strong>
		<br>
		<br>
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
					<tr>
						<td>1.00</td>
						<td>10</td>
						<td>5.00%</td>
						</tr>
						<tr>
						<td>1.25</td>
						<td>10</td>
						<td>5.00%</td>
						</tr>
						<tr>
						<td>1.50</td>
						<td>10</td>
						<td>5.00%</td>
						</tr>
						<tr>
						<td>1.75</td>
						<td>10</td>
						<td>5.00%</td>
						</tr>
						<tr>
						<td>2.00</td>
						<td>10</td>
						<td>5.00%</td>
						</tr>
						<tr>
						<td>2.25</td>
						<td>10</td>
						<td>5.00%</td>
						</tr>
						<tr>
						<td>2.50</td>
						<td>10</td>
						<td>5.00%</td>
						</tr>
						<tr>
						<td>2.75</td>
						<td>10</td>
						<td>5.00%</td>
						</tr>
						<tr>
						<td>3.00</td>
						<td>10</td>
						<td>5.00%</td>
						</tr>
						<tr>
						<td>4.00</td>
						<td>10</td>
						<td>5.00%</td>
						</tr>
						<tr>
						<td>5.00</td>
						<td>10</td>
						<td>5.00%</td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<div class="span3">
				<div class="well">
					<strong>Index of Discrimination</strong>
					</br></br>##</br></br>
					<strong>Passing Rate</strong>
					</br></br>##%
				</div>
			</div>
		</div>
		<br/>
	</div>
</div>

<script class="code" type="text/javascript">
	$(document).ready(function(){
        $.jqplot.config.enablePlugins = true;
        var s1 = [5, 6, 7, 8 , 9, 10, 11, 12, 11, 10, 9];
        var ticks = ['1.00', '1.25', '1.50', '1.75', '2.00', '2.25', '2.50', '2.75', '3.00', '4.00', '5.00', ];
        
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
    });</script>
	
<!-- Don't touch this! -->

<!-- Additional plugins go here -->
	<script class="include" type="text/javascript" src="<?= base_url('assets/js/jquery.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/js/jquery.jqplot.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.barRenderer.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.pieRenderer.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.categoryAxisRenderer.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.pointLabels.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.canvasTextRenderer.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.canvasAxisLabelRenderer.min.js') ?>"></script>
	<script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.canvasAxisTickRenderer.min.js') ?>"></script>
	<link rel="stylesheet" type="text/css" href="<?= base_url('assets/css/jquery.jqplot.min.css') ?>"></link>
<!-- End additional plugins -->