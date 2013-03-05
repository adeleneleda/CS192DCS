<script>	
	$(document).ready(function() { 
		$('#sr').removeClass('active');
		$('#cs').removeClass('active');
		$('#et').removeClass('active');
		$('#us').removeClass('active');
		$('#ab').removeClass('active');
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

<div class="row">
	<div class="well">
	<h2> Overview </h2>
	In line with the Department of Computer Science's goal to 
	effectively monitor their students and help them in 
	the pursuit of academic excellence 
	and also to provide the best classes and environment for learning, this UP DCS Student Profiling System was born.<br/>	
	<br/>
	Every module comes with its own functionalities. Each also comes with 'Download CSV' feature. <br/>CSVs are automatically saved in your Downloads folder.
	</div>
</div>

<div class="row">
	<div style="margin-left:0px; margin-right:1%" class="span6">
		<div style="width:95%" class="well">
			<h3 style="color:#045c08"><img src="<?= base_url('assets/img/green-glyphicons_328_podium.png')?>"></img> Student Rankings</h3>
			<hr/>
			<strong>Description</strong> <br/><br/>
			This module allows the user to see the student rankings per year level with the option to view past semester's rankings.
			The GWA, CWA, CS GWA, Math GWA are also displayed. Students can be arranged alphabetically, by GWA, CWA, CS GWA, and Math GWA.
			<br/>
			<br/>
			<br/>
			<br/>
		</div>
	</div>
	<div style="margin-right:1%" class="span6">
		<div style="width:95%;" class="well">
			<h3 style="color:#045c08"><img src="<?= base_url('assets/img/green-glyphicons_041_charts.png')?>"></img> Course Statistics</h3>
			<hr/>
			<strong>Description</strong> <br/><br/>
			This module allows the user to see the course statistics. It comes with a Search and and an Advanced Search function which allows user to filter the results more.
			The results of the Search will be a list of subjects satisfying the query.
			Upon clicking View Statistics, user will be presented with a graph and a table containing the passing rate, grade statistics and the index of discrimination.
			<br/>
			<br/>
		</div>
	
	</div>
</div>

<div class="row">
	<div style="margin:0px; margin-right:1%" class="span6">
		<div style="width:95%" class="well">
			<h3 style="color:#045c08"><img src="<?= base_url('assets/img/green-glyphicons_152_check.png')?>"></img> Eligibility Checking</h3>
			<hr/>
			<strong>Description</strong> <br/><br/>
			The eligibility testing module shows the students who are eligible or ineligible to enroll for the 
			following semester. Eligibility is based off of the four main ineligibilities: Twice-Fail Subjects, 
			50% Passing per Semester, 50% Passing of Math and CS subjects per Semester, and the 24 unit passing rule per year.
		</div>
	</div>
	<div style="margin-right:1%" class="span6">
		<div style="width:95%" class="well">
			<h3 style="color:#045c08"><img src="<?= base_url('assets/img/green-glyphicons_081_refresh.png')?>"></img> Update Statistics</h3>
			<hr/>
			<strong>Description</strong>
			<br/>
			<br/>
			This module allows to update the records in the database by uploading spreadsheets with grades for the semester.
			It also allows direct editing of the fields of the tables, backup and restore of the database.
			<br/>
			<br/>
		</div>
	</div>
</div>