<script>	
$(document).ready(function() { 
	$('#sr').addClass('active');
	$('#cs').removeClass('active');
	$('#et').removeClass('active');
	$('#us').removeClass('active');
	$('#ab').removeClass('active');
}); 
</script>
  
<script src="http://localhost/cs192dcs/assets/js/jquery-1.8.3.js"></script> 
<script src="http://localhost/cs192dcs/assets/js/jquery.tablesorter.js"></script>


<style>
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
        background-image: url(http://localhost/cs192dcs/images/bg.gif);
        background-repeat: no-repeat;
        background-position: center right;
        background-color:#4D9900;
    }
    table thead tr .headerSortUp {
        background-image: url(http://localhost/cs192dcs/images/asc.gif);
        background-color:#336600;
    }
    table thead tr .headerSortDown {
        background-image: url(http://localhost/cs192dcs/images/desc.gif);
        background-color:#336600;
    }
</style>
</head>

<body>
<script>
$(document).ready(function() 
    { 
        $("#students").tablesorter( {sortList: [[0,0]]} ); 
    } 
); 
</script>
  
<div class="page-header">
	<h1><img src="<?= base_url('assets/img/glyphicons_328_podium.png')?>"></img> Student Rankings</h1>
</div>

<div class="row">
	<div class="span3">
		<h3>Search Students</h3>
		<div class="well form-search">
			<form action="<?= base_url('studentrankings/get_students')?>" method="post"> 
			
			<div class="control-group">
				<label class="control-label" for="select01">Year of Students</label>
				<div class="controls">
					<select name="year" id="select01" style="width:180px">
                    <?php $ctr = 0; 
                    while($ctr < sizeof($year))
                    {
                    ?>
					  <option value="<?php echo $year[$ctr]?>"><?php echo $year[$ctr]?></option>
                      <?php $ctr++; }?>
					</select>
					<button type="submit" class="btn btn-primary"><i class="icon-white icon-search2"></i></button>
				</div>
			</div>
			</br>
			<div class="control-group">
				<label class="control-label" for="select02">Semester</label>
				<div class="controls">
					<select name="semester">
						<option value="1">1st Year, 1st Sem</option>
						<option value="2">1st Year, 2nd Sem</option>
						<option value="3">1st Year, Summer</option>
						<option value="11">2nd Year, 1st Sem</option>
						<option value="12">2nd Year, 2nd Sem</option>
                        <option value="13">2nd Year, Summer</option>
						<option value="21">3rd Year, 1st Sem</option>
						<option value="22">3rd Year, 2nd Sem</option>
						<option value="23">3rd Year, Summer</option>
						<option value="31">4th Year, 1st Sem</option>
						<option value="32">4th Year, 2nd Sem</option>
						<option value="33">4th Year, Summer</option>
					</select> 
				</div>
			</div>
			</form>
		</div>
	</div>
	<div class="span9">
		<table id="students" class="table table-bordered table-striped table-hover">
			<thead>
			  <tr>
				<th>Name</th>
				<th>GWA</th>
				<th>CWA</th>
				<th>CS GWA</th>
				<th>Math GWA</th>
			  </tr>
			</thead>
			<tbody>
		 <?php
		 $ctr = 0;
         if(!empty($name))
         {
		 while($ctr < sizeof($name))
		 {?>
			<tr>
			<td> <?php echo $name[$ctr]['lastname'] . ', ' . $name[$ctr]['firstname'] . ' ' . $name[$ctr]['middlename']; ?> </td>
			<td> <?php echo $name[$ctr]['gwa']; ?> </td>
			<td> <?php echo $name[$ctr]['cwaproto4']; ?> </td>
			<td> <?php echo $name[$ctr]['csgwa']; ?> </td>
			<td> <?php echo $name[$ctr]['mathgwa']; ?>  </td></td>
			</tr>
		 <?php
		 $ctr++;
		 }
         }
		 ?>
			</tbody>
		</table>
	</div>
</div>