<script type="text/javascript">
	$(document).ready(function() {
		$('#sr').removeClass('active');
		$('#cs').addClass('active');
		$('#et').removeClass('active');
		$('#us').removeClass('active');
		$('#ab').removeClass('active');
		document.location.href="#focus_here";
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
			<select name='courseid' id="selectError">
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
				<tr>
					<td width="50%">Semester</td>
					<td width="50%">Year</td>
				</tr>
				<tr>
					<td>
						<div class="controls">
							<select style="width:90%" name = 'startsem' id="select01">
							<option <? if($selected['startsem'] == '1st')  echo 'selected="selected"';?> value="1st">1st</option>
							<option <? if($selected['startsem'] == '2nd')  echo 'selected="selected"';?> value="2nd">2nd</option>
							<option <? if($selected['startsem'] == 'sum')  echo 'selected="selected"';?> value="sum">Summer</option>
							</select>
						</div>
					</td>
					<td>
						<div class="controls">
							<select style="width:100%" name = 'starttermid' id="select01">
							<option value="2008-2009">2007-2008</option>
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
				</table>
			</div>
			<div class="control-group">
				<label class="control-label" for="select01"><b>End Academic Term</b></label>
				<table width="100%">
				<tr>
					<td width="50%">Semester</td>
					<td width="50%">Year</td>
				</tr>
				<tr>
					<td>
						<div class="controls">
							<select style="width:90%" name = 'endsem' id="select01">
							<option <? if($selected['endsem'] == '1st')  echo 'selected="selected"';?> value="1st">1st</option>
							<option <? if($selected['endsem'] == '2nd')  echo 'selected="selected"';?> value="2nd">2nd</option>
							<option <? if($selected['endsem'] == 'sum')  echo 'selected="selected"';?> value="sum">Summer</option>
							</select>
						</div>
					</td>
					<td>
						<div class="controls">
							<select style="width:100%" name = 'endtermid' id="select01">
							<option value="2012-2013">2013-2014</option>
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
			</table>
			</div>
			<div class="control-group">
				<label class="control-label" for="select01"><b>Instructor</b></label>
				<div class="controls">
					<select name = 'instructor' id="select01">
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
					<select name = 'section' id="focus_here">
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
		<br>
		<br>
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
			</div>
			
			<div class="span3">
				<div class="well">
					<strong>Index of Discrimination</strong>
					</br></br><?= $iod?></br></br>
					<strong>Passing Rate</strong>
					</br></br><?= $stat2['percentage']?>
				</div>
				<form method="post" action="<?= base_url('coursestatistics/generate_csv')?>">
				<input type="hidden" name="csv_classid" value="<?= $classid?>">
				<input type="hidden" name="csv_courseid" value="<?= $courseid?>">
				<input type="hidden" name="csv_passingrate" value="<?= $stat2['percentage']?>">
				<input type="hidden" name="csv_iod" value="<?= $iod?>">
				<input class="btn btn-primary" type="submit" value="Download CSV"/>
				</form>
			</div>
		</div>
		<br/>
	</div>
</div>

<script class="code" type="text/javascript">
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
    });</script>
	
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