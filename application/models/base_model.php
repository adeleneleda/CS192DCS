<?php
/*
 * Unit_model
 * An easier way to construct your unit testing
 * and pass it to a really nice looking page.
 *
 * @author sjlu
 */
class Base_Model extends CI_Model {

	public function __construct() {
		parent::__construct();
	}
	
	public function get_terms() {
		$results = $this->db->query('SELECT * FROM terms ORDER BY termid');
		$final = $results->result_array();
		return $final;
	}
	
	public function get_studentyears() {
		$results = $this->db->query('select year as yearid, year from (select distinct substr(studentno, 1, 4) as year from students ORDER BY year) as temp');
		$final = $results->result_array();
		return $final;
	}
	
	public function get_years() {
		$results = $this->db->query('SELECT termid / 10 as yearid, year FROM terms GROUP BY yearid, year ORDER BY yearid');
		$final = $results->result_array();
		return $final;
	}
	
	public function get_semesters() {
		$a = array(1 => '1st Semester', 2 => '2nd Semester', 3 => 'Summer');
		return $a;
	}
}
