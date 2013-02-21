<script>	
$(document).ready(function() { 
	document.getElementById('focus_here').focus()
	$('#sr').addClass('active');
	$('#cs').removeClass('active');
	$('#et').removeClass('active');
	$('#us').removeClass('active');
	$('#ab').removeClass('active');
}); 

$(function() {

  $.extend($.tablesorter.themes.bootstrap, {
    // these classes are added to the table. To see other table classes available,
    // look here: http://twitter.github.com/bootstrap/base-css.html#tables
    table      : 'table table-bordered',
    header     : 'bootstrap-header', // give the header a gradient background
    footerRow  : '',
    footerCells: '',
    icons      : '', // add "icon-white" to make them white; this icon class is added to the <i> in the header
    sortNone   : 'bootstrap-icon-unsorted',
    sortAsc    : 'icon-chevron-up',
    sortDesc   : 'icon-chevron-down',
    active     : '', // applied when column is sorted
    hover      : '', // use custom css here - bootstrap class may not override it
    filterRow  : '', // filter row class
    even       : '', // odd row zebra striping
    odd        : ''  // even row zebra striping
  });

  // call the tablesorter plugin and apply the uitheme widget
  $("table").tablesorter({
    theme : "bootstrap", // this will 

    widthFixed: true,

    headerTemplate : '{content} {icon}', // new in v2.7. Needed to add the bootstrap icon!

    // widget code contained in the jquery.tablesorter.widgets.js file
    // use the zebra stripe widget if you plan on hiding any rows (filter widget)
    widgets : [ "uitheme", "zebra" ],

    widgetOptions : {
      // using the default zebra striping class name, so it actually isn't included in the theme variable above
      // this is ONLY needed for bootstrap theming if you are using the filter widget, because rows are hidden
      zebra : ["even", "odd"],

      // reset filters button
      filter_reset : ".reset",

      // set the uitheme widget to use the bootstrap theme class names
      uitheme : "bootstrap"

    }
  });
});
</script>
  
<div class="page-header">
	<h1><img src="<?= base_url('assets/img/glyphicons_328_podium.png')?>"></img> Student Rankings</h1>
</div>

<div class="row">
	<div class="span3">
		<h3>Search Students</h3>
		<div class="well form-search">
			<form action="<?= base_url('studentrankings/get_students')?>" method="post"> 
			
			<div class="control-group">
				<label class="control-label" for="select01">Year of Students</label>
				<div class="controls">
					<select name="year" id="select01" style="width:180px">
                    <?php $ctr = 0; 
                    while($ctr < sizeof($year))
                    {
                    ?>
					  <option value="<?php echo $year[$ctr]?>"
					  <?php if($year[$ctr] == $currentyear)
                                {   
                                ?>
                                selected = "selected"
                                <?php
                                }?>>
                      <?php echo $year[$ctr]?></option>
                      <?php $ctr++; }?>
					</select>
					<button type="submit" class="btn btn-primary"><i class="icon-white icon-search2"></i></button>
				</div>
			</div>
			</br>
            <div class="control-group">
				<label class="control-label" for="select02">Year</label>
				<div class="controls">
					<select id = "focus_here" name="cyear">
						<option value="0" <?php if($yearlvl == 0)
                        {?>selected="selected" <?php
                        }?>>1st</option>
						<option value="1" <?php if($yearlvl == 1)
                        {?>selected="selected" <?php
                        }?>>2nd</option>
						<option value="2" <?php if($yearlvl == 2)
                        {?>selected="selected" <?php
                        }?>>3rd</option>
                        <option value="3" <?php if($yearlvl == 3)
                        {?>selected="selected" <?php
                        }?>>4th</option>
					</select> 
				</div>
			</div>
            </br>
			<div class="control-group">
				<label class="control-label" for="select03">Semester</label>
				<div class="controls">
					<select id = "focus_here" name="semester">
						<option value="1" <?php if($currentsem == 1)
                        {?>selected="selected" <?php
                        }?>>1st Sem</option>
						<option value="2" <?php if($currentsem == 2)
                        {?>selected="selected" <?php
                        }?>>2nd Sem</option>
						<option value="3" <?php if($currentsem == 3)
                        {?>selected="selected" <?php
                        }?>>Summer</option>
					</select> 
				</div>
			</div>
			</form>
		</div>
	</div>
	<div class="span9">
		<table id="students" class="tablesorter">
			<thead>
			  <tr>
                <th style="width:18%">Student #</th>
				<th style="width:30%">Name</th>
				<th style="width:18%">GWA</th>
				<th style="width:18%">CWA</th>
				<th style="width:18%">CS GWA</th>
				<th style="width:18%">Math GWA</th>
			  </tr>
			</thead>
			<tbody>
		 <?php
		 $ctr = 0;
         if(!empty($name))
         {
		 while($ctr < sizeof($name))
		 {?>
			<tr>
            <td> <?php echo $name[$ctr]['studentno']; ?> </td>
			<td> <?php echo $name[$ctr]['lastname'] . ', ' . $name[$ctr]['firstname'] . ' ' . $name[$ctr]['middlename']; ?> </td>
			<td> <?php echo $name[$ctr]['gwa']; ?> </td>
			<td> <?php echo $name[$ctr]['cwaproto4']; ?> </td>
			<td> <?php echo $name[$ctr]['csgwa']; ?> </td>
			<td> <?php echo $name[$ctr]['mathgwa']; ?>  </td></td>
			</tr>
		 <?php
		 $ctr++;
		 }
         }
		 else {
		 ?>
		 <tr>
			<th colspan="5" style="text-decoration:none"><center>No Students Found</center></th>
		</tr>
		 <?php
		 }
		 ?>
			</tbody>
		</table>
		<form method="post" action="<?= base_url('studentrankings/generate_csv')?>">
				<input type="hidden" name="csv_year" value="<?= $this->input->post("year")?>">
				<input type="hidden" name="csv_sem" value="<?= $this->input->post('semester')?>">
				<input class="btn btn-primary" type="submit" value="Download CSV"/>
		</form>
	</div>
</div>
