<script type="text/javascript" src="<?= base_url('assets/js/edit_grades.js') ?>"></script>
<link href="<?= base_url('assets/css/edit_grades.css') ?>" rel="stylesheet" type="text/css" />
<?php 
	$studentno = $student_info['studentno'];
	$name = $student_info['student_name'];
?>
	
<span class="page-header"> 
	<h3><?=$name?></h3>
	<h4><?=$studentno?></h4>
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
 
function printGradeTable($termname, $rows){ ?>
	<table width='70%' class='grades table table-bordered table-striped table-hover' >
		<thead>
			<tr>
				<th id='gradeheader' colspan='4'><center><?=$termname?></center></th>
			</tr>
			<tr>
				<th width='20%'><center>Class Code</center></th>
				<th width='40%'><center>Class</center></th>
				<th width='20%'><center>Units</center></th>
				<th width='20%'><center>Grade</center></th>
			</tr>
		</thead>
		<tbody>
		<?php foreach($rows as $row)
			printGradeRow($row); ?>
		</tbody>
	</table>
<?php }

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
	
	$length = strlen($grade) + 1;
	$data = array('name'=>'gradecell', 'id'=>$id, 'class'=>'gradecell', 'size'=>$length, 'value'=>$grade);
	echo "<td><div class='controls'>".form_input($data)."</div></td>";
	
	echo "</tr>"; 
}
?>