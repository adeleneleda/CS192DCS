<script>	
$(document).ready(function() { 
	document.getElementById('focus_here').focus()
	$('#sr').removeClass('active');
	$('#cs').removeClass('active');
	$('#et').addClass('active');
	$('#us').removeClass('active');
	$('#ab').removeClass('active');
	document.location.href="#focus_here";
	$('.tool').qtip({
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

  // call the tablesorter plugin and apply the uitheme widget
  $("table").tablesorter({
    theme : "bootstrap", // this will 

    widthFixed: true,

    headerTemplate : '{content} {icon}', // new in v2.7. Needed to add the bootstrap icon!

    // widget code contained in the jquery.tablesorter.widgets.js file
    // use the zebra stripe widget if you plan on hiding any rows (filter widget)
    widgets : [ "uitheme", "zebra" ],

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

  
<div class="page-header">
    <h1><img src="<?= base_url('assets/img/glyphicons_152_check.png')?>"></img> Eligibility Checking</h1>
</div>
 
<div class="row">
	<div class="span3">
		<h3>Search Students</h3>
		<div class="well form-search">
			<form action="<?=base_url('eligibilitytesting/load_students')?>" method="post"> 
				<div class="control-group">
					<label class="control-label" for="select01">Year of Students</label>
					<div class="controls">
						<select name="year" id="select01">
							<? foreach($studentyears as $r) { ?>
								<option value="<?=$r['yearid']?>" <?=($r['yearid'] == $activeyear) ? 'selected' : ''?>>
									<? echo $r['year'] ?>
								</option>
							<? } ?>
						</select>
					</div>
				</div>
				<br />
				<div class="control-group">
					<label class="control-label" for="select02">Academic Year</label>
					<div class="controls">
						<select name="yearid" id="focus_here">
							<? foreach($years as $r) { ?>
								<option value="<?=$r['yearid']?>" <?=($r['yearid'] == intval($activetermid / 10)) ? 'selected' : ''?>>
									<? echo $r['year'] ?>
								</option>
							<? } ?>
						</select>
					</div>
				</div>
				<br />
				<div class="control-group">
					<label class="control-label" for="select02">Semester</label>
					<div class="controls">
					<select name="semid" id="focus_here">
						<? foreach($sems as $id => $r) { ?>
							<option value="<?=$id?>" 
								<?=($id == $activetermid % 10) ? 'selected' : ''?>>
								<? echo $r ?>
							</option>
						<? } ?>
					</select>
					</div>
				</div>
				<br />
				<button type="submit" class="btn btn-primary">Search</button>
			</form>
		</div>
	</div>
	
	<div class="span9">
			<form id="csv" method="post" action="<?= base_url('eligibilitytesting/generate_csv')?>">
			<input type="hidden" name="activetermid" value="<?= $activetermid?>">
			<input type="hidden" name="activeyear" value="<?= $activeyear?>">
			<button style="flush-right" type="submit" class="btn-primary btn">Generate CSV</button>
			</form>
		<ul class="nav nav-tabs">
			<li class="active"><a href="#A" data-toggle="tab">All</a></li>
			<li><a href="#B" data-toggle="tab">Eligible Only</a></li>
			<li><a href="#C" data-toggle="tab">Ineligible Only</a></li>
			<li>
			</li>
		</ul>
		<div class="tabbable">
			<div class="tab-content">
				<div class="tab-pane active" id="A">
					<table id="students" class="tablesorter">
						<thead>
							<tr>
								<th width="13%"><center>Student #</center></th>
								<th width="30%"><center>Name</center></th>
								<th width="15%"><center>Twice Fail</center></th>
								<th width="15%"><center>50% Passing</center></th>
								<th width="15%"><center>Math/CS 50%</center></th>
								<th width="15%"><center>24 units</center></th>
							</tr>
						</thead>

						<tbody>
						<? if (!empty($students)) { ?>
							<? foreach($students as $result) { ?>
								<tr>
									<td><center><? echo $result['studentno']; ?></center></td>
									<td><center><? echo $result['name'];?></center></td>
									<td><center>
										<? if (empty($result['eTwiceFail'])) { ?>
										<? } else { ?>
											<? $tooltip = "";
											foreach ($result['eTwiceFail'] as $one) { ?>
												<? $tooltip .= $one['coursename'] . ' ' . $one['section'] . ' ' . $one['name'] . '<br />'; ?>
											<? } ?>
											<img class="tool" title="<?= $tooltip?>" src="<?=base_url("assets/img/glyphicons_207_remove_2.png")?>"></img>
										<? } ?>
									</center></td>									
									<td><center>
										<? if (empty($result['ePassHalf'])) { ?>
										<? } else { ?>
											<? $tooltip = "";
											foreach ($result['ePassHalf'] as $one) { ?>
												<? $tooltip .= (int) (100 - $one['failpercentage'] * 100) . '% Passing ' . $one['name'] . '<br />'; ?>
											<? } ?>
											<img class="tool" title="<?= $tooltip?>" src="<?=base_url("assets/img/glyphicons_207_remove_2.png")?>"></img>
										<? } ?>
									</center></td>									
									<td><center>
										<? if (empty($result['ePassHalfMathCS'])) { ?>
										<? } else { ?>
											<? $tooltip = "";
											foreach ($result['ePassHalfMathCS'] as $one) { ?>
												<? $tooltip .= (int) (100 - $one['failpercentage'] * 100) . '% Passing ' . $one['name'] . '<br />'; ?>
											<? } ?>
											<img class="tool" title="<?= $tooltip?>" src="<?=base_url("assets/img/glyphicons_207_remove_2.png")?>"></img>
										<? } ?>
									</center></td>
									<td><center>
										<? if (empty($result['eTotal24'])) { ?>
										<? } else { ?>
											<? $tooltip = "";
											foreach ($result['eTotal24'] as $one) { ?>
												<? $tooltip .= $one['unitspassed'] . ' Units Passed ' . $one['name'] . '<br />'; ?>
											<? } ?>
											<img class="tool" title="<?= $tooltip?>" src="<?=base_url("assets/img/glyphicons_207_remove_2.png")?>"></img>
										<? } ?>
									</center></td>
								</tr>
							<? } ?>
						<? } else { ?>
							<tr>
								<td colspan="6"><center>No Students Found</center></td>
							</tr>
						<? } ?>
						</tbody>
					</table>
				</div>
				<div class="tab-pane" id="B">
					<table id="eligstudents" class="table-striped table-hover tablesorter">
						<thead>
							<tr>
								<th width="13%"><center>Student #</center></th>
								<th width="30%"><center>Name</center></th>
								<th width="15%"><center>Twice Fail</center></th>
								<th width="15%"><center>50% Passing</center></th>
								<th width="15%"><center>Math/CS 50%</center></th>
								<th width="15%"><center>24 units</center></th>
								</tr>
						</thead>

						<tbody>
						<? if (!empty($students)) { ?>
							<? $added = false; ?>
							<? foreach($students as $result) { ?>
								<? if (empty($result['eTwiceFail']) && empty($result['ePassHalf']) && empty($result['ePassHalfMathCS']) && empty($result['eTotal24'])) { ?>
									<? $added = true; ?>
									<tr>
										<td><center><? echo $result['studentno']; ?></center></td>
										<td><center><? echo $result['name'];?></center></td>
										<td><center>
											<? echo empty($result['eTwiceFail']) ? '' : '<img src="'.base_url("assets/img/glyphicons_207_remove_2.png").'"></img>'; ?>
										</center></td>									
										<td><center>
											<? echo empty($result['ePassHalf']) ? '' : '<img src="'.base_url("assets/img/glyphicons_207_remove_2.png").'"></img>'; ?>
										</center></td>									
										<td><center>
											<? echo empty($result['ePassHalfMathCS']) ? '' : '<img src="'.base_url("assets/img/glyphicons_207_remove_2.png").'"></img>'; ?>
										</center></td>
										<td><center>
											<? echo empty($result['eTotal24']) ? '' : '<img src="'.base_url("assets/img/glyphicons_207_remove_2.png").'"></img>'; ?>
										</center></td>
									</tr>
								<? } ?>
							<? } ?>
							<? if (!$added) { ?>
								<tr>
									<td colspan="6"><center>No Students Found</center></td>
								</tr>
							<? } ?>
						<? } else { ?>
							<tr>
								<td colspan="6"><center>No Students Found</center></td>
							</tr>
						<? } ?>
						</tbody>
					</table>
				</div>
				<div class="tab-pane" id="C">
					<table id="ineligstudents" class="table-striped table-hover tablesorter">
						<thead>
							<tr>
								<th width="13%"><center>Student #</center></th>
								<th width="30%"><center>Name</center></th>
								<th width="15%"><center>Twice Fail</center></th>
								<th width="15%"><center>50% Passing</center></th>
								<th width="15%"><center>Math/CS 50%</center></th>
								<th width="15%"><center>24 units</center></th>
							</tr>
						</thead>

						<tbody>
						<? if (!empty($students)) { ?>
							<? $added = false; ?>
							<? foreach($students as $result) { ?>
								<? if (empty($result['eTwiceFail']) && empty($result['ePassHalf']) && empty($result['ePassHalfMathCS']) && empty($result['eTotal24'])) { ?>
								<? } else { ?>
									<? $added = true; ?>
									<tr>
										<td><center><? echo $result['studentno']; ?></center></td>
										<td><center><? echo $result['name'];?></center></td>
										<td><center>
											<? if (empty($result['eTwiceFail'])) { ?>
											<? } else { ?>
												<? $tooltip = "";
												foreach ($result['eTwiceFail'] as $one) { ?>
													<? $tooltip .= $one['coursename'] . ' ' . $one['section'] . ' ' . $one['name'] . '<br />'; ?>
												<? } ?>
												<img class="tool" title="<?= $tooltip?>" src="<?=base_url("assets/img/glyphicons_207_remove_2.png")?>"></img>
											<? } ?>
										</center></td>									
										<td><center>
											<? if (empty($result['ePassHalf'])) { ?>
											<? } else { ?>
												<? $tooltip = ""; 
												foreach ($result['ePassHalf'] as $one) { ?>
													<? $tooltip .= (int) (100 - $one['failpercentage'] * 100) . '% Passing ' . $one['name'] . '<br />'; ?>
												<? } ?>
												<img class="tool" title="<?= $tooltip?>" src="<?=base_url("assets/img/glyphicons_207_remove_2.png")?>"></img>
											<? } ?>
										</center></td>									
										<td><center>
											<? if (empty($result['ePassHalfMathCS'])) { ?>
											<? } else { ?>
												<? $tooltip = "";
												foreach ($result['ePassHalfMathCS'] as $one) { ?>
													<? $tooltip .= (int) (100 - $one['failpercentage'] * 100) . '% Passing ' . $one['name'] . '<br />'; ?>
												<? } ?>
												<img class="tool" title="<?= $tooltip?>" src="<?=base_url("assets/img/glyphicons_207_remove_2.png")?>"></img>
											<? } ?>
										</center></td>
										<td><center>
											<? if (empty($result['eTotal24'])) { ?>
											<? } else { ?>
												<? $tooltip = "";
												foreach ($result['eTotal24'] as $one) { ?>
													<? $tooltip .= $one['unitspassed'] . ' Units Passed ' . $one['name'] . '<br />'; ?>
												<? } ?>
												<img class="tool" title="<?= $tooltip?>" src="<?=base_url("assets/img/glyphicons_207_remove_2.png")?>"></img>
											<? } ?>
										</center></td>
									</tr>
								<? } ?>
							<? } ?>
							<? if (!$added) { ?>
								<tr>
									<td colspan="6"><center>No Students Found</center></td>
								</tr>
							<? } ?>
						<? } else { ?>
							<tr>
								<td colspan="6"><center>No Students Found</center></td>
							</tr>
						<? } ?>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>
