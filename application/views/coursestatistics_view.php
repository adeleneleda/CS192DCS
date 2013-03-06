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
					<select name = 'section'>
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
			<form method="post" action="<?= base_url('coursestatistics/stat/0')?>">
				<input type="hidden" name="classid" value="<?= null?>">
				<input type="hidden" name="courseid" value="<?= $search_results[0]['courseid']?>">
				<input type="hidden" name="course" value="<?= $default_coursename?>">
				<input type="hidden" name="section" value="<?= ''?>">
				<input type="hidden" name="ayterm" value="<?= ''?>">
				<?if(empty($search_results)){
					echo '<a class="btn btn-primary disabled">View Statistics</a>';
				}else{
					echo '<input class="btn btn-primary" type="submit" value="View Course Statistics"></input>';
				}?>
			</form>
			</td>
		</tr>
		<tr>
			
			<td colspan = "2" align="right"><i class="icon-tags"></i> 
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
				<th class="header" style="width:10%">Actions</th>
			</tr>
		</thead>
		<tbody>
			<tr>
			<?foreach($search_results as $index=>$subject){?>
			<td><?= $subject['coursename']?></td>
			<td><?= $subject['section']?></td>
			<td><?//= $subject['instructorname']?></td>
			<td><?= $subject['ayterm']?></td>
			
			<form method="post" action="<?= base_url('coursestatistics/stat/1')?>">
				<input type="hidden" name="course" value="<?= $subject['coursename']?>">
				<input type="hidden" name="section" value="<?= $subject['section']?>">
				<input type="hidden" name="ayterm" value="<?= $subject['ayterm']?>">
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