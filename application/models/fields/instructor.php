<?php
require_once 'field.php';

class Instructor extends Field {
	public function parse(&$fullname, $a = null, $b = null) {
		$sep_name = explode(',', $fullname.',,');
		for ($i = 0; $i < 2; $i++) {
			$name = strtoupper(trim($sep_name[$i]));
			$fieldname = ($i == 0) ? 'lastname' : 'firstname';
			if (empty($name))
				$name = '';
			else if (preg_match('/[^\-a-zA-Z\. ]/u', $name))
				throw new Exception("Instructor name contains non-alphabetic characters");
			else if (strlen($name) > 45)
				throw new Exception("Instructor name is greater than 45 characters");
			$this->values['instructor_'.$fieldname] = $name;
		}
	}
}
?>