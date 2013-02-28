<script type = "text/javascript" src = "assets/js/jquery-1.8.3.js"></script>
<script language = "JavaScript" type = "text/javascript">
$(document).ready(function(){
	$('#upload_form').submit(function() {
		$('#loading').show();
		$('#content').hide();
	});
});
</script>
<span class="page-header">
	<h3><?=$upload_header?></h3>
</span>
<?php
if (!isset($success));
else if ($success) {
	echo "<span class='success'>File successfully uploaded<br></span><br>";
} else if (!$success) {
	echo "<span class='error'>$errormessage</span><br><br>";
}
?> 
<form id="upload_form" enctype="multipart/form-data" action="<?=$dest?>" method="POST">
	<table width="50%" class="noborder">
		<tr><strong><?=$message?></strong></tr>
		<tr></tr>
		<tr>
			<td></td>
			<td>&nbsp;<?=$upload_filetype?>:</td>
			<td><input class="input-file" type="file" id="upload_file" name="upload_file" /></td>
		</tr>
		
		<?php
		
		//if($upload_filetype == "Grade File"){
			echo'
			<tr>
				<td></td>
				<td>&nbsp;Reset Database?</td> <td><input type="checkbox" name="reset" value="Yes" /></td>
			</tr>
			';
		//}
		?>
		<tr><td colspan=2><br></td></tr>
		<tr>
			<td></td>
			<td></td>
			<td>
				<input type="submit" class="btn btn-primary" name="submit" value="Submit" />
				<input type="reset" class="btn" name="cancel" value="Cancel"/>
			</td>
		</tr>
	</table>
	<?php if (isset($pg_bin_dir))
		echo '<input type="hidden" name="pg_bin_dir" value='.escapeshellarg($pg_bin_dir).'>';
	?>
</form>
<?php
if (isset($success) && $success) {
	echo "<br><b><span class='success'>$success_rows</span></b> rows added, ";
	echo "<b><span class='error'>$error_rows</span></b> rows with errors. ";
	echo $excel_dump;
	if ($error_rows > 0){
		echo "<br>Rows with errors:<br>";
		echo $parse_output;
		echo "<br><br>";
		echo "<input type=\"submit\" name=\"updatefile\" value=\"Update\" />";
		echo "<input type=\"reset\" name=\"cancel\" value=\"Cancel\" />";
	}
	else
		echo "<br>Upload complete! There are no rows with errors.<br>";
}
?>
