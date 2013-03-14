<script type = "text/javascript">
$(document).ready(function(){
	$('#output').hide();
	$('#show_output').click(function() {
		$('#show_output').hide();
		$('#output').show();
	});
});
</script>
<?php
if ($restore_success)
	echo "<h4><span class='success'>Restore complete!<br></span></h4><br>";
else
	echo "<span class='error'>Failed to restore from the database dump</span>.<br>
	Check if you have the correct version of psql in '".$pg_bin_dir."'.<br>";
?>
<input type="button" id="show_output" value="Show output" class="btn btn-primary">
<div id="output">
	<?php foreach ($output as $output_line)
		echo $output_line."<br>";
	?>
</div>