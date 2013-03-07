<link href="<?= base_url('assets/css/update_statistics_edit.css') ?>" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="<?= base_url('assets/js/edit_students.js') ?>"></script>
<span class="page-header">
	<h3>Edit Student Information</h3>
</span>
	<?php if (empty($students)) { ?>
		Database is empty.
	<?php } else { ?>
	<table id="students" class="edit_table tablesorter">
		<thead>
			<tr>
				<th width='16%'>Student #</th>
				<th width='20%'>Last Name</th>
				<th width='25%'>First Name</th>
				<th width='20%'>Middle Name</th>
				<th width='17%'>Pedigree</th>
				<th width='14%' class="filter-false"></th>
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
			$data = array('name'=>'studentinfocell', 'id'=>$personid, 'class'=>'studentinfocell tool',
			'data-changedfieldname'=>$fieldname, 'size'=>$length, 'value'=>$fieldvalue, 'style' => 'width:80%',);
			echo "<td><center>".form_input($data)."</center></td>";
		} ?>
	</tbody>
</table>