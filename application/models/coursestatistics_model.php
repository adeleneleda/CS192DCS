<?php
class Coursestatistics_model extends CI_Model {
   public function __construct()
   {
      parent::__construct();
   }
   
  public function dropdown_info() {
  
	$query = "select coursename, courseid from courses;";
	$results = $this->db->query($query);
		
	if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			return $temp;
		}
	return false;
  
  }
  
   public function term_info() {
  
	$query = "select termid, name from terms;";
	$results = $this->db->query($query);
		
	if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			return $temp;
		}
	return false;
  
  }
  
  
     public function instructor_info() {
  
	$query = "select firstname, lastname, instructorid from persons join instructors using (personid);";
	$results = $this->db->query($query);
		
	if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			return $temp;
		}
	return false;
  
  }
  
  
     public function section_info() {
  
	$query = "select distinct section from classes;";
	$results = $this->db->query($query);
		
	if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			return $temp;
		}
	return false;
  
  }

  
  

  public function search($courseid,$starttermid, $endtermid,  $instructorid, $section) {
  
	$query = "SELECT classid, courseid, coursename, terms.name as ayterm, section, lastname || ', ' || firstname as instructorname
			FROM courses JOIN classes USING (courseid) 
			JOIN instructorclasses USING (classid) 
			JOIN instructors USING (instructorid) 
			JOIN persons using (personid)
			JOIN terms USING (termid)  
			WHERE courseid = ".$courseid." 
			AND termid <= ".$endtermid." 
			 AND termid >= ". $starttermid." AND instructorid in (".$instructorid.") and section ilike '%".$section."%';";
			 
	$results = $this->db->query($query);
	if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			return $temp;
		}
	return false;
  }
  
  public function results_graph($classid, $courseid) {
  
	$query = 'SELECT gradename, count(*) from studentclasses
			join classes using (classid) 
			join courses using (courseid) 
			join grades using (gradeid) 
			where courseid in ('.$courseid.') and classid in ('.$classid.') group by gradename;';
			
	//echo $query;
	$results = $this->db->query($query);
		
	if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			return $temp[0];
		}
	return false;  
  }
  
  
  public function results_chart($classid, $courseid) {
  
  	$courseid = $courseid;
	$classid = $classid;

  
	$query = 'SELECT	p.gradeid, p.gradename, p.total_qty, 
	
		CASE WHEN t.total_qty = 0 then \'0\' 
		else round(p.total_qty * 100.0 / t.total_qty, 2) || '.'\'%\''. 'end
		
		as percentage
		
		
		
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
	)t;';
			
	//print_r($query);

//die();	
	$results = $this->db->query($query);
		
	if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			
			return $temp;
		}
	return false;    
  }

}
