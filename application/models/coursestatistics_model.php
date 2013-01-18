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
  
  public function get_total_and_percentage($classid = null, $courseid) {

  if($classid != null) {
	$query = 'select classid, (select count(*) from studentclasses where classid in ('.$classid.')) as count, round((select count(*) * 100.00 / (select count(*) from studentclasses where  
	classid in ('.$classid.')) from studentclasses where
	classid in ('.$classid.')),2) || \'%\' as percentage from classes where classid in ('.$classid.');';
  }
  else {
  $query = 'select (select count(*) from studentclasses join classes using (classid) where courseid in ('.$courseid.')) as count, round((select count(*) * 100.00 / (select count(*) from studentclasses join classes using (classid) where  
	courseid in ('.$courseid.')) from studentclasses join classes using (classid) where
	courseid in ('.$courseid.')),2) || \'%\' as percentage from classes where courseid in ('.$courseid.') limit 1;';
  }
  
  $results = $this->db->query($query);
	if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			return $temp;
		}
	return false;    
	
  }
  
  
  public function results_chart($classid = null, $courseid) {
  
	if($classid != null) {
	$query = 'select gradename, (select count(*) from studentclasses where studentclasses.gradeid = grades.gradeid and 
	classid in ('.$classid.')) as count, round((select count(*) * 100.00 / (select count(*) from studentclasses where  
	classid in ('.$classid.')) from studentclasses a where a.gradeid = grades.gradeid and 
	classid in ('.$classid.')),2) || \'%\' as percentage from grades;';
	}
	else {
		$query = 'select gradename, (select count(*) from studentclasses join classes using (classid) where studentclasses.gradeid = grades.gradeid and 
	courseid in ('.$courseid.')) as count, round((select count(*) * 100.00 / (select count(*) from studentclasses join classes using (classid) where  
	courseid in ('.$courseid.')) from studentclasses a join classes using (classid) where a.gradeid = grades.gradeid and 
	courseid in ('.$courseid.')),2) || \'%\' as percentage from grades;';
	}
	
	$results = $this->db->query($query);
		
	if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			
			return $temp;
		}
	return false;    
  }

}
