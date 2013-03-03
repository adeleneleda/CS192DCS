<script type="text/javascript" src="<?= base_url('assets/js/edit_students.js') ?>"></script>
<link href="<?= base_url('assets/css/update_statistics_edit.css') ?>" rel="stylesheet" type="text/css" />

<span class="page-header">
	<h3>Edit Student Information</h3>
</span>

<table class="students edit_table table table-bordered table-striped table-hover">
	<?php if (empty($students)) { ?>
		Database is empty.
	<?php } else { ?>
		<thead>
			<tr>
				<th colspan="6" id="studentheader"><center>Students</center></th>
			</tr>
			<tr>
				<th width="10%"><center>Student Number</center></th>
				<th><center>Last Name</center></th>
				<th><center>First Name</center></th>
				<th><center>Middle Name</center></th>
				<th width="10%"><center>Pedigree</center></th>
				<th width="10%"><center></center></th>
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
			echo "<td><a class='view_grades btn btn-primary' href='$grade_url'>Edit Grades</a></td>
			</tr>";
		}
			
		function printCell($personid, $fieldname, $fieldvalue) {
			$length = strlen($fieldvalue) + 1;
			$data = array('name'=>'studentinfocell', 'id'=>$personid, 'class'=>'studentinfocell',
			'data-changedfieldname'=>$fieldname, 'size'=>$length, 'value'=>$fieldvalue, 'style' => 'width:80%',);
			echo "<td><div class='controls'>".form_input($data)."</div></td>";
		} ?>
	</tbody>
</table>