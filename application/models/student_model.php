<?php
	class student_model extends CI_Model {
			
		function __construct() {
			parent::__construct();
		}
		
		function getStudents(){
			$query = "SELECT personid, studentno, lastname, firstname, middlename, pedigree FROM students NATURAL JOIN persons ORDER BY studentno;";
			$result = $this->db->query($query);
			$rows = $result->result_array();

			return $rows;
		}
		
		public function changeStudentInfo($changedfield_name, $changedfield_value, $personid){
			if ($changedfield_name == "studentno")
				$tablename = "students";
			else
				$tablename = "persons";
			$query = "UPDATE $tablename SET $changedfield_name = '$changedfield_value' WHERE personid = '$personid'";
			$this->db->query($query);	
			
			if ($this->db->affected_rows() > 0){
				return true;
			}
			else{
				throw new Exception("Error in update of student information.");
			}
		}//end change student info	

	}//end class
	
	
?>