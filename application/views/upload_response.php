<?php if ($reset_success) : ?>
	<span class='success'>Database successfully reset.<br></span>
<?php endif;
	if ($upload_success && isset($success_rows) && isset($error_rows) && isset($parse_output)) {	?>
	<span class='success'>File successfully uploaded.<br></span><br>
	<b><span class='success'><?= $success_rows ?></span></b> rows added,
	<b><span class='error'><?= $error_rows ?></span></b> rows with errors.
	<?php
		if ($error_rows > 0)
			echo "<br><br>Rows with errors: <br> $parse_output";
		else
			echo "<br>Upload complete! There are no rows with errors.<br>";
	}
	else
		echo "<span class='error'>$error_message</span><br><br>";
?>
