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
					<option value="-1">Current</option>
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
		<table style="width:100%">
		<tr>
			<td>
			<div class="well" style="padding:13px">
			<b>Legend: </b> 
			<span class="label" style="background-color:#A60800">Start AY Term</span>
			<span class="label" style="background-color:#FFAA00">End AY Term</span>
			<span class="label" style="background-color:#8805AB">Instructor</span>
			<span class="label" style="background-color:#009999">Section</span>
			</div>
			</td>
		</tr>
		</table>
		<table style="width:100%">
		<tr>
			<td style="width:40%"><h3><?= $default_coursename?></h3></td>
			<td align="right">
			<form method="post" action="<?= base_url('coursestatistics/stat')?>">
				<input type="hidden" name="classid" value="<?= null?>">
				<input type="hidden" name="courseid" value="<?= $search_results[0]['courseid']?>">
				<?if(empty($search_results)){
					echo '<a class="btn btn-primary disabled">View Statistics</a>';
				}else{
					echo '<input class="btn btn-primary" type="submit" value="View Statistics"></input>';
				}?>
			</form>
			</td>
		</tr>
		<tr>
			<td><h4>Computer Programming I</h4></td>
			<td align="right"><i class="icon-tags"></i> 
			<span class="label" style="background-color:#A60800"><?= $default_startterm?></span>
			<span class="label" style="background-color:#FFAA00"><?= $default_endterm?></span>
			<span class="label" style="background-color:#8805AB"><?= $default_instructor?></span>
			<span class="label" style="background-color:#009999"><?= $default_section?></span>
		</tr>
		</table>
		<br>
		<br>
		<?if(!empty($search_results)){?>
		<table id="students" class="table table-bordered table-striped table-hover"> 
		<thead>
			<tr>
				<th class="header">Course</th>
				<th class="header">Section</th>
				<th class="header">Instructor</th>
				<th class="header">AY Term</th>
				<th class="header">IOD</th>
				<th class="header" style="width:10%">Actions</th>
			</tr>
		</thead>
		<tbody>
			<tr>
			<?foreach($search_results as $index=>$subject){?>
			<td><?= $subject['coursename']?></td>
			<td><?= $subject['section']?></td>
			<td><?= $subject['instructorname']?></td>
			<td><?= $subject['ayterm']?></td>
			<td><?= $iod[$index]?></td>
			<form method="post" action="<?= base_url('coursestatistics/stat')?>">
				<input type="hidden" name="classid" value="<?= $subject['classid']?>">
				<input type="hidden" name="courseid" value="<?= $subject['courseid']?>">
				<input type="hidden" name="iod" value="<?= $iod[$index]?>">
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