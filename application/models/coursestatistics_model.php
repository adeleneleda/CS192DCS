<?php
require_once('base_model.php');
class Coursestatistics_model extends Base_Model {
   public function __construct()
   {
      parent::__construct();
   }
   
  public function dropdown_info() {
  
	$query = "select coursename, courseid from courses where domain = 'MAJ';";
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
  
  public function get_years() {
  
	$query = "select distinct year from terms;";
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

  
  

  public function search($courseid, $startyear, $endyear, $startsem, $endsem,  $instructorid, $section) {
  
	$query = "SELECT classid, courseid, coursename, terms.name as ayterm, section, lastname || ', ' || firstname as instructorname
			FROM courses JOIN classes USING (courseid) 
			JOIN instructorclasses USING (classid) 
			JOIN instructors USING (instructorid) 
			JOIN persons using (personid)
			JOIN terms USING (termid)  
			WHERE courseid = ".$courseid." 
			AND termid <= (select termid from terms where year ilike '%".$endyear."%' and sem ilike '%".$endsem."%') 
			 AND termid >= (select termid from terms where year ilike '%".$startyear."%' and sem ilike '%".$startsem."%') AND instructorid in (".$instructorid.") and section ilike '%".$section."%';";

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
	classid in ('.$classid.') and gradeid < 10),2) || \'%\' as percentage from classes where classid in ('.$classid.');';
  }
  else {
  $query = 'select (select count(*) from studentclasses join classes using (classid) where courseid in ('.$courseid.')) as count, round((select count(*) * 100.00 / (select count(*) from studentclasses join classes using (classid) where  
	courseid in ('.$courseid.')) from studentclasses join classes using (classid) where
	courseid in ('.$courseid.') and gradeid < 10),2) || \'%\' as percentage from classes where courseid in ('.$courseid.') limit 1;';
  }
  
  $results = $this->db->query($query);
	if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			return $temp[0];
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
	
	public function whole_index_of_discrimination($sem, $courseid) {  
		$pass1 = 0;
		$pass2 = 0;
        $currentsem = $this->db->query('SELECT termid FROM terms WHERE name = \'' . $sem . '\';');
        $currentsem = $currentsem->result_array();
        $thissem = $currentsem[0]['termid'];
		$semester = $thissem%10;
		$prevsem = ($thissem/10) - $semester/10;
	
		if($semester == 1)
		{
			$prevsem = $prevsem - 1;
			$prevsem = $prevsem*10;
			$prevsem = $prevsem + 3;
		}
		else if($semester == 2)
		{
			$prevsem = $thissem-1;
		}
        else if($semester == 3)
        {
            $prevsem = $thissem-1;
        }
			$results = $this->db->query('SELECT grades.gradevalue
				FROM students s
				JOIN persons USING (personid)
				JOIN studentterms USING (studentid)
				JOIN studentclasses USING (studenttermid)
				JOIN terms USING (termid)
				JOIN grades USING (gradeid)
				JOIN classes USING (classid)
				JOIN courses USING (courseid)
				JOIN instructorclasses using (classid)
				JOIN instructors using (instructorid)
				WHERE courses.courseid = ' . $courseid . '
				ORDER BY xcwa69(s.studentid, ' . $prevsem . ') ASC;');
			$results = $results->result_array();				
            $ctr = 0;
            
			if(sizeof($results) < 10) {
				$iod = "N/A";
			}
			else {
                for($ctr = 0; $ctr < 10; $ctr++)
                {
                    if($results[$ctr]['gradevalue'] != '5.00')
                    {
                        $pass1++;
                    }
                }
                for($ctr = sizeof($results)-1; $ctr > sizeof($results)-11; $ctr--)
                {
                    if($results[$ctr]['gradevalue'] != '5.00')
                    {
                        $pass2++;
                    }
                }
				$iod = ($pass1 - $pass2)/10;
			}
            return $iod;
  
  
  
  }
  
	public function index_of_discrimination($sem, $courseid, $instructorname){
		$pass1 = 0;
		$pass2 = 0;
        $instructor = $this->db->query('SELECT instructorid FROM instructors JOIN persons using (personid) WHERE lastname || \', \' || firstname = \''.$instructorname.'\';');
        $instructor = $instructor->result_array();
        $instructorid = $instructor[0]['instructorid'];
        $currentsem = $this->db->query('SELECT termid FROM terms WHERE name = \'' . $sem . '\';');
        $currentsem = $currentsem->result_array();
        $thissem = $currentsem[0]['termid'];
		$semester = $thissem%10;
		$prevsem = ($thissem/10) - $semester/10;
	
		if($semester == 1)
		{
			$prevsem = $prevsem - 1;
			$prevsem = $prevsem*10;
			$prevsem = $prevsem + 3;
		}
		else if($semester == 2)
		{
			$prevsem = $thissem-1;
		}
        else if($semester == 3)
        {
            $prevsem = $thissem-1;
        }
			$results = $this->db->query('SELECT grades.gradevalue
				FROM students s
				JOIN persons USING (personid)
				JOIN studentterms USING (studentid)
				JOIN studentclasses USING (studenttermid)
				JOIN terms USING (termid)
				JOIN grades USING (gradeid)
				JOIN classes USING (classid)
				JOIN courses USING (courseid)
				JOIN instructorclasses using (classid)
				JOIN instructors using (instructorid)
				WHERE courses.courseid = ' . $courseid . ' AND terms.termid = ' . $thissem . ' AND instructors.instructorid = ' . $instructorid. '
				ORDER BY xcwa69(s.studentid, ' . $prevsem . ') ASC;');
			$results = $results->result_array();				
            $ctr = 0;
            
			if(sizeof($results) < 10) {
				$iod = "N/A";
			}
			else {
                for($ctr = 0; $ctr < 10; $ctr++)
                {
                    if($results[$ctr]['gradevalue'] != '5.00')
                    {
                        $pass1++;
                    }
                }
                for($ctr = sizeof($results)-1; $ctr > sizeof($results)-11; $ctr--)
                {
                    if($results[$ctr]['gradevalue'] != '5.00')
                    {
                        $pass2++;
                    }
                }
				 $iod = ($pass1 - $pass2)/10;
			}
            return $iod;
	}
  
	public function make_csv($classid = null, $courseid) {
  
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
			$this->load->dbutil();
			$delimiter = ",";
			$newline = "\r\n";
			$temp = $this->dbutil->csv_from_result($results, $delimiter, $newline);
			
			return $temp;
		}
	return false;    
  }

	 public function get_classname($classid){
			$query = 'select coursename, section, termid from classes join courses using (courseid) where classid in ('.$classid.')';
			$results = $this->db->query($query);
			$result = $results->result_array();
			return $result[0];
		
	 }
	 
	 public function get_coursename($courseid){
			$query = 'select coursename from courses where courseid in ('.$courseid.')';
			$results = $this->db->query($query);
			$result = $results->result_array();
			return $result[0]['coursename'];
		
	 }
}
