<?php
require_once 'field.php';

class Classcode extends Field {
	public function parse(&$classcode, $a = null, $b = null) {
		if (empty($classcode))
			throw new Exception("Class code is empty");
		else if (preg_match('/[^\d]/', $classcode))
			throw new Exception("Class code contains non-numeric characters");
		$this->values['classcode'] = $classcode;
	}
}
?>