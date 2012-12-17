<script src="http://localhost/cs192dcs/assets/js/jquery-1.8.3.js"></script> 
<script src="http://localhost/cs192dcs/assets/js/jquery.tablesorter.js"></script>


<script type="text/javascript">
		$(document).ready(function() {
			$('#advanced_search').click(function(){
				$('#advanced_search_div').slideToggle();
			});
			
		});
</script>


<style type="text/css">
.students
{
font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;
width:1000;
border-collapse:collapse;
color:#FFFFFF;
}
.students td, #students th 
{
font-size:1.2em;
color:#FFFFFF;
border:1px solid #006600;
padding:3px 7px 2px 7px;
}
.students th 
{
font-size:1.4em;
text-align:left;
padding-top:3px;
padding-bottom:2px;
color:#000;
}
tr:nth-child(even) {background: #F5F0EB}
tr:nth-child(odd) {background: #FFF}

</style>
<style type="text/css">
    table thead tr .header {
        background-color:#4D9900;
    }
</style>

</head>
<body>


<!-- Typography
================================================== -->
<section id="typography">
  <div class="page-header">
    <h1>Course Statistics</h1>
  </div>

<div class="row">
  <div class="span3">
  <h3>Search Course</h3>
	<form id="search_dropdown" method="post" action="<?= base_url('coursestatistics/search')?>">
	<div class="control-group">
            <div class="controls">
              <select name = 'courseid' id="selectError">
                <?/*<option>CS 11</option>
                <option>CS 12</option>
                <option>CS 135</option>
                <option>CS 192</option>
                <option>CS 153</option>*/?>
				<?foreach ($dropdown as $indiv_drop) {
				
					echo "<option  value = ".$indiv_drop['courseid'].">".$indiv_drop['coursename']."</option>";
				
				}?>
              </select>
            </div>
          </div>
		  
	
	<a id="advanced_search" class="btn btn-primary">Advanced Search</a>
	
	</br>
	</br>
	<div id="advanced_search_div" class="well" style="display:none">
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
	<?if(!empty($search_results)){?>
	<table id="students" class="table table-bordered table-striped table-hover"> 
    <thead>
      <tr>
        <th class="header">Course</th>
        <th class="header">IOD</th>
        <th class="header">Actions</th>
      </tr>
    </thead>
    <tbody>
      <tr>
		<?foreach($search_results as $subject){?>
        <td><?= $subject['coursename']?>
			
			</td>
        <td>##</td>
		<form method="post" action="<?= base_url('coursestatistics/stat')?>">
		<input type="hidden" name="classid" value="<?= $subject['classid']?>">
		<input type="hidden" name="courseid" value="<?= $subject['courseid']?>">
        <td><input type="submit" value="View Statistics"></input></td>
		
		</form>
		</tr>
		<?}?>
		
	</tbody>
	</table>
	
	<?}else{?>
		No results available.
	<?}?>
	</div>
  <br/>
</div>
  </body>


