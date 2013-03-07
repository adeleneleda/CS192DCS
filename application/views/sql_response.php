<?php if ($success) : ?>
	<h4><span class='success'>Success!<br></span></h4>
	<br>The SQL file was executed successfully.
<?php else : ?>
	<span class='error'>Failed to run the SQL file</span>.<br>
<?php endif ?>