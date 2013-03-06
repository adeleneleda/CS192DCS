<?php
if($reset_success)
	echo "<span class='success'>Database successfully reset.<br></span>";
if ($restore_success)
	echo "<h4><span class='success'>Restore complete<br></span></h4><br>";
else
	echo "<span class='error'>Failed to restore from the database dump</span>.<br>
		Check if you have the correct version of psql in '".$pg_bin_dir."'.<br>";
foreach ($output as $output_line)
	echo $output_line."<br>";
?>