<?php

/** Holds a row of data to be added to the database. */
class Query_data extends CI_Model {
	private $shouldExecute;
	
	public function __construct() {
		parent::__construct();
		$this->shouldExecute = true;
	}

	/** Holds the query data (acad year, last name, grade, etc. */
	private $data = array();
	/* Data list:
		acadyear	semester	termname	studentno
		firstname	middlename	lastname	pedigree
		classcode	coursename	section		grade
		termid		batch
	*/
	
	public function doNotExecute() {
		$this->shouldExecute = false;
	}
	
	private function distinctInsert($search_query, $insert_query, $primary_key) {
		$result = $this->db->query($search_query);
		$row = $result->result_array();
		if (empty($row)) {
			$result = $this->db->query($insert_query);
			$result = $this->db->query($search_query);
			$row = $result->result_array();
			if (empty($row)) // was not inserted
				throw new Exception("Failed to add to database");
		}
		return $row[0][$primary_key];
	}
	
	private function get_personid() {
		$search = "SELECT personid FROM persons WHERE lastname = '$this->lastname' AND firstname = '$this->firstname' AND middlename = '$this->middlename' AND pedigree='$this->pedigree';";
		$insert = "INSERT INTO persons(lastname, firstname, middlename, pedigree) VALUES ('$this->lastname', '$this->firstname', '$this->middlename', '$this->pedigree');";
		$personid = $this->distinctInsert($search, $insert, 'personid');
		return $personid;
	}
	
	private function get_termid() {
		$this->termid = $this->acadyearid . $this->semid;
		$this->termname = $this->semname . ' '. $this->acadyearname;
		$search = "SELECT termid FROM terms WHERE termid = '$this->termid' AND year = '$this->acadyearname' AND sem = '$this->semester';";
		$insert = "INSERT INTO terms VALUES ('$this->termid', '$this->termname', '$this->acadyearname', '$this->semester');";
		$termid = $this->distinctInsert($search, $insert, 'termid');
		return $this->termid;
	}
	
	private function get_curriculumid() {
		$query = "SELECT curriculumid FROM curricula WHERE curriculumname='new'";
		$result = $this->db->query($query);
		$row = $result->result_array();
		$new = $row[0]['curriculumid'];
		
		$query = "SELECT curriculumid FROM curricula WHERE curriculumname='old'";
		$result = $this->db->query($query);
		$row = $result->result_array();
		$old = $row[0]['curriculumid'];
			
		if($this->batch == '2010' || $this->batch == '2011')
			return $old;
		else
			return $new;
	}
	
	private function get_studentid($personid, $curriculumid) {
		$search = "SELECT studentid FROM students WHERE personid='$personid'";
		$insert = "INSERT INTO students(personid, studentno, curriculumid) VALUES($personid, $this->studentno, $curriculumid);";
		$studentid = $this->distinctInsert($search, $insert, 'studentid');
		return $studentid;
	}

	private function get_courseid() {
		$query = "SELECT MAX(courseid) FROM courses;";
		$result = $this->db->query($query);
		$row = $result->result_array();
		$courseid = $row[0]['max'] + 1;

		$search = "SELECT courseid FROM courses WHERE coursename ILIKE '$this->coursename';";
		$insert = "INSERT INTO courses VALUES ($courseid, '$this->coursename', 3, '$this->domain');";
		$courseid = $this->distinctInsert($search, $insert, 'courseid');
		return $courseid;
	}
 	
	private function get_classid($termid, $courseid) {
		$section = $this->section;
		$classcode = $this->classcode;
		$search = "SELECT classid FROM classes WHERE termid = '$termid' AND courseid = '$courseid' AND section = '$section' AND classcode = '$classcode';";
		$insert = "INSERT INTO classes(termid, courseid, section, classcode) VALUES($termid, $courseid, '$section', '$classcode');";
		$classid = $this->distinctInsert($search, $insert, 'classid');
		return $classid;
	}
	
	private function get_studenttermid($studentid, $termid) {
		$ineligibilities = 'N/A';
		$issettled = 'TRUE';
		$search = "SELECT studenttermid FROM studentterms WHERE studentid = '$studentid' AND termid = '$termid';";		
		$insert = "INSERT INTO studentterms(studentid, termid, ineligibilities, issettled) VALUES($studentid, $termid, '$ineligibilities', $issettled);";
		$studenttermid = $this->distinctInsert($search, $insert, 'studenttermid');
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
		$search = "SELECT studentclassid FROM studentclasses WHERE studenttermid = '$studenttermid' AND classid = '$classid' AND gradeid = '$gradeid';";
		$insert = "INSERT INTO studentclasses(studenttermid, classid, gradeid) VALUES($studenttermid, $classid, $gradeid);";
		$studentclassid = $this->distinctInsert($search, $insert, 'studentclassid');
		return $studentclassid;
	}
	
	public function execute() {
		if (!$this->shouldExecute)
			return;
		$personid = $this->get_personid();
		$curriculumid = $this->get_curriculumid();
		$studentid = $this->get_studentid($personid, $curriculumid);
		$termid = $this->get_termid();
		$courseid = $this->get_courseid();
		$classid = $this->get_classid($termid, $courseid);
		$studenttermid = $this->get_studenttermid($studentid, $termid);
		$gradeid = $this->get_gradeid();
		$studentclassid = $this->get_studentclassid($studenttermid, $classid, $gradeid);
	}
	
	// Groupmates, you don't need to understand everything else below, just leave it as is.
	// From http://php.net/manual/en/language.oop5.overloading.php#object.get
	public function __get($name) {
		if ($name === "db")
			return parent::__get($name);
		else
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