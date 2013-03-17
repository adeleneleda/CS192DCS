<?php
require_once 'field.php';

class Pedigree extends Field {
	public function parse(&$pedigree, $a = null, $b = null) {
		$pedigree = strtoupper(trim($pedigree));
		if (strlen($pedigree) > 45)
			throw new Exception("Pedigree is greater than 45 characters");
		else if (preg_match('/[^\-a-zA-Z\. ]/u', $pedigree))
			throw new Exception("Pedigree contains non-alphabetic characters");
		$this->values['pedigree'] = $pedigree;
	}
}
?>