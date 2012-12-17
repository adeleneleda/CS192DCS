<?php
/*
 * Unit_model
 * An easier way to construct your unit testing
 * and pass it to a really nice looking page.
 *
 * @author sjlu
 */
class EligibilityTesting_Model extends CI_Model {

	public function __construct() {
		parent::__construct();
	}

	public function get_studentsofterm($termid, $year) {
		// $results = $this->db->query('SELECT studentno, firstname || \' \' || middlename || \' \' || lastname as name FROM students JOIN studentterms USING (studentid) JOIN persons USING (personid) WHERE studentterms.termid = ' . $termid);
		
		$results = $this->db->query('SELECT studentno, firstname || \' \' || middlename || \' \' || lastname as name FROM students JOIN studentterms USING (studentid) JOIN persons USING (personid) WHERE studentterms.termid = ' . $termid . ' AND studentno ILIKE \'' . $year . '%\'');
		
		$final = $results->result_array();
		//print_r($final);
		return $final;
	}
	
	public function get_terms() {
		$results = $this->db->query('SELECT termid, name FROM terms');
		$final = $results->result_array();
		return $final;
	}
}
