<?php
	class grades_model extends CI_Model {
			
		function __construct() {
			parent::__construct();
		}
		
		function getStudentInfo($personid){
			$student_info = array();
		
			$query = "SELECT studentno, lastname, firstname, middlename, pedigree FROM students natural join persons where personid = '$personid';";
			$result = $this->db->query($query);
			
			if ($result->num_rows() > 0){
			   $row = $result->row(); 
			   //pedigree how?
			   $student_info['student_name'] = $row->lastname.", ".$row->firstname." ".$row->middlename." ".$row->pedigree;
			   $student_info['studentno'] = $row->studentno;
			}
			
			return $student_info;
		}
		
		function getGrades($personid){
			$grades_info = array();
			
			$studentid = '';
		
			$query = "SELECT studentid FROM STUDENTS where personid = '$personid'";
			$result = $this->db->query($query);
			
			if ($result->num_rows() > 0){
			   $row = $result->row(); 
			   $studentid = $row->studentid;
			}
			
			$query = "SELECT distinct * FROM studentterms NATURAL JOIN terms WHERE studentid = '$studentid' ORDER BY termid";
			$result = $this->db->query($query);
			$rows = $result->result_array();
			
			foreach($rows as $row){
				$term_grades = array();
				
				$termid = $row['termid'];
				$query = "SELECT studentclassid, classcode, coursename, section, credits, gradename 
					 FROM students JOIN persons ON students.personid = persons.personid 
					 JOIN studentterms ON students.studentid = studentterms.studentid 
					 JOIN studentclasses ON studentterms.studenttermid = studentclasses.studenttermid 
					 JOIN classes ON studentclasses.classid = classes.classid 
					 JOIN courses ON classes.courseid = courses.courseid 
					 JOIN grades ON studentclasses.gradeid = grades.gradeid 
					 WHERE students.studentid = '$studentid' AND studentterms.termid = '$termid'";
				$result = $this->db->query($query);
				$rows = $result->result_array();
				
				$term_grades['termname'] = $row['name'];
				$term_grades['rows'] = $rows;
				//$term_grades['query'] = $query;
				
				array_push($grades_info, $term_grades);
			}
		
			return $grades_info;
		}
		
		public function changeGrade($grade, $studentclassid){
			$query = "SELECT gradeid FROM grades WHERE gradename = '$grade'";
			$result = $this->db->query($query);	
			$row = $result->row();
			$gradeid = $row->gradeid;
		
			$query = "UPDATE studentclasses SET gradeid = '$gradeid' WHERE studentclassid = '$studentclassid'";
			$this->db->query($query);	
			
			if ($this->db->affected_rows() > 0){
				return true;
			}
			else {
				throw new Exception("Error in update of grade.");
			}
		}//end change grade

	}//end class	
?>