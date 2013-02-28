<?php
require_once 'field.php';

class Grade extends Field {
	public function parse(&$grade, $compgrade, $secondcompgrade) {
		$grade = trim($grade);
		$compgrade = trim($compgrade);
		$secondcompgrade = trim($secondcompgrade);
		if (empty($grade))
			if (empty($compgrade))
				$grade = "NG";
			else
				throw new Exception("Unexpected input in compgrade");
		else if (preg_match('/^([12](\.([27]50*|[05]0*))?)$|^([345](\.0*)?)$/', $grade))
			$grade = number_format($grade, 2); // make into 2 decimal places
		else if (preg_match('/^DRP$|^NG$|^INC$/i', $grade))
			$grade = strtoupper($grade);
		else
			throw new Exception('Invalid input in grade');
		if (preg_match('/^4\.00$|^INC$/', $grade)) {
			if (empty($compgrade))
				; // leave grade as is
			else if (is_numeric($compgrade))
				if (preg_match('/^([12](\.([27]50*|[05]0*))?)$|^([35](\.0*)?)$/', $compgrade))
					$grade = number_format($compgrade, 2); // make into 2 decimal places
			else
				throw new Exception("Invalid input in compgrade");
		}
		$this->values['grade'] = $grade;
	}
}
?>