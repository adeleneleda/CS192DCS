<script type="text/javascript" src="<?= base_url('assets/js/jquery-ui.js') ?>"></script>
<link href="<?= base_url('assets/css/jquery-ui.css') ?>" rel="stylesheet" />
<script type = "text/javascript">
$(document).ready(function(){
	$('#upload_form').ajaxForm({ 
        target: '#content', // target element to be updated with server response 
        beforeSubmit: showLoading,
        success: showResponse,
		url: "<?=$dest ?>"
	});
});
function showLoading() {
	<?php if($upload_filetype == "Grade File") { ?>
		showProgressBar();
	<?php } else { ?>
		showLoadingGif();
	<?php } ?>
	$('#content').hide();
}
function showLoadingGif() {
	$('#loading').show();
}
function showProgressBar() {
	$("#progressbar").show();
	var max_width = $("#progressbar").width();
	$("#pbar").width(0);
	$('#upload_form').ajaxSubmit({ 
		url: "<?=site_url('updatestatistics/computeEstimatedProgress') ?>",
        success: function(retVal) {
			var progressRate = parseFloat(retVal);
			var percentComplete = 0;
			var timer = setInterval(function() {
				percentComplete += progressRate;
				if (percentComplete > 100) {
					clearInterval(timer);
				}
				$("#pbar").width(percentComplete * max_width);
			}, 200);
		}
	});
}
function showResponse() {
	$('#loading').hide();
	$("#progressbar").hide();
	$('#content').show();
}
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