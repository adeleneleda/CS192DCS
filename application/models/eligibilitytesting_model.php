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
	
	public function get_studentyears() {
		$results = $this->db->query('select year as yearid, year || \'-xxxxx\' as year from (select distinct substr(studentno, 1, 4) as year from students ORDER BY year) as temp');
		$final = $results->result_array();
		return $final;
	}

	public function get_studentsofterm($termid, $year) {
		$query = 'SELECT * FROM f_loadstudents_andineligible_nosum(' . $termid . ', \'' . $year . '%\')';
		$results = $this->db->query($query);
		$final = $results->result_array();
		return $final;
	}
	
	public function get_studentsofyear($termid, $year) {
		$yearid = (int) ($termid / 10);
		$query = 'SELECT * FROM f_loadstudents_andineligible_year(' . $termid . ', \'' . $year . '%\', ' . $yearid . ')';
		$results = $this->db->query($query);
		$final = $results->result_array();
		return $final;
	}
	
	public function get_terms() {
		$results = $this->db->query('SELECT termid, name FROM terms ORDER BY termid');
		$final = $results->result_array();
		return $final;
	}
	
	public function e_TwiceFail($termid) {
		$results = $this->db->query('SELECT elig.*, \'(\' || terms.year || \')\' AS name FROM f_loadelig_twicefailsubjects(' . $termid . ') AS elig JOIN terms USING (termid)');
		$final = $results->result_array();
		return $final;
	}
	
	public function e_PassHalf($termid) {
		$results = $this->db->query('SELECT eligpasshalf.*, \'(\' || terms.year || \')\' AS name FROM eligpasshalf JOIN terms USING (termid) WHERE eligpasshalf.termid <= ' . $termid);
		$final = $results->result_array();
		return $final;
	}
	
	public function e_PassHalfMathCS($termid) {
		$results = $this->db->query('SELECT eligpasshalfmathcs.*, \'(\' || terms.year || \')\' AS name FROM eligpasshalfmathcs JOIN terms USING (termid) WHERE termid <= ' . $termid);
		$final = $results->result_array();
		return $final;
	}
	
	public function e_24UnitsPassed($yearid) {
		$query = 'SELECT *, yearid || \'-\' || (yearid + 1) AS name FROM elig24unitspassing WHERE yearid <= ' . $yearid;
		$results = $this->db->query($query);
		$final = $results->result_array();
		return $final;
	}
	
	public function get_termname($termid) {
		$results = $this->db->query('SELECT name FROM terms WHERE ('. $termid .') = termid');
		$final = $results->result_array();
		return $final[0];
	}
	
	public function postprocessing_bystudent($studentid) {
		$this->db->query('DELETE FROM eligtwicefail WHERE studentid = ' . $studentid);
		$this->db->query('DELETE FROM eligpasshalf WHERE studentid = ' . $studentid);
		$this->db->query('DELETE FROM eligpasshalfmathcs WHERE studentid = ' . $studentid);
		$this->db->query('DELETE FROM elig24unitspassing WHERE studentid = ' . $studentid);
		
		$this->db->query('INSERT INTO eligtwicefail SELECT DISTINCT * FROM f_getall_eligtwicefail_student(' . $studentid . ') ORDER BY studentid, courseid, termid');
		$this->db->query('INSERT INTO eligpasshalf SELECT DISTINCT * FROM f_getall_eligpasshalf_student(' . $studentid . ') ORDER BY studentid, studenttermid, termid, failpercentage');
		$this->db->query('INSERT INTO eligpasshalfmathcs SELECT DISTINCT * FROM f_getall_eligpasshalfmathcs_student(' . $studentid . ') ORDER BY studentid, studenttermid, termid, failpercentage');
		$this->db->query('INSERT INTO elig24unitspassing SELECT DISTINCT * FROM f_getall_24unitspassed_student(' . $studentid . ') ORDER BY studentid, yearid, unitspassed');
	}
	
	public function postprocessing() {
		$this->db->query('TRUNCATE eligtwicefail, eligpasshalf, eligpasshalfmathcs, elig24unitspassing;');
		$this->db->query('INSERT INTO eligtwicefail SELECT DISTINCT * FROM f_getall_eligtwicefail() ORDER BY studentid, courseid, termid');
		$this->db->query('INSERT INTO eligpasshalf SELECT DISTINCT * FROM f_getall_eligpasshalf() ORDER BY studentid, studenttermid, termid, failpercentage');
		$this->db->query('INSERT INTO eligpasshalfmathcs SELECT DISTINCT * FROM f_getall_eligpasshalfmathcs() ORDER BY studentid, studenttermid, termid, failpercentage');
		$this->db->query('INSERT INTO elig24unitspassing SELECT DISTINCT * FROM f_getall_24unitspassed() ORDER BY studentid, yearid, unitspassed');
	}
}
