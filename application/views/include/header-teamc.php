<div class="page-header" id="page-header">
    <h1><img src="<?= base_url('assets/img/glyphicons_081_refresh.png')?>"></img>&nbsp;Update Statistics</h1>
</div>

<div class="span2">
    <div class="well" id="sidebar">
    <ul class="nav nav-list-team-c">
		<li class="nav-header">Update Navigation</li>
		<li id="up"><a class="teamcnav" href="<?= site_url("updatestatistics/upload") ?>">Upload</a></li>
		<li id="ed"><a class="teamcnav" href="<?= site_url("updatestatistics/edit") ?>">Edit</a></li>
		<li id="bu"><a class="teamcnav" href="<?= site_url("updatestatistics/backup") ?>">Backup</a></li>
		<li id="re"><a class="teamcnav" href="<?= site_url("updatestatistics/restore") ?>">Restore</a></li>
		<!--<li id="rs"><a class="teamcnav" href="<?= site_url("updatestatistics/sql") ?>">Run SQL</a></li>-->
	</ul>
    </div>
</div>

<div id="container" class="span4">
	<div id="progressbar" style="display:none;" class="progress progress-info progress-striped">
        <div class="bar" id="pbar"></div>
    </div>
	<div id="prog-msgs" style="display:none;"></div>
	<div id="loading" style="display:none;">
		<img src="<?=base_url('images/loading.gif')?>" alt="" /><br>Please wait...
	</div>
	<div id="content">