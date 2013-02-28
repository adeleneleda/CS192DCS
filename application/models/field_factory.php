<?php
require_once 'fields/field.php';
require_once 'fields/acadyear.php';
require_once 'fields/semester.php';
require_once 'fields/studentno.php';
require_once 'fields/lastname.php';
require_once 'fields/firstname.php';
require_once 'fields/middlename.php';
require_once 'fields/pedigree.php';
require_once 'fields/classcode.php';
require_once 'fields/classname.php';
require_once 'fields/grade.php';

class Field_factory extends CI_Model {
	private $fields = array('', 'Acadyear', 'Semester', 'Studentno', 'Lastname', 
		'Firstname', 'Middlename', 'Pedigree', 'Classcode', 'Classname', 'Grade');
	
	public function createField($field) {
		if (is_numeric($field))
			return $this->createFieldByNum($field);
		else
			return $this->createFieldByName($field);
	}
	
	public function createFieldByNum($fieldnum) {
		$fieldname = $this->fields[$fieldnum];
		return $this->createFieldByName($fieldname);
	}
	
	public function createFieldByName($fieldname) {
		return new $fieldname;
	}
}
?>