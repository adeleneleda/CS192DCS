<?php
require_once 'field.php';

class Studentno extends Field {
	public function parse(&$studentno, $a = null, $b = null) {
		$studentno = preg_replace('/[ \-]/', '', $studentno); // remove spaces and hyphens
		if (empty($studentno))
			throw new Exception("Student # is empty");
		else if (preg_match('/[^\d]/', $studentno))
			throw new Exception("Student # contains non-numeric characters");
		else if (strlen($studentno) != 9)
			throw new Exception("Student # must be exactly 9 digits long");
		$this->values['studentno'] = $studentno;
		$this->values['batch'] = substr($studentno, 0, 4);
	}
}
?>