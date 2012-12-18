<script class="include" type="text/javascript" src="<?= base_url('assets/js/jquery.min.js') ?>"></script>
<link class="include" rel="stylesheet" type="text/css" href="<?= base_url('assets/css/jquery.jqplot.min.css') ?>" />

<div class="page-header">
	<h1>Course Statistics</h1>
</div>

<div class="row">
	<div class="span3">
		<h3>CS 32</h3>
		<h3>Data Structures</h3>	  
		<a class="btn btn-primary">Back to Search Results</a>
		</br>
		</br>
		<div id="advanced_search_div" class="well">
			<form id="search_dropdown" method="post" action="<?= base_url('coursestatistics/search')?>">
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
						<?foreach ($term_info as $term) {
						
							echo "<option value = ".$term['termid'].">".$term['name']."</option>";
						
						}?>
					</select>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label" for="select01">End Academic Term</label>
				<div class="controls">
					<select name = 'endtermid' id="select01">
						<option value="10000000">Current</option>
						<?foreach ($term_info as $term) {
						
							echo "<option value = ".$term['termid'].">".$term['name']."</option>";
						
						}?>
					</select>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label" for="select01">Instructor</label>
				<div class="controls">
					<select name = 'instructor' id="select01">
						<option value="select instructorid from instructors">Any</option>
						<?foreach ($instructor_info as $instructor) {
						
							echo "<option value = ".$instructor['instructorid'].">". $instructor['lastname'] . " " .$instructor['firstname']."</option>";
						
						}?>
					</select>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label" for="select01">Section</label>
				<div class="controls">
					<select name = 'section' id="select01">
						<option value="">Any</option>
						 <?foreach ($section_info as $section) {
						
							echo "<option value = ".$section['section'].">". $section['section']."</option>";
						
						}?>
					</select>
				</div>
			</div>
		</div>
		<input class="btn btn-primary" value="Submit" type="submit"/>
		</form>
	</div>

	<div class="span9">
		<br>
		<div><span>You Clicked: </span><span id="info1">Nothing yet</span></div>
        <div id="chart1" style="margin-top:20px; margin-left:20px; width:300px; height:300px;"></div>
		<strong>Total Number of Students: 97</strong>
		<br>
		<br>
		<div class="row">
			<div class="span6">
				<table class="table table-bordered table-striped">
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

<script class="code" type="text/javascript">$(document).ready(function(){
        $.jqplot.config.enablePlugins = true;
        var s1 = [2, 6, 7, 10];
        var ticks = ['a', 'b', 'c', 'd'];
        
        plot1 = $.jqplot('chart1', [s1], {
            // Only animate if we're not using excanvas (not in IE 7 or IE 8)..
            animate: !$.jqplot.use_excanvas,
            seriesDefaults:{
                renderer:$.jqplot.BarRenderer,
                pointLabels: { show: true }
            },
            axes: {
                xaxis: {
                    renderer: $.jqplot.CategoryAxisRenderer,
                    ticks: ticks
                }
            },
            highlighter: { show: false }
        });
    
        $('#chart1').bind('jqplotDataClick', 
            function (ev, seriesIndex, pointIndex, data) {
                $('#info1').html('series: '+seriesIndex+', point: '+pointIndex+', data: '+data);
            }
        );
    });</script>
	
<!-- Don't touch this! -->


    <script class="include" type="text/javascript" src="<?= base_url('assets/js/jquery.jqplot.min.js') ?>"></script>
    <script type="text/javascript" src="syntaxhighlighter/scripts/shCore.min.js"></script>
    <script type="text/javascript" src="syntaxhighlighter/scripts/shBrushJScript.min.js"></script>
    <script type="text/javascript" src="syntaxhighlighter/scripts/shBrushXml.min.js"></script>
<!-- Additional plugins go here -->

  <script class="include" type="text/javascript" src="<?= base_url('assets/js/jquery.jqplot.min.js') ?>"></script>
  <script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.barRenderer.min.js') ?>"></script>
  <script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.pieRenderer.min.js') ?>"></script>
  <script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.categoryAxisRenderer.min.js') ?>"></script>
  <script class="include" type="text/javascript" src="<?= base_url('assets/plugins/jqplot.pointLabels.min.js') ?>"></script>

<!-- End additional plugins -->