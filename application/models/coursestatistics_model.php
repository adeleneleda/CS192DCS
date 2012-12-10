<?php
class Coursestatistics_model extends CI_Model {
   public function __construct()
   {
      parent::__construct();
   }

  public function search() {
	$coursename = '';
	$starttermid = '';
	$endtermid = '';
	$instructorid = 'select instructorid from instructors';
	$section = '';
  
	$query = 'SELECT classid, courseid, coursename 
			FROM courses JOIN classes USING (courseid) 
			JOIN instructorclasses USING (classid) 
			JOIN instructors USING (instructorid) 
			JOIN terms USING (termid)  
			WHERE coursename ILIKE "%'.$coursename.'%" 
			AND termid <= '.$endtermid.' 
			AND termid >= '. $starttermid.'AND instructorid in ('.$instructorid.') and section ilike "%'.$section.'%;"';
	echo $query;
	$results = $this->db->query($query);
		
	if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			return $temp[0];
		}
	return false;
  
  }
  
  public function results_graph() {
	$courseid = '';
	$classid = '';
  
	$query = 'SELECT gradename, count(*) from studentclasses
			join classes using (classid) 
			join courses using (courseid) 
			join grades using (gradeid) 
			where courseid in ('.$courseid.') and classid in ('.$classid.') group by gradename;';
			
	echo $query;
	$results = $this->db->query($query);
		
	if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			return $temp[0];
		}
	return false;  
  }
  
  
  public function results_chart() {
  
  	$courseid = '';
	$classid = 'select classid from classes';
  
	$query = 'SELECT	p.gradeid, p.gradename, p.total_qty, round(p.total_qty * 100.0 / t.total_qty, 2) || '%' as percentage
	FROM(
	SELECT 	gradeid, gradename, count(*) as total_qty 
	from studentclasses join classes using (classid) 
	join courses using (courseid) 
	join grades using (gradeid) 
	where courseid in ('.$courseid.') and classid in ('.$classid.') group by gradename, gradeid
	) p
	CROSS JOIN
	(
	SELECT	count(*) as total_qty from studentclasses 
	join classes using (classid) 
	join courses using (courseid) 
	join grades using (gradeid) 
	where courseid in ('.$courseid.') and classid in ('.$classid.')
	) t;';
			
	echo $query;
	$results = $this->db->query($query);
		
	if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			return $temp[0];
		}
	return false;    
  }

}
