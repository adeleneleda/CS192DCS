<link href="<?= base_url('assets/css/update_statistics_edit.css') ?>" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="<?= base_url('assets/js/edit_students.js') ?>"></script>
<span class="page-header">
	<h3>Edit Student Information</h3>
</span>
	<?php if (empty($students)) { ?>
		Database is empty.
	<?php } else { ?>
	<table id="students" class="edit_table tablesorter">
		<colgroup>
			<col style="width:10%;">
			<col style="width:15%;">
			<col style="width:15%;">
			<col style="width:15%;">
			<col style="width:8%;">
			<col style="width:10%;">
		</colgroup>
		<thead>
			<tr>
				<th>Student Number</th>
				<th>Last Name</th>
				<th>First Name</th>
				<th>Middle Name</th>
				<th>Pedigree</th>
				<th></th>
			</tr>
		</thead>
	<?php } ?>
	
	<tbody>
		<?php foreach($students as $student){
			$personid = $student['personid'];
			$studentno = $student['studentno'];
			$lastname = $student['lastname'];
			$firstname = $student['firstname'];
			$middlename = $student['middlename'];
			$pedigree = $student['pedigree'];

			echo "<tr>";
			printCell($personid, 'studentno', $studentno);
			printCell($personid, 'lastname', $lastname);
			printCell($personid, 'firstname', $firstname);				
			printCell($personid, 'middlename', $middlename);
			printCell($personid, 'pedigree', $pedigree);
			
			$grade_url = site_url("updatestatistics/editGrades/$personid");
			echo "<td><center><a class='view_grades btn btn-primary' href='$grade_url'>Edit Grades</a></center></td>
			</tr>";
		}
			
		function printCell($personid, $fieldname, $fieldvalue) {
			$length = strlen($fieldvalue) + 1;
			$data = array('name'=>'studentinfocell', 'id'=>$personid, 'class'=>'studentinfocell',
			'data-changedfieldname'=>$fieldname, 'size'=>$length, 'value'=>$fieldvalue, 'style' => 'width:80%',);
			echo "<td><center>".form_input($data)."</center></td>";
		} ?>
	</tbody>
</table>