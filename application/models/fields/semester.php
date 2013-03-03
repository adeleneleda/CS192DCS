<?php
require_once 'field.php';

class Semester extends Field{
	const FIRST  = "1st";
	const SECOND = "2nd";
	const SUMMER = "Sum";
	
	public function parse(&$semester, $a = null, $b = null) {
		if (empty($semester))
			throw new Exception("Semester is blank");
		else if (!is_numeric($semester))
			throw new Exception("Semester must be numeric");
		else if ($semester < 1 || $semester > 3)
			throw new Exception("Semester must be between 1 and 3");
		$this->values['semid'] = $semester;
		if ($semester == 1) {
			$this->values['semname'] = "1st Semester";
			$this->values['semester'] = "1st";
		}
		else if ($semester == 2) {
			$this->values['semname'] = "2nd Semester";
			$this->values['semester'] = "2nd";
		}
		else {
			$this->values['semname'] = "Summer";
			$this->values['semester'] = "Sum";
		}
	}
}
?>