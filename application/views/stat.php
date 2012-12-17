

<!-- Typography
================================================== -->
<section id="typography">
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
	</div>
	
	</form>
	
	<div class="span9">
	<br>
	<div id="chart3" style="width:400px; height:300px;"></div>
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

 <script class="code" type="text/javascript">$(document).ready(function(){
        var s1 = [2, 6, 7, 10];
        var s2 = [7, 5, 3, 2];
        var s3 = [14, 9, 3, 8];
        plot3 = $.jqplot('chart3', [s1, s2, s3], {
            stackSeries: true,
            captureRightClick: true,
            seriesDefaults:{
                renderer:$.jqplot.BarRenderer,
                rendererOptions: {
                    highlightMouseDown: true    
                },
                pointLabels: {show: true}
            },
            legend: {
                show: true,
                location: 'e',
                placement: 'outside'
            }      
        });
    
        $('#chart3').bind('jqplotDataRightClick', 
            function (ev, seriesIndex, pointIndex, data) {
                $('#info3').html('series: '+seriesIndex+', point: '+pointIndex+', data: '+data);
            }
        ); 
    });</script>


