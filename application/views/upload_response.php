<?php
if ($reset_success)
	echo "<span class='success'>Database successfully reset.<br></span>";
if ($upload_success) {	
	echo "<span class='success'>File successfully uploaded.<br></span><br>";
	echo "<b><span class='success'>$success_rows</span></b> rows added, ";
	echo "<b><span class='error'>$error_rows</span></b> rows with errors. ";
	echo $excel_dump;
	if ($error_rows > 0){
		echo "<br><br>Rows with errors:<br>";
		echo $parse_output;
	}
	else
		echo "<br>Upload complete! There are no rows with errors.<br>";
} else
	echo "<span class='error'>$error_message</span><br><br>";
?>
