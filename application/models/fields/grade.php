<?php
require_once 'field.php';

class Grade extends Field {
	public function parse(&$grade, $compgrade = null, $secondcompgrade = null) {
		$grade = trim($grade);
		$compgrade = trim($compgrade);
		$secondcompgrade = trim($secondcompgrade);
		if (!empty($secondcompgrade))
			$grade = $secondcompgrade;
		else if (!empty($compgrade))
			$grade = $compgrade;
			
		if (empty($grade))
			$grade = "NG";
		else if (preg_match('/^([12](\.([27]50*|[05]0*))?)$|^([345](\.0*)?)$/', $grade))
			$grade = number_format($grade, 2); // make into 2 decimal places
		else if (preg_match('/^DRP$|^NG$|^INC$/i', $grade))
			$grade = strtoupper($grade);
		else if (!strcasecmp('IP', $grade))
			$grade = 'NG';
		else
			throw new Exception('Invalid input in grade');
		$this->values['grade'] = $grade;
	}
}
?>