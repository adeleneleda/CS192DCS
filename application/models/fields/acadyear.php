<?php
require_once 'field.php';

class Acadyear extends Field {
	public function parse(&$acadyear, $a = null, $b = null) {
		$acadyear = preg_replace('/ /', '', $acadyear); // remove spaces
		if (empty($acadyear)) // nothing was left
			throw new Exception("Acad year is empty");
		else if (preg_match('/[^\d\-]/', $acadyear))
			throw new Exception("Acad year contains non-numeric characters");
		$acadyear = explode("-", $acadyear); // separate by hyphen (e.g. 2010-2011)
		$acadyear = array_filter($acadyear); // remove empty elements
		$acadyear = array_values($acadyear); // rearrange elements to remove gaps in index
		$start = $acadyear[0];
		if (count($acadyear) == 1) // no end year was specified
			$acadyear = $start."-".($start + 1);
		else { // end year was specified
			$end = $acadyear[1];
			if ($end - $start !== 1)
				throw new Exception("Start and end of acad year are not 1 year apart");
			$acadyear = $start."-".$end;
		}
		$this->values['acadyearid'] = $start;
		$this->values['acadyearname'] = $acadyear;
	}
}
?>