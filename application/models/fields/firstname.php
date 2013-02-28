<?php
require_once 'field.php';

class Firstname extends Field {
	public function parse(&$firstname, $a = null, $b = null) {
		if (empty($firstname))
			throw new Exception("First name is empty");
		else if (preg_match('/[^\-a-zA-Z\. ]/u', $firstname))
			throw new Exception("First name contains non-alphabetic characters");
		else if (strlen($firstname) > 45)
			throw new Exception("First name is greater than 45 characters");
		$this->values['firstname'] = $firstname;
	}
}
?>