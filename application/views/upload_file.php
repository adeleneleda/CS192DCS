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
	var messages = ["Precomputing metrics...", "A few bits tried to escape, but we caught them...", "Why don't you try making cofee?",
	"Go ahead -- hold your breath", "The bits are still doing the harlem shake.", "The sprites are still working with the abacus", 
	"Hava a break, have a Kitkat.", "Call someone, maybe?", "Counting backwards from infinity", "Trying to look into your future",
	"Don't stop believing...*hums*", "The bits are flowing slowly today", "Still dreaming of faster computers..", "Would you like fries with that?"];
	var num_msgs = messages.length;
	var cur_msg = 0;
	var waiting_time = 0;
	$('#prog-msgs').show();
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
				if (percentComplete > 1) {
					clearInterval(timer);
				}
				else if(waiting_time % 150 == 0){
					var msg = messages[cur_msg];
					$('#prog-msgs').html(msg);
					cur_msg = (cur_msg + 1) % num_msgs ;
				}
				$("#pbar").width(percentComplete * max_width);
				waiting_time += 1;
			}, 400);
		}
	});
}
function showResponse() {
	$('#prog-msgs').hide();
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