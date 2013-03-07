<?php if ($success) { ?>
	<h4><span class='success'>Backup Success!<br></span></h4>
	Backup was saved to <span class='backup-location'><?=$backup_location?></span>
	<br>
<?php } else { ?>
	<span class='error'>Failed to backup the database</span>
	<br>
	Check if you have the correct version of pg_dump in '<?=$pg_bin_dir?>' and if you have write permissions on the dumps folder.<br>
<?php }
foreach ($output as $output_line)
	echo $output_line."<br>";
?>