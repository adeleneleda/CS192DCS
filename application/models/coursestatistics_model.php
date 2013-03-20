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
  
	if($instructorid == "" || $instructorid == 'select instructorid from instructors') {
		$instructorid = "select instructorid from instructors";  
	/*$query = "SELECT classid, (select count(*) from studentclasses in_sc where in_sc.classid = out_c.classid) as studentsize, courseid, coursename, terms.name as ayterm, section
			FROM courses JOIN classes out_c USING (courseid) 
			JOIN terms USING (termid)  
			WHERE courseid = ".$courseid." 
			AND termid <= (select termid from terms where year ilike '%".$endyear."%' and sem ilike '%".$endsem."%') 
			 AND termid >= (select termid from terms where year ilike '%".$startyear."%' and sem ilike '%".$startsem."%') AND section ilike '%".$section."%';";*/
			 
	$query = "SELECT out_c.classid, lastname || ', ' || firstname as instructorname, (select count(*) from studentclasses in_sc where in_sc.classid = out_c.classid) as studentsize, courseid, coursename, terms.name as ayterm, section
			FROM courses JOIN classes out_c USING (courseid) 
			JOIN terms USING (termid)  
			LEFT JOIN instructorclasses on out_c.classid = instructorclasses.classid 
			LEFT JOIN instructors on instructorclasses.instructorid = instructors.instructorid
			LEFT JOIN persons on instructors.personid = persons.personid
			WHERE courseid = ".$courseid." 
			AND termid <= (select termid from terms where year ilike '%".$endyear."%' and sem ilike '%".$endsem."%') 
			 AND termid >= (select termid from terms where year ilike '%".$startyear."%' and sem ilike '%".$startsem."%') AND section ilike '%".$section."%';";		 	 
	//, lastname || ', ' || firstname as instructorname
	//JOIN instructorclasses USING (classid) 
	//JOIN instructors USING (instructorid) 
	//JOIN persons using (personid)
	//instructorid in (".$instructorid.") and
	//echo $query;
	//die();
	} else {
	
	$query = "SELECT classid, lastname || ', ' || firstname as instructorname, (select count(*) from studentclasses in_sc where in_sc.classid = out_c.classid) as studentsize, courseid, coursename, terms.name as ayterm, section
			FROM courses JOIN classes out_c USING (courseid) 
			JOIN terms USING (termid)  
			JOIN instructorclasses USING (classid) 
			JOIN instructors USING (instructorid) 
			JOIN persons using (personid)
			WHERE courseid = ".$courseid." AND instructorid in (".$instructorid.")
			AND termid <= (select termid from terms where year ilike '%".$endyear."%' and sem ilike '%".$endsem."%') 
			 AND termid >= (select termid from terms where year ilike '%".$startyear."%' and sem ilike '%".$startsem."%') AND section ilike '%".$section."%';";
	
	}
	$results = $this->db->query($query);
	if($results->num_rows() > 0)
		{
			$temp = $results->result_array();		
			//echo "Hi elijah! Ito ung nirereturn nung search function: <br/> May additional index: [studentsize] for # of students :'D<br/>Thanks! Go us!<br/><br/>";
			//print_r($temp);
			return $temp;
		}
	return false;
  }
  
  public function get_classlist($classid) {
  
	  $query = "SELECT studentno, 
	  lastname || ',' || firstname || ' ' || middlename as name, 
	  gradevalue from students join persons using (personid) join studentterms
	  using (studentid) join studentclasses  using (studenttermid) 
	  join grades using (gradeid) where classid = ". $classid .';';
		$results = $this->db->query($query);
		if($results->num_rows() > 0){
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
		$results = $this->db->query('SELECT AVG(zzz) FROM
(SELECT x_iod_perclass2(classid) as zzz FROM
	(SELECT classid 
	FROM classes JOIN courses USING (courseid)
	WHERE courseid = '.$courseid.') as z) as y
WHERE zzz != 100;');
        $results = $results->result_array();
		
        return $results[0]['avg'];
  }

	
	public function index_of_discrimination_perclass($classid){
		$results = $this->db->query('SELECT * FROM x_iod_perclass2(' . $classid . ');');
        $results = $results->result_array();	
        if($results[0]['x_iod_perclass2'] == 100)
        {
            $iod = "N/A";
			return $iod;
        }
        else
        {
            $iod = $results;
			return $iod[0]['x_iod_perclass2'];
        }
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
	 
	 public function change_course_ajax($courseid) {		
		$query = 'select section from classes where courseid ='. $courseid .';';
		$sections = $this->db->query($query);
		$sections = $sections->result_array();
		
		$query = 'select firstname, lastname, instructorid from persons join instructors using (personid) join instructorclasses using (instructorid) join classes using (classid) where courseid = '.$courseid.'order by lastname;';
		$instructors = $this->db->query($query);
		$instructors = $instructors->result_array();
		
		$query = 'select distinct year from terms join classes using (termid) where courseid = '.$courseid.' order by year;';
		$years = $this->db->query($query);
		$years = $years->result_array();
		
		$results = array();
		$results['sections'] = $sections;
		$results['instructors'] = $instructors;
		$results['years'] = $years;
		
		return $results;
		
	 }
	 
	 public function change_acadtermrange_ajax($courseid, $startsem, $startyear, $endsem, $endyear) {
	 //change sections and instructors.
	 
		$query = "select termid from terms where sem ilike '%".$startsem."%' and year ilike '%".$startyear."%';";
		$starttermid = $this->db->query($query);
		$starttermid = $starttermid->result_array();
		$starttermid = $starttermid[0]['termid'];
		
		$query = "select termid from terms where sem ilike '%".$endsem."%' and year ilike '%".$endyear."%';";
		$endtermid = $this->db->query($query);
		$endtermid = $endtermid->result_array();
		$endtermid = $endtermid[0]['termid'];
		
		$query = 'select section from classes where termid >= '.$starttermid.' and termid <= '.$endtermid.' and courseid ='. $courseid .' order by section;';
		$sections = $this->db->query($query);
		$sections = $sections->result_array();
		
		$query = 'select firstname, lastname, instructorid from persons join instructors using (personid) join instructorclasses using (instructorid) join classes using (classid) where termid >= '.$starttermid.' and termid <= '.$endtermid.' and courseid = '.$courseid.' order by lastname;';
		$instructors = $this->db->query($query);
		$instructors = $instructors->result_array();
		
		$results = array();
		$results['sections'] = $sections;
		$results['instructors'] = $instructors;
		
		return $results;
	 }
	 
	 public function change_instructor_ajax($courseid, $startsem, $startyear, $endsem, $endyear, $instructorid) {
	 //change sections
	 
		if($instructorid == "") {
		$instructorid = "select instructorid from instructors";
		}
	 
		$query = "select termid from terms where sem ilike '%".$startsem."%' and year ilike '%".$startyear."%';";
		$starttermid = $this->db->query($query);
		$starttermid = $starttermid->result_array();
		$starttermid = $starttermid[0]['termid'];
		
		$query = "select termid from terms where sem ilike '%".$endsem."%' and year ilike '%".$endyear."%';";
		$endtermid = $this->db->query($query);
		$endtermid = $endtermid->result_array();
		$endtermid = $endtermid[0]['termid'];
	 
		$query = 'select section from classes join instructorclasses using (classid) where instructorid in ('.$instructorid.') and termid >= '.$starttermid.' and termid <= '.$endtermid.' and courseid ='. $courseid .' order by section;';
		$sections = $this->db->query($query);
		$sections = $sections->result_array();
		
		$results = array();
		$results['sections'] = $sections;
			
		return $results;
	 }
	 //no change fuc for section kasi mas important ang instructor than section
	 //what if you want to change instructor pero you have chosen a section na, so wala na ung instructor na gusto mo <//3
	 // u have to reselect the course again.
}
