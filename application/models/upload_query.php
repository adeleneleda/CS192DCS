<?php

/** Holds a row of data to be added to the database. */
class Upload_query extends CI_Model {
	private $shouldExecute;
	
	public function __construct() {
		parent::__construct();
		$this->db = parent::__get('db');
		$this->shouldExecute = true;
		$this->initializeCurriculumIds();
	}

	/** Holds the query data (acad year, last name, grade, etc. */
	private $data = array();
	/* Data list:
		acadyear	semester	termname	studentno
		firstname	middlename	lastname	pedigree
		classcode	coursename	section		grade
		termid		batch
	*/
	
	private function initializeCurriculumIds() {
		$query = "SELECT curriculumid FROM curricula WHERE curriculumname='new'";
		$result = $this->db->query($query);
		$row = $result->result_array();
		$this->newCurriculum = $row[0]['curriculumid'];
		
		$query = "SELECT curriculumid FROM curricula WHERE curriculumname='old'";
		$result = $this->db->query($query);
		$row = $result->result_array();
		$this->oldCurriculum = $row[0]['curriculumid'];
	}
	
	public function toBeExecuted() {
		$this->shouldExecute = true;
	}
	
	public function doNotExecute() {
		$this->shouldExecute = false;
	}
	
	private function distinctInsert($primary_key_name, $search_query, $insert_query, $update_query = '') {
		$result = $this->db->query($search_query);
		$row = $result->result_array();
		if (empty($row)) {
			$result = $this->db->query($insert_query);
			$result = $this->db->query($search_query);
			$row = $result->result_array();
		} else if (!empty($update_query)) {
			$primary_key = $row[0][$primary_key_name];
			$this->db->query($update_query.' '.$primary_key_name.'='.$primary_key);
		}
		return $row[0][$primary_key_name];
	}
	
	private function get_personid() {
		$search = "SELECT personid FROM persons WHERE lastname = '$this->lastname' AND firstname = '$this->firstname' AND middlename = '$this->middlename' AND pedigree='$this->pedigree';";
		$insert = "INSERT INTO persons(lastname, firstname, middlename, pedigree) VALUES ('$this->lastname', '$this->firstname', '$this->middlename', '$this->pedigree');";
		$personid = $this->distinctInsert('personid', $search, $insert);
		return $personid;
	}
	
	private function get_termid() {
		$termid = $this->acadyearid . $this->semid;
		$termname = $this->semname . ' '. $this->acadyearname;
		$search = "SELECT termid FROM terms WHERE termid = '$termid' AND year = '$this->acadyearname' AND sem = '$this->semester';";
		$insert = "INSERT INTO terms VALUES ('$termid', '$termname', '$this->acadyearname', '$this->semester');";
		$termid = $this->distinctInsert('termid', $search, $insert);
		return $termid;
	}
	
	private function get_curriculumid() {
		if($this->batch == '2010' || $this->batch == '2011')
			return $this->oldCurriculum;
		else
			return $this->newCurriculum;
	}
	
	private function get_studentid($personid, $curriculumid) {
		$search = "SELECT studentid FROM students WHERE personid='$personid'";
		$insert = "INSERT INTO students(personid, studentno, curriculumid) VALUES($personid, $this->studentno, $curriculumid);";
		$studentid = $this->distinctInsert('studentid', $search, $insert);
		return $studentid;
	}

	private function get_courseid() {
		$query = "SELECT MAX(courseid) FROM courses;";
		$result = $this->db->query($query);
		$row = $result->result_array();
		$courseid = $row[0]['max'] + 1;

		$search = "SELECT courseid FROM courses WHERE coursename ILIKE '$this->coursename';";
		$insert = "INSERT INTO courses VALUES ($courseid, '$this->coursename', 3, '$this->domain');";
		$courseid = $this->distinctInsert('courseid', $search, $insert);
		return $courseid;
	}
 	
	private function get_classid($termid, $courseid) {
		$section = $this->section;
		$classcode = $this->classcode;
		$search = "SELECT classid FROM classes WHERE termid = '$termid' AND courseid = '$courseid' AND section = '$section' AND classcode = '$classcode';";
		$insert = "INSERT INTO classes(termid, courseid, section, classcode) VALUES($termid, $courseid, '$section', '$classcode');";
		$classid = $this->distinctInsert('classid', $search, $insert);
		return $classid;
	}
	
	private function get_studenttermid($studentid, $termid) {
		$ineligibilities = 'N/A';
		$issettled = 'TRUE';
		$search = "SELECT studenttermid FROM studentterms WHERE studentid = '$studentid' AND termid = '$termid';";		
		$insert = "INSERT INTO studentterms(studentid, termid, ineligibilities, issettled) VALUES($studentid, $termid, '$ineligibilities', $issettled);";
		$studenttermid = $this->distinctInsert('studenttermid', $search, $insert);
		return $studenttermid;
	}
	
	private function get_gradeid() {
		$query = "SELECT gradeid FROM grades WHERE gradename = '$this->grade';";
		$result = $this->db->query($query);
		$row = $result->result_array();
		$gradeid = $row[0]['gradeid'];
		return $gradeid;
	}
	
	private function get_studentclassid($studenttermid, $classid, $gradeid) {
		$search = "SELECT studentclassid FROM studentclasses WHERE studenttermid = '$studenttermid' AND classid = '$classid';";// AND gradeid = '$gradeid';";
		$insert = "INSERT INTO studentclasses(studenttermid, classid, gradeid) VALUES($studenttermid, $classid, $gradeid);";
		$update = "UPDATE studentclasses SET gradeid = $gradeid WHERE ";
		$studentclassid = $this->distinctInsert('studentclassid', $search, $insert, $update);
		return $studentclassid;
	}
	
	public function execute() {
		if ($this->shouldExecute) {
			$personid = $this->get_personid();
			$curriculumid = $this->get_curriculumid();
			$studentid = $this->get_studentid($personid, $curriculumid);
			$termid = $this->get_termid();
			$courseid = $this->get_courseid();
			$classid = $this->get_classid($termid, $courseid);
			$studenttermid = $this->get_studenttermid($studentid, $termid);
			$gradeid = $this->get_gradeid();
			$studentclassid = $this->get_studentclassid($studenttermid, $classid, $gradeid);
			
			return $studenttermid; //dan
		}
		else return -1;	//dan
	}
	
	// Groupmates, you don't need to understand everything else below, just leave it as is.
	// From http://php.net/manual/en/language.oop5.overloading.php#object.get
	public function __get($name) {
		return $this->data[$name];
	} 

	public function __set($name, $value) {
		$this->data[$name] = $value;
	} 

	public function __isset($name) {
		return isset($this->data[$name]); 
	} 

	public function __unset($name) {
		unset($this->data[$name]); 
	}
}

?>