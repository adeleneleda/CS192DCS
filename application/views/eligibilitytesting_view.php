<script>
$(document).ready(function() { 
	$('#sr').removeClass('active');
	$('#cs').removeClass('active');
	$('#et').addClass('active');
	$('#us').removeClass('active');
	$('#ab').removeClass('active');
    $("#students").tablesorter( {sortList: [[0,0]]} ); 
}); 
</script>

<style>
	.students
	{
	font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;
	width:1000;
	border-collapse:collapse;
	color:#FFFFFF;
	}
	.students td, #students th 
	{
	font-size:1.2em;
	color:#FFFFFF;
	border:1px solid #006600;
	padding:3px 7px 2px 7px;
	}
	.students th 
	{
	font-size:1.4em;
	text-align:left;
	padding-top:3px;
	padding-bottom:2px;
	color:#000;
	}
	tr:nth-child(even) {background: #F5F0EB}
	tr:nth-child(odd) {background: #FFF}

	table thead tr .header {
        background-image: url(http://localhost/cs192dcs/images/bg.gif);
        background-repeat: no-repeat;
        background-position: center right;
        background-color:#4D9900;
    }
    table thead tr .headerSortUp {
        background-image: url(http://localhost/cs192dcs/images/asc.gif);
        background-color:#336600;
    }
    table thead tr .headerSortDown {
        background-image: url(http://localhost/cs192dcs/images/desc.gif);
        background-color:#336600;
    }
</style>
  
<div class="page-header">
    <h1>Eligibility Testing</h1>
</div>
 
<form action="<?=base_url('eligibilitytesting/load_students')?>" method="post"> 
<table border="0" cellspacing="0" width="800">

<? $yearhard = array(0 => array('value' => '%', 'str' => 'All'),
1 => array('value' => '2009', 'str' => '2009'),
2 => array('value' => '2010', 'str' => '2010'),
3 => array('value' => '2011', 'str' => '2011'),
4 => array('value' => '2012', 'str' => '2012'),) ?>

<td>
	Year of Students
    <div class="controls">
	<select name="year">
		<? foreach($yearhard as $r) { ?>
			<option value="<?=$r['value']?>" <?=($r['value'] == $activeyear) ? 'selected' : ''?>>
				<? echo $r['str'] ?>
			</option>
		<? } ?>
	</select>
    </div>
</td>

<td>
	Semester: 
    <div class="controls">
	<select name="termid">
		<? foreach($terms as $r) { ?>
			<option value="<?=$r['termid']?>" 
				<?=($r['termid'] == $activetermid) ? 'selected' : ''?>>
				<? echo $r['name'] ?>
			</option>
		<? } ?>
	</select>
    </div>
</td>
<td>
<input type="submit" value="Submit" class="btn btn-primary"/>
</td>
</form>
</table>
</br>
</br>
<br/>
<input type="button" value="ALL" class="btn btn-primary btn-small"/>
<input type="button" value="ELIGIBLE ONLY" class="btn btn-primary btn-small"/>
<input type="button" value="INELIGIBLE ONLY" class="btn btn-primary btn-small"/><br/><br/>
<table id="students" class="table table-bordered table-striped table-hover">
    <thead>
        <tr>
            <th rowspan="2" width="10%"><center>Student Number</center></th>
            <th rowspan="2" width="30%"><center>Name</center></th>
            <th colspan="4" width="60%"><center>Ineligibilities</center></th>
        </tr>
        <tr>
            <th width="15%"><center>Twice Fail</center></th>
            <th width="15%"><center>Math/CS 50%</center></th>
            <th width="15%"><center>24 units</center></th>
            <th width="15%"><center>50% Passing</center></th>
        </tr>
    </thead>

    <tbody>
    <? if (!empty($students)) { ?>
        <? foreach($students as $result) { ?>
            <tr>
                <td><center><? echo $result["studentno"]; ?></center></td>
                <td><center><?  echo $result["name"];?></center></td>
                <? for($i=0; $i<4; $i++) { ?>
                    <? if(rand(0, 3) == 0){ ?>
                        <td><center> X </center></td>
                    <? } else if (rand(0, 2) == 0) { ?>
                        <td><center>O (cleared)</center></td>
                    <? } else { ?>
                        <td><center></center></td>
                    <? } ?>
                <? } ?>
            </tr>
        <? } ?>
    <? } else { ?>
        <tr>
            <td colspan="6"><center>No Students Found</center></td>
        </tr>
    <? } ?>
    </tbody>
</table>
<br /><br />