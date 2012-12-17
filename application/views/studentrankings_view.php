
  
<script src="http://localhost/cs192dcs/assets/js/jquery-1.8.3.js"></script> 
<script src="http://localhost/cs192dcs/assets/js/jquery.tablesorter.js"></script>


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

</style>
<style type="text/css">
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
</head>

<body>
<script>
$(document).ready(function() 
    { 
        $("#students").tablesorter( {sortList: [[0,0]]} ); 
    } 
); 
</script>
  
  <div class="page-header">
    <h1>Student Rankings</h1>
  </div>

  
<form action="<?= base_url('studentrankings/get_students')?>" method="post"> 
<table border="0" cellspacing="0" width="800">

<td>Year Level: <select name="year">
  <option value="1">First</option>
  <option value="2">Second</option>
  <option value="3">Third</option>
  <option value="4">Fourth</option>
</select> </td>

<td>Semester: <select name="semester">
  <option value="20091">1st Year, 1st Sem</option>
  <option value="20092">1st Year, 2nd Sem</option>
  <option value="20101">2nd Year, 1st Sem</option>
  <option value="20102">2nd Year, 2nd Sem</option>
  <option value="20111">3rd Year, 1st Sem</option>
  <option value="20112">3rd Year, 2nd Sem</option>
  <option value="20121">4th Year, 1st Sem</option>
  <option value="20122">4th Year, 2nd Sem</option>
</select> 
</td>
<td>
<input type="submit" value="Submit" class="btn btn-primary"/>
</td>
</form>
</table>
</br>
</br>

<br/>
  <table id="students" class="table table-bordered table-striped table-hover">
    <thead>
      <tr>
        <th>Name</th>
        <th>GWA</th>
        <th>CWA</th>
        <th>CS GWA</th>
        <th>Math GWA</th>
      </tr>
    </thead>
    <tbody>
 <?php
 $ctr = 0;
 while($ctr < sizeof($name))
 {?>
    <tr>
    <td> <?php echo $name[$ctr]['lastname'] . ', ' . $name[$ctr]['firstname'] . ' ' . $name[$ctr]['middlename']; ?> </td>
    <td> <?php echo $name[$ctr]['gwa']; ?> </td>
    <td> <?php echo $name[$ctr]['cwaproto3']; ?> </td>
    <td> <?php echo $name[$ctr]['csgwa']; ?> </td>
    <td> </td>
    </tr>
 <?php
 $ctr++;
 }
 ?>
    </tbody>
  </table>