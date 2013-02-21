<?php
require_once('base_model.php');
/*
 * Unit_model
 * An easier way to construct your unit testing
 * and pass it to a really nice looking page.
 *
 * @author sjlu
 */
class EligibilityTesting_Model extends Base_Model {

	public function __construct() {
		parent::__construct();
	}

	public function get_studentsofterm($termid, $year) {
		$results = $this->db->query('SELECT studentid, studentno, firstname || \' \' || middlename || \' \' || lastname as name FROM students JOIN studentterms USING (studentid) JOIN persons USING (personid) WHERE studentterms.termid = ' . $termid . ' AND studentno ILIKE \'' . $year . '%\'');
		
		$final = $results->result_array();
		return $final;
	}
	
	public function get_studentsofyear($termid, $year) {
		$termid = (int) ($termid / 10);
		$year1 = $termid * 10 + 1;
		$year2 = $termid * 10 + 2;
		$year3 = $termid * 10 + 3;
		$results = $this->db->query('SELECT DISTINCT studentid, studentno, 
			firstname || \' \' || middlename || \' \' || lastname as name 
			FROM students JOIN studentterms USING (studentid) JOIN persons USING (personid) 
			WHERE studentterms.termid IN (' . $year1 . ', ' . $year2 . ', ' . $year3 . ') AND studentno ILIKE \'' . $year . '%\'');
		
		$final = $results->result_array();
		return $final;
	}
	
	public function get_terms() {
		$results = $this->db->query('SELECT termid, name FROM terms ORDER BY termid');
		$final = $results->result_array();
		return $final;
	}
	
	public function e_TwiceFail($termid) {
		$results = $this->db->query('SELECT * FROM f_elig_twicefailsubjects(' . $termid . ')');
		$final = $results->result_array();
		return $final;
	}
	
	public function e_PassHalf($termid) {
		$results = $this->db->query('SELECT * FROM f_elig_passhalfpersem(' . $termid . ')');
		$final = $results->result_array();
		return $final;
	}
	
	public function e_PassHalfMathCS($termid) {
		$results = $this->db->query('SELECT * FROM f_elig_passhalf_mathcs_persem(' . $termid . ')');
		$final = $results->result_array();
		return $final;
	}
	
	public function e_24UnitsPassed($termid) {
		$results = $this->db->query('SELECT * FROM f_elig_24unitspassed(' . $termid . ')');
		$final = $results->result_array();
		return $final;
	}
	
	public function get_termname($termid) {
		$results = $this->db->query('SELECT name FROM terms WHERE ('. $termid .') = termid');
		$final = $results->result_array();
		return $final[0];
	}
}
