<link href="<?= base_url('assets/css/update_statistics_edit.css') ?>" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="<?= base_url('assets/js/edit_grades.js') ?>"></script>
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
	<center><h4><?=$termname?></h4>
	<table id="grades" class="edit_table tablesorter">
		<thead>
			<tr>
				<th width='20%'>Class Code</th>
				<th width='40%'>Class</th>
				<th width='20%'>Units</th>
				<th width='20%'>Grade</th>
			</tr>
		</thead>
		<tbody>
		<?php foreach($rows as $row)
			printGradeRow($row); ?>
		</tbody>
	</table></center>
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
	echo "<td><center>".form_input($data)."</center></td>";
	
	echo "</tr>"; 
}
?>