<!DOCTYPE html>
<html lang="en">
	<head>
		<meta http-equiv="Content-Type" content="text/html" charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta name="description" content="">
		<meta name="keywords" content="">
		<meta name="author" content="">

		<title>UP DCS Student Profiling System</title>

		<script type="text/javascript" src="<?= base_url('assets/js/jquery-1.8.3.js') ?>"></script>
		<link href="<?= base_url('assets/css/font-awesome.css') ?>" rel="stylesheet">
		<link href="<?= base_url('assets/css/bootstrap.min.css') ?>" rel="stylesheet">
		<link href="<?= base_url('assets/css/bootstrap-responsive.min.css') ?>" rel="stylesheet">
		<link href="<?= base_url('assets/css/style.css') ?>" rel="stylesheet">
		<link href="<?= base_url('assets/css/custom.css') ?>" rel="stylesheet">
		<script src="<?= base_url('assets/js/bootstrap.min.js') ?>"></script>
		<script src="<?= base_url('assets/js/custom.js') ?>"></script>
		
		
		<link href="<?= base_url('assets/css/theme.bootstrap.css') ?>" rel="stylesheet">
		<script type="text/javascript" src="<?= base_url('assets/js/jquery.tablesorter.js') ?>"></script>
		<script type="text/javascript" src="<?= base_url('assets/js/jquery.tablesorter.widgets.js') ?>"></script>
		<script type="text/javascript" src="<?= base_url('assets/js/jquery.tablesorter.pager.js') ?>"></script>
		
		<link rel="shortcut icon" href="<?= base_url('images/favicon.ico')?>" >
		
		<?php if (isset($update_statistics)) { // include Team C headers ?>
			<link href="<?= base_url('assets/css/update_statistics.css') ?>" rel="stylesheet" type="text/css" />
			<script type="text/javascript" src="<?= base_url('assets/js/update_statistics_sidebar.js') ?>"></script>
			<script type="text/javascript" src="<?= base_url('assets/js/jquery.form.js') ?>"></script>
			<script type="text/javascript">
				var base_url = "<?= base_url(''); ?>";
				var site_url = "<?= site_url(''); ?>";
			</script>
		<?php } ?>
		<script type="text/javascript" src="<?= base_url('assets/js/jquery.qtip-1.0.0-rc3.min.js') ?>"></script>
	</head>
	<body class="preview" data-spy="scroll" data-target=".subnav" data-offset="80">
		<div class="container">
		<br/>
		<header class="jumbotron subhead" id="overview">
			<div class="row">   
				<div class="well" align="center">
					<span>
						<a href="<?= base_url('')?>"><img src="<?= base_url('images/logo.png')?>" align="middle" alt="Logo" /></a>
					</span>
					<span>
						<h1>UP DCS Student Profiling System</h1> 
						<p class="lead">Department of Computer Science, UP Diliman</p>
						<a id="focus_here" name="focus_here"></a>
					</span>
				</div>
				
				<div class="navbar">
					<div class="navbar-inner">
						<div class="container" style="width: auto;">
							<a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
								<span class="icon-bar"></span>
								<span class="icon-bar"></span>
								<span class="icon-bar"></span>
							</a>
							<a class="brand" href="<?= base_url('')?>"><i class="icon-home2" style="padding:4px; padding-right:8px"></i>Welcome!</a>
							<div class="nav-collapse">
								<ul class="nav">
									<li id="sr"><a href="<?= base_url('studentrankings')?>" style="height:23px;">Student Rankings</a></li>
									<li id="cs"><a href="<?= base_url('coursestatistics')?>" style="height:23px;">Course Statistics</a></li>
									<li id="et"><a href="<?= base_url('eligibilitytesting')?>" style="height:23px;">Eligibility Checking</a></li>
									<li id="us"><a href="<?= base_url('updatestatistics')?>" style="height:23px;">Update Statistics</a></li>
									<li id="ab"><a href="<?= base_url('about')?>" style="height:23px;">About</a></li>
								</ul>
							</div><!-- /.nav-collapse -->
						</div>
					</div><!-- /navbar-inner -->
			  </div><!-- /navbar -->
			</div>
		</header>