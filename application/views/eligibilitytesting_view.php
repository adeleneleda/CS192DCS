<script>	
$(document).ready(function() { 
	$('#sr').removeClass('active');
	$('#cs').removeClass('active');
	$('#et').addClass('active');
	$('#us').removeClass('active');
	$('#ab').removeClass('active');
}); 
</script>
  
<script src="http://localhost/cs192dcs/assets/js/jquery-1.8.3.js"></script> 
<script src="http://localhost/cs192dcs/assets/js/jquery.tablesorter.js"></script>

<style type="text/css">
    table thead tr .header {
        background-image: url(http://localhost/cs192dcs/images/bg.gif);
        background-repeat: no-repeat;
        background-position: center right;
        background-color:#389400;
		margin: 10px;
		color:white;
    }
    table thead tr .headerSortUp {
        background-image: url(http://localhost/cs192dcs/images/asc.gif);
        background-color:#0c8800;
		margin: 10px;
		color:white;
    }
    table thead tr .headerSortDown {
        background-image: url(http://localhost/cs192dcs/images/desc.gif);
        background-color:#0c8800;
		margin: 10px;
		color:white;
    }
</style>
</head>

<body>
<script>
$(document).ready(function() 
    { 
        $("#students").tablesorter( {sortList: [[0,0]]} ); 
		$("#eligstudents").tablesorter( {sortList: [[0,0]]} ); 
		$("#ineligstudents").tablesorter( {sortList: [[0,0]]} ); 
    } 
); 
</script>
  
<div class="page-header">
    <h1><img src="<?= base_url('assets/img/glyphicons_152_check.png')?>"></img> Eligibility Checking</h1>
</div>
 
<div class="row">
	<div class="span3">
		<h3>Search Students</h3>
		<div class="well form-search">
			<form action="<?=base_url('eligibilitytesting/load_students')?>" method="post"> 

			<? $yearhard = array(0 => array('value' => '%', 'str' => 'All'),
			1 => array('value' => '2009', 'str' => '2009'),
			2 => array('value' => '2010', 'str' => '2010'),
			3 => array('value' => '2011', 'str' => '2011'),
			4 => array('value' => '2012', 'str' => '2012'),) ?>
				<div class="control-group">
				<label class="control-label" for="select01">Year of Students</label>
				<div class="controls">
				<select name="year" id="select01" style="width:180px">
					<? foreach($yearhard as $r) { ?>
						<option value="<?=$r['value']?>" <?=($r['value'] == $activeyear) ? 'selected' : ''?>>
							<? echo $r['str'] ?>
						</option>
					<? } ?>
				</select>
				<button type="submit" class="btn btn-primary"><i class="icon-white icon-search2"></i></button>
				</div>
				</div>
				</br>
				<div class="control-group">
				<label class="control-label" for="select02">Semester</label>
				<div class="controls">
				<select name="termid" id="select02">
					<? foreach($terms as $r) { ?>
						<option value="<?=$r['termid']?>" 
							<?=($r['termid'] == $activetermid) ? 'selected' : ''?>>
							<? echo $r['name'] ?>
						</option>
					<? } ?>
				</select>
				</div>
				</div>
			</form>
		</div>
	</div>
	
	<div class="span9">
		<ul class="nav nav-tabs">
			<li class="active"><a href="#A" data-toggle="tab">All</a></li>
			<li><a href="#B" data-toggle="tab">Eligible Only</a></li>
			<li><a href="#C" data-toggle="tab">Ineligible Only</a></li>
		</ul>
		<div class="tabbable">
			<div class="tab-content">
				<div class="tab-pane active" id="A">
					<table id="students" class="table table-bordered table-striped table-hover">
						<thead>
							<tr>
								<th rowspan="2" width="10%"><center>Student Number</center></th>
								<th rowspan="2" width="30%"><center>Name</center></th>
								<th colspan="4" width="60%"><center>Ineligibilities</center></th>
							</tr>
							<tr>
								<th width="15%"><center>Twice Fail</center></th>
								<th width="15%"><center>Math/CS 50%</center></th>
								<th width="15%"><center>24 units</center></th>
								<th width="15%"><center>50% Passing</center></th>
							</tr>
						</thead>

						<tbody>
						<? if (!empty($students)) { ?>
							<? foreach($students as $result) { ?>
								<tr>
									<td><center><? echo $result["studentno"]; ?></center></td>
									<td><center><?  echo $result["name"];?></center></td>
									<? for($i=0; $i<4; $i++) { ?>
										<? if(rand(0, 3) == 0){ ?>
											<td><center> X </center></td>
										<? } else if (rand(0, 2) == 0) { ?>
											<td><center>O (cleared)</center></td>
										<? } else { ?>
											<td><center></center></td>
										<? } ?>
									<? } ?>
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
					<table id="eligstudents" class="table table-bordered table-striped table-hover">
						<thead>
							<tr>
								<th rowspan="2" width="10%"><center>Student Number</center></th>
								<th rowspan="2" width="30%"><center>Name</center></th>
								<th colspan="4" width="60%"><center>Ineligibilities</center></th>
							</tr>
							<tr>
								<th width="15%"><center>Twice Fail</center></th>
								<th width="15%"><center>Math/CS 50%</center></th>
								<th width="15%"><center>24 units</center></th>
								<th width="15%"><center>50% Passing</center></th>
							</tr>
						</thead>

						<tbody>
						<? if (!empty($students)) { ?>
							<? foreach($students as $result) { ?>
								<tr>
									<td><center><? echo $result["studentno"]; ?></center></td>
									<td><center><?  echo $result["name"];?></center></td>
									<? for($i=0; $i<4; $i++) { ?>
										<? if(rand(0, 3) == 0){ ?>
											<td><center> X </center></td>
										<? } else if (rand(0, 2) == 0) { ?>
											<td><center>O (cleared)</center></td>
										<? } else { ?>
											<td><center></center></td>
										<? } ?>
									<? } ?>
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
					<table id="ineligstudents" class="table table-bordered table-striped table-hover">
						<thead>
							<tr>
								<th rowspan="2" width="10%"><center>Student Number</center></th>
								<th rowspan="2" width="30%"><center>Name</center></th>
								<th colspan="4" width="60%"><center>Ineligibilities</center></th>
							</tr>
							<tr>
								<th width="15%"><center>Twice Fail</center></th>
								<th width="15%"><center>Math/CS 50%</center></th>
								<th width="15%"><center>24 units</center></th>
								<th width="15%"><center>50% Passing</center></th>
							</tr>
						</thead>

						<tbody>
						<? if (!empty($students)) { ?>
							<? foreach($students as $result) { ?>
								<tr>
									<td><center><? echo $result["studentno"]; ?></center></td>
									<td><center><?  echo $result["name"];?></center></td>
									<? for($i=0; $i<4; $i++) { ?>
										<? if(rand(0, 3) == 0){ ?>
											<td><center> X </center></td>
										<? } else if (rand(0, 2) == 0) { ?>
											<td><center>O (cleared)</center></td>
										<? } else { ?>
											<td><center></center></td>
										<? } ?>
									<? } ?>
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
		</div> <!-- /tabbable -->
	</div>
</div>
