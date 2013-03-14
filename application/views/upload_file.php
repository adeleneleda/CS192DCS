<script type = "text/javascript">
$(document).ready(function(){
	$('#upload_form').ajaxForm({ 
        target: '#content',   // target element to be updated with server response 
        beforeSubmit: showLoading,  // pre-submit callback 
        success: showResponse, // post-submit callback
		url: "<?=$dest ?>"
	});
	$('#upload_formz').submit(function() {
		<?php if($upload_filetype == "Grade File") { ?>
			$("#progressbar").show();
			$("#progressbar").progressbar({ value: 0 });
			var percentComplete = 0; //Update this in your other script
			var timer = setInterval(function() {
				percentComplete++;
				if (percentComplete > 100) {
					clearInterval(timer);
				}
				$("#progressbar").progressbar( { value: percentComplete } );
			}, 200);
		<?php } else { ?>
			$('#loading').show();
		<?php } ?>
		$('#content').hide();
	});
});
function showLoading() {
	$('#loading').show();
	$('#content').hide();
};
function showResponse() {
	$('#loading').hide();
	$('#content').show();
};
</script>

<span class="page-header">
	<h3><?=$upload_header?></h3>
</span>

<form id="upload_form" enctype="multipart/form-data" action="" method="POST">
	<table width="50%" class="noborder">
		<tr><strong><?=$message?></strong></tr>
		<tr></tr>
		<tr>
			<td>&nbsp;<?=$upload_filetype?>:</td>
			<td><input class="input-file" type="file" id="upload_file" name="upload_file" /></td>
		</tr>
		
		<?php if($upload_filetype == "Grade File") : ?>
		<tr>
			<td>&nbsp;Reset Database?</td>
			<td><input type="checkbox" name="reset" value="Yes" /></td>
		</tr>
		<?php endif	?>
		
		<tr><td colspan="2"><br></td></tr>
		<tr>
			<td></td>
			<td>
				<input type="submit" class="btn btn-primary" name="submit" value="Submit" />
				<input type="reset" class="btn" name="cancel" value="Cancel"/>
			</td>
		</tr>
	</table>
	<?php if (isset($pg_bin_dir))
		echo "<input type='hidden' name='pg_bin_dir' value=".escapeshellarg($pg_bin_dir).">";
	?>
</form>