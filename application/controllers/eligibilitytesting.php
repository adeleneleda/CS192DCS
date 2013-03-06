<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Eligibilitytesting extends Main_Controller {	

	public function __construct() {
		parent::__construct(true);
		$this->load->model('EligibilityTesting_Model', 'Model');
	}
	
	public function test() {
		print_r($this->Model->e_TwiceFail(20101));
	}
	
	public function index() {
		$this->load_students();
	}

	public function load_students() {
		if(!empty($_POST)){
			$activetermid = $this->input->post('yearid') * 10 + $this->input->post('semid');
			$activeyear = $this->input->post('year');
		} else {
			$activetermid = $this->session->userdata('activetermid');
			$activeyear = $this->session->userdata('activeyear');
		}
		if (empty($activetermid))
			$activetermid = 20091;
		if (empty($activeyear))
			$activeyear = '%';
		$this->session->set_userdata('activetermid', $activetermid);
		$this->session->set_userdata('activeyear', $activeyear);
		
		if ($activetermid % 10 == 3) {
			$students = $this->Model->get_studentsofyear($activetermid, $activeyear);
		} else {
			$students = $this->Model->get_studentsofterm($activetermid, $activeyear);
		}
		
		$twiceFail = $this->Model->e_TwiceFail($activetermid);
		$passHalf = $this->Model->e_PassHalf($activetermid);
		$passHalfMathCS = $this->Model->e_PassHalfMathCS($activetermid);
		$total24 = $this->Model->e_24UnitsPassed((int) ($activetermid / 10));
		// print_r($twiceFail);
		// print_r($passHalf);
		// print_r($passHalfMathCS);
		// print_r($total24);
		
		foreach ($students as $studentKey => $oneStudent) {
			// Twice Fail
			$students[$studentKey]['eTwiceFail'] = array();
			foreach ($twiceFail as $oneFail) {
				if ($oneStudent['studentid'] == $oneFail['studentid']) {
					array_push($students[$studentKey]['eTwiceFail'], $oneFail);
				}
			}
			
			// Pass Half
			$students[$studentKey]['ePassHalf'] = array();
			foreach ($passHalf as $oneFail) {
				if ($oneStudent['studentid'] == $oneFail['studentid']) {
					array_push($students[$studentKey]['ePassHalf'], $oneFail);
				}
			}
			
			// Pass Half MathCS
			$students[$studentKey]['ePassHalfMathCS'] = array();
			foreach ($passHalfMathCS as $oneFail) {
				if ($oneStudent['studentid'] == $oneFail['studentid']) {
					array_push($students[$studentKey]['ePassHalfMathCS'], $oneFail);
				}
			}
			
			// Pass 24 Units
			$students[$studentKey]['eTotal24'] = array();
			foreach ($total24 as $oneFail) {
				if ($oneStudent['studentid'] == $oneFail['studentid']) {
					array_push($students[$studentKey]['eTotal24'], $oneFail);
				}
			}
		}
		$studentyears = $this->Model->get_studentyears();
		$temp = array(array('yearid' => '%', 'year' => 'All'));
		$studentyears = array_merge($temp, $studentyears);
		$years = $this->Model->get_years();
		$sems = $this->Model->get_semesters();
		
		// print_r($students);
		
		$this->load_view('eligibilitytesting_view', compact('students', 'studentyears', 'years', 'sems', 'activeyear', 'activetermid'));
	}
	
	public function generate_csv() {
		$activetermid = $_POST['activetermid'];
		$activeyear = $_POST['activeyear'];
		$this->session->set_userdata('activetermid', $activetermid);
		$this->session->set_userdata('activeyear', $activeyear);
		
		
		
		if ($activetermid % 10 == 3) {
			$students = $this->Model->get_studentsofyear($activetermid, $activeyear);
		} else {
			$students = $this->Model->get_studentsofterm($activetermid, $activeyear);
		}
		$twiceFail = $this->Model->e_TwiceFail($activetermid);
		$passHalf = $this->Model->e_PassHalf($activetermid);
		$passHalfMathCS = $this->Model->e_PassHalfMathCS($activetermid);
		$total24 = $this->Model->e_24UnitsPassed((int) ($activetermid / 10));
		// print_r($twiceFail);
		// print_r($passHalf);
		// print_r($passHalfMathCS);
		// print_r($total24);
		
		foreach ($students as $studentKey => $oneStudent) {
			// Twice Fail
			$students[$studentKey]['eTwiceFail'] = array();
			foreach ($twiceFail as $oneFail) {
				if ($oneStudent['studentid'] == $oneFail['studentid']) {
					array_push($students[$studentKey]['eTwiceFail'], $oneFail);
				}
			}
			
			// Pass Half
			$students[$studentKey]['ePassHalf'] = array();
			foreach ($passHalf as $oneFail) {
				if ($oneStudent['studentid'] == $oneFail['studentid']) {
					array_push($students[$studentKey]['ePassHalf'], $oneFail);
				}
			}
			
			// Pass Half MathCS
			$students[$studentKey]['ePassHalfMathCS'] = array();
			foreach ($passHalfMathCS as $oneFail) {
				if ($oneStudent['studentid'] == $oneFail['studentid']) {
					array_push($students[$studentKey]['ePassHalfMathCS'], $oneFail);
				}
			}
			
			// Pass 24 Units
			$students[$studentKey]['eTotal24'] = array();
			foreach ($total24 as $oneFail) {
				if ($oneStudent['studentid'] == $oneFail['studentid']) {
					array_push($students[$studentKey]['eTotal24'], $oneFail);
				}
			}
		}
		
		$temp_students = array();
		foreach ($students as $student) {
			$temp = array();
			$temp['studentno'] = $student['studentno'];
			$temp['name'] = $student['name'];
			
			if (empty($student['eTwiceFail'])) {
				$temp['eTwiceFail'] = '';
			}
			else { 
			$temp['eTwiceFail'] ='';
				foreach ($student['eTwiceFail'] as $one) { 
					$temp['eTwiceFail'] = $temp['eTwiceFail'].$one['coursename'].' '.$one['section'].' '.$one['name'].', '; 
				}
				$temp['eTwiceFail'] = substr($temp['eTwiceFail'], 0, strlen($temp['eTwiceFail'])-2);
			}
			
			if (empty($student['ePassHalf'])) {
				$temp['ePassHalf'] = '';
			}
			else { 
			$temp['ePassHalf'] ='';
				foreach ($student['ePassHalf'] as $one) { 
					$temp['ePassHalf'] = $temp['ePassHalf'].(int) (100 - $one['failpercentage'] * 100). '% Passing '.$one['name'].', '; 
				}
				$temp['ePassHalf'] = substr($temp['ePassHalf'], 0, strlen($temp['ePassHalf'])-2);
			}
			
			if (empty($student['ePassHalfMathCS'])) {
				$temp['ePassHalfMathCS'] = '';
			}
			else { 
			$temp['ePassHalfMathCS'] ='';
				foreach ($student['ePassHalfMathCS'] as $one) { 
					$temp['ePassHalfMathCS'] = $temp['ePassHalfMathCS'].(int) (100 - $one['failpercentage'] * 100). '% Passing '.$one['name'].', '; 
				}
				$temp['ePassHalfMathCS'] = substr($temp['ePassHalfMathCS'], 0, strlen($temp['ePassHalfMathCS'])-2);
			}
			
			if (empty($student['eTotal24'])) {
				$temp['eTotal24'] = '';
			}
			else { 
			$temp['eTotal24'] ='';
				foreach ($student['eTotal24'] as $one) { 
					$temp['eTotal24'] = $temp['eTotal24'].$one['unitspassed'].' Units Passed '.$one['yearid'].', '; 
				}
				$temp['eTotal24'] = substr($temp['eTotal24'], 0, strlen($temp['eTwiceFail'])-2);
			}
			
			array_push($temp_students, $temp);
		}
		
		$terms = $this->Model->get_terms();
		$temp2 = $this->Model->get_termname($activetermid);
		$name = str_replace(' ', '', $temp2['name']);
		
		$return = "\"student no.\",\"student name\",";
		$return = $return."\"twiceFail\",";
		$return = $return."\"ePassHalf\",";
		$return = $return."\"ePassHalfMathCS\",";
		$return = $return."\"eTotal24\",";
		
		$return = $return."\r\n";
		foreach($temp_students as $student){
			$return =  $return.$this->arraytoCsv($student).",\r\n";
		}
		header("Content-type: text/csv");
		header("Content-length:". strlen($return));
		header("Content-Disposition: attachment; filename=".$name."_ineligibilities.csv");
		
		echo $return;
		exit;
		
	}
	
	function arrayToCsv( array &$fields, $delimiter = ',', $enclosure = '"', $encloseAll = false, $nullToMysqlNull = false ) {
		$delimiter_esc = preg_quote($delimiter, '/');
		$enclosure_esc = preg_quote($enclosure, '/');

		$output = array();
		foreach ( $fields as $field ) {
			if ($field === null && $nullToMysqlNull) {
				$output[] = 'NULL';
				continue;
			}

			// Enclose fields containing $delimiter, $enclosure or whitespace
			if ( $encloseAll || preg_match( "/(?:${delimiter_esc}|${enclosure_esc}|\s)/", $field ) ) {
				$output[] = $enclosure . str_replace($enclosure, $enclosure . $enclosure, $field) . $enclosure;
			}
			else {
				$output[] = $field;
			}
		}
		return implode( $delimiter, $output );
	}
}

