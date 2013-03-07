<script>	
	$(document).ready(function() { 
		$('#sr').removeClass('active');
		$('#cs').removeClass('active');
		$('#et').removeClass('active');
		$('#us').removeClass('active');
		$('#ab').addClass('active');
		$('#focus_here').goTo();
	}); 
	
	(function($) {
		$.fn.goTo = function() {
			$('html, body').animate({
				scrollTop: $(this).offset().top + 'px'
			}, 'slow');
			return this; // for chaining...
		}
	})(jQuery);
</script>

<div class="page-header">
	<h1><img src="<?= base_url('assets/img/glyphicons_136_cogwheel.png')?>"></img> About</h1>
</div>
<div class="well">
<h3> Project Specifics </h3>
	The Student Profiler System is a project for the CS 192 - Software Engineering II Class, 2nd Semester, AY 2012-2013  of  Mr. Paul Rossener Regonia.<br/>
<br/>
	This project's main client is Mr. Philip Christian Zuniga. One sem has been allotted for the full development of the project.<br/><br/>
<h3> Application Specifics </h3>
	Mainly, the following technologies were used:<br/>
	Postgresql<br/>
	PHP<br/>
	CodeIgniter<br/>
	Twitter bootstrap<br/>
</div>
<br/>
<div class="well">
<h3> The Team </h3>
<table width="100%">
	<tr>
		<td width="50%">
			<h4><img src="<?= base_url('assets/img/glyphicons_029_notes_2.png')?>"></img> Input and Updates Processing Team</h4> <br/>
			Co, Matthew Dee<br/>
			de Villa, Fatima <br/>
			Fernando, Molen<br/>
			Ilao, Jaymelyn<br/>
			Ongcol, Anna Janeri<br/>
			Osera, Christelle<br/>
		</td>
		<td>
			<h4><img src="<?= base_url('assets/img/glyphicons_137_cogwheels.png')?>"></img> Application and Functionality Development Team</h4><br/>
			Castaneda, Joshua V. <br/>
			Cayabyab, Elijah Joshua B.<br/>
			Festin, Adelen Victoria Po<br/>
			Sison, Flor Marie Carmeli<br/>
			Reyes, Dan Antonio<br/>
			Torres, Ray D.<br/>
		</td>
	<tr>
</table>	
<br/>
</div>
<div class="well">
<h4><img src="<?= base_url('assets/img/glyphicons_012_heart.png')?>"></img> Mentor: Sir Paul Rossener Regonia</h4>
<h4><img src="<?= base_url('assets/img/glyphicons_361_crown.png')?>"></img> Project Client: Sir Philip Christian Zuniga</h4>
</div>