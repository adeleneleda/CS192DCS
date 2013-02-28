<script>
$(document).ready(function(){
	var location = prompt('Enter the location of Postgres bin:', 'it is in your Postgres installation directory');
	var dest = "<?= site_url($dest)?>";
	$.post(dest, {'pg_bin_dir': location}, function(data) {
		$('#container').html(data);
	},"html");
});
</script>