<?php
require_once 'field.php';

class Pedigree extends Field {
	public function parse(&$pedigree, $a = null, $b = null) {
		if (strlen($pedigree) > 45)
			throw new Exception("Pedigree is greater than 45 characters");
		$this->values['pedigree'] = $pedigree;
	}
}
?>