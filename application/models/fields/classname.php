<?php
require_once 'field.php';
require_once 'exceptions/nstp_exception.php';
require_once 'exceptions/pe_exception.php';

class Classname extends Field {
	protected function toHinduArabic($romannum) {
		$roman_numerals = array('C' => 100, 'L' => 50, 'X' => 10, 'V' => 5, 'I' => 1,);
		$result = 0;
		if (is_numeric($romannum))
			return $romannum;
		else if (preg_match('/^C{0,3}(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$/i', $romannum)) {
			$romannum = strtoupper($romannum);
			for ($i = 0; $i < strlen($romannum); $i++) {
				$val = $roman_numerals[$romannum[$i]];
				$nextvalue = !isset($romannum[$i+1]) ? 0 : $roman_numerals[$romannum[$i+1]];
				$result += ($nextvalue > $val) ? -$val : $val;
			}
			return $result;
		}
		else return false;
	}

	public function parse(&$classname, $a = null, $b = null) {
		if (empty($classname))
			throw new Exception("Class is empty");
		if (($lastspace = strrpos($classname, " ")) === false)
			throw new Exception("Course name and section cannot be distinguished");
		$coursename = substr($classname, 0, $lastspace);

		$mscourses = '/^app physics |^bio |^chem |^env sci |^geol |^math |^mbb |^ms |^physics |^che |^ce |^coe |^ee |^eee |^ece |^ge |^ie |^mate |^me |^mete |^em /i';
		if (preg_match('/^pe /i', $coursename))
			throw new PeException();
		else if (preg_match('/^cwts|^rotc|^lts|mil\s?sci/i', $coursename))
			throw new NstpException();
		else if (preg_match('/^cs /i', $coursename))
			$domain = "CSE";
		else if (preg_match($mscourses, $coursename))
			$domain = "MSEE";
		else
			$domain = "FE";

		$section = substr($classname, $lastspace + 1);
		if (strlen($section) > 12)
			throw new Exception("Section is longer than 12 characters");
		//covert roman numeral course num
		if (($lastspace = strrpos($coursename, " ")) !== false) {
			$coursenum = substr($coursename, $lastspace + 1);
			/*
			if (($coursenumint = $this->toHinduArabic($coursenum)) === false)
				throw new Exception("Invalid course number");
			*/
			if (($coursenumint = $this->toHinduArabic($coursenum)) !== false)	
				$coursename = substr_replace($coursename, $coursenumint, $lastspace+1);
		}

		$this->values['coursename'] = $coursename;
		$this->values['section'] = $section;
		$this->values['domain'] = $domain;
	}
}
?>