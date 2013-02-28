<script type="text/javascript">
$(document).ready(function(){
	$(".gradecell").change(function() {
		var callback = "<?=site_url('updatestatistics/updateGrade')?>";
		var changed_cell = $(this);
		
		$.ajax({
			type: 'post',
			url: callback,
			data: {
				studentclassid: $(this).attr('id'),
				grade: $(this).val()
			},
			dataType: 'html',
			success: function (retVal) {
				if (retVal == 'true') {
					$(changed_cell).css('background-color','#AAFFCC').css("color","#555555");
					$(changed_cell).prop("title", null);
					setTimeout(function() { $(changed_cell).css("background-color","white"); }, 250);
				} else {
					$(changed_cell).prop("title", retVal);
					$(changed_cell).css("background-color","#CF0220").css("color","white");
				}
			},
			error: function(){
				alert("Call to database failed.");
				$(changed_cell).css("background-color","#CF0220").css("color","white");
			}
		});//endajax
	});//endchange
});//end ready ()
</script>

<script src="http://localhost/cs192dcs/assets/js/jquery.tablesorter.js"></script>

<style>
.grades
{
font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;
width:500;
border-collapse:collapse;
}
#gradeheader
{
border-bottom:1px solid #FFFFFF;
}
.grades td
{
font-size:1.2em;
border:1px solid #006600;
padding:3px 7px 2px 7px;
}
.grades th 
{
font-size:1.4em;
text-align:left;
padding-top:3px;
padding-bottom:2px;
background-color:green;
color:#FFFFFF;
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
<span class="page-header">
	<?php 
	$studentno = $student_info['studentno'];
	$name = $student_info['student_name'];
	echo "<h3>$name</h3>";
	echo "<h4>$studentno</h4>";
	?>
 </span>
 
 <?php
 printGrades($term_grades);
 
 function printGrades($term_grades){
	foreach($term_grades as $term_grade){
		$termname = $term_grade['termname'];
		$rows = $term_grade['rows'];
		printGradeTable($termname, $rows);
		echo "</br>";
	}
 }
 
 function printGradeTable($termname, $rows){
	echo "<table width='70%' class='grades table table-bordered table-striped table-hover' >
			<thead>
				<tr>
					<th id='gradeheader' colspan='4'><center>$termname</center></th>
				</tr>
				<tr>
					<th width='20%'><center>Class Code</center></th>
					<th width='40%'><center>Class</center></th>
					<th width='20%'><center>Units</center></th>
					<th width='20%'><center>Grade</center></th>
				</tr>
			</thead><tbody>";
			
	foreach($rows as $row) {
		printGradeRow($row);
	}
	
	echo "</tbody></table>";
 }
 
 function printGradeRow($row){
	$classcode = $row['classcode'];
	$class = $row['coursename']." ". $row['section'];
	$units = (String)$row['credits'];
	if(!preg_match("[\.]", $units)){
		$units = $units.".0";
	}	
	$grade = $row['gradename'];
	$id = $row['studentclassid'];
	
	echo "<tr>";
	echo "<td>$classcode</td>";
	echo "<td>$class</td>";
	echo "<td>$units</td>";
	
	//make grade editable	
	$length = strlen($grade) + 1;
	$data = array('name'=>'gradecell', 'id'=>$id, 'class'=>'gradecell', 'size'=>$length, 'value'=>$grade);
	echo "<td><div class='controls'>".form_input($data)."</div></td>";
	
	echo "</tr>"; 
 }
 
 ?>