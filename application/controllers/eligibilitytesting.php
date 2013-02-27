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
		
		$show = array();
		$show['twiceFail'] = true;
		$show['passHalf'] = ($activetermid % 10 < 3) ? true : false;
		$show['passHalfCSMath'] = ($activetermid % 10 < 3) ? true : false;
		$show['24units'] = ($activetermid % 10 == 3) ? true : false;
		
		if ($activetermid % 10 == 3)
			$students = $this->Model->get_studentsofyear($activetermid, $activeyear);
		else
			$students = $this->Model->get_studentsofterm($activetermid, $activeyear);
		
		$twiceFail = $this->Model->e_TwiceFail($activetermid);
		$passHalf = $this->Model->e_PassHalf($activetermid);
		$passHalfMathCS = $this->Model->e_PassHalfMathCS($activetermid);
		$total24 = $this->Model->e_24UnitsPassed((int) ($activetermid / 10));
		foreach ($students as $studentKey => $oneStudent) {
			foreach ($twiceFail as $oneFail)
				if ($oneStudent['studentid'] == $oneFail['studentid'])
					$students[$studentKey]['eTwiceFail'] = 'X';
			foreach ($passHalf as $oneFail)
				if ($oneStudent['studentid'] == $oneFail['studentid'])
					$students[$studentKey]['ePassHalf'] = 'X';
			foreach ($passHalfMathCS as $oneFail)
				if ($oneStudent['studentid'] == $oneFail['studentid'])
					$students[$studentKey]['ePassHalfMathCS'] = 'X';
			foreach ($total24 as $oneFail)
				if ($oneStudent['studentid'] == $oneFail['studentid'])
					$students[$studentKey]['eTotal24'] = 'X';
		}
		$studentyears = $this->Model->get_studentyears();
		$temp = array(array('yearid' => '%', 'year' => 'All'));
		$studentyears = array_merge($temp, $studentyears);
		$years = $this->Model->get_years();
		$sems = $this->Model->get_semesters();
		
		$this->load_view('eligibilitytesting_view', compact('students', 'studentyears', 'years', 'sems', 'activeyear', 'activetermid', 'show'));
	}
	
	public function generate_csv() {
		$activetermid = $_POST['activetermid'];
		$activeyear = $_POST['activeyear'];
		$this->session->set_userdata('activetermid', $activetermid);
		$this->session->set_userdata('activeyear', $activeyear);
		
		$show = array();
		$show['twiceFail'] = true;
		$show['passHalf'] = ($activetermid % 10 < 3) ? true : false;
		$show['passHalfCSMath'] = ($activetermid % 10 < 3) ? true : false;
		$show['24units'] = ($activetermid % 10 == 3) ? true : false;
		
		if ($activetermid % 10 == 3) {
			$students = $this->Model->get_studentsofyear($activetermid, $activeyear);
		} else {
			$students = $this->Model->get_studentsofterm($activetermid, $activeyear);
		}
		$twiceFail = $this->Model->e_TwiceFail($activetermid);
		$passHalf = $this->Model->e_PassHalf($activetermid);
		$passHalfMathCS = $this->Model->e_PassHalfMathCS($activetermid);
		$total24 = $this->Model->e_24UnitsPassed((int) ($activetermid / 10));
		foreach ($students as $studentKey => $oneStudent) {
			foreach ($twiceFail as $oneFail)
				if ($oneStudent['studentid'] == $oneFail['studentid'])
					$students[$studentKey]['eTwiceFail'] = 'X';
			foreach ($passHalf as $oneFail)
				if ($oneStudent['studentid'] == $oneFail['studentid'])
					$students[$studentKey]['ePassHalf'] = 'X';
			foreach ($passHalfMathCS as $oneFail)
				if ($oneStudent['studentid'] == $oneFail['studentid'])
					$students[$studentKey]['ePassHalfMathCS'] = 'X';
			foreach ($total24 as $oneFail)
				if ($oneStudent['studentid'] == $oneFail['studentid'])
					$students[$studentKey]['eTotal24'] = 'X';
		}
		
		$temp_students = array();
		foreach ($students as $student) {
			$temp = array();
			$temp['studentno'] = $student['studentno'];
			$temp['name'] = $student['name'];
			
			if($show['twiceFail']) $temp['eTwiceFail'] = empty($student['eTwiceFail']) ? '' : $student['eTwiceFail'];
			if($show['passHalf'])	$temp['ePassHalf'] = empty($student['ePassHalf']) ? '' : $student['ePassHalf'];
			if($show['passHalfCSMath'])	$temp['ePassHalfMathCS'] = empty($student['ePassHalfMathCS']) ? '' : $student['ePassHalfMathCS'];
			if($show['24units'])	$temp['eTotal24'] = empty($student['eTotal24']) ? '' : $student['eTotal24'];
			
			array_push($temp_students, $temp);
		}
		
		$terms = $this->Model->get_terms();
		$temp2 = $this->Model->get_termname($activetermid);
		$name = str_replace(' ', '', $temp2['name']);
		
		$return = "\"student no.\",\"student name\",";
		if($show['twiceFail']) $return = $return."\"twiceFail\",";
		if($show['passHalf'])	 $return = $return."\"50% inelig.\",";
		if($show['passHalfCSMath'])	 $return = $return."\"Math/CS 50% inelig.\",";
		if($show['24units'])	 $return = $return."\"24 units inelig.\","; 
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

