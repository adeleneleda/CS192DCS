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
			$activetermid = $this->input->post('termid');
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
		$terms = $this->Model->get_terms();
		
		//print_r($students);
		$this->load_view('eligibilitytesting_view', compact('students', 'terms', 'activeyear', 'activetermid', 'show'));
	}
	
	public function generate_csv() {
		/*if(!empty($_POST)){
			$activetermid = $this->input->post('termid');
			$activeyear = $this->input->post('year');
		} else {
			$activetermid = $this->session->userdata('activetermid');
			$activeyear = $this->session->userdata('activeyear');
		}
		if (empty($activetermid))
			$activetermid = 20091;
		if (empty($activeyear))
			$activeyear = '%';*/
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
		/*
		foreach($temp_students as $index=>$l){
			if(empty($l['eTwiceFail'])) $temp_students[$index]['eTwiceFail'] = " ";
			if(empty($l['ePassHalf'])) $temp_students[$index]['ePassHalf'] = " ";
			if(empty($l['ePassHalfMathCS'])) $temp_students[$index]['ePassHalfMathCS'] = " ";
		}*/
		$terms = $this->Model->get_terms();
		$temp2 = $this->Model->get_termname($activetermid);
		
		
		$return = "\"student no.\",\"student name\",";
		if($show['twiceFail']) $return = $return."\"twiceFail\",";
		if($show['passHalf'])	 $return = $return."\"50% inelig.\",";
		if($show['passHalfCSMath'])	 $return = $return."\"Math/CS 50% inelig.\",";
		if($show['24units'])	 $return = $return."\"24 units inelig.\","; 
		$return = $return."\r\n";
		foreach($temp_students as $student){
			$return =  $return.$this->arraytoCsv($student).",\r\n";
		}
		//print_r($temp_students);
		//echo $return;
		//die();
		//$this->load->dbutil();
		//$delimiter = ",";
		//$newline = "\r\n";
		//$temp = $this->dbutil->csv_from_result($terms, $delimiter, $newline);
		//$temp = $this->dbutil->csv_from_result($terms);
		//$return =
		header("Content-type: text/csv");
		header("Content-length:". strlen($return));
		header("Content-Disposition: attachment; filename=".$temp2['name']."_ineligibilities.csv");
		
		echo $return;
		exit;
		//echo $add.$terms;
		//exit;	*/
			/*
			$fp = fopen($temp2['name']."_ineligibilities".'.csv', 'w');
			$array = array('studentid', 'student no.', 'student name', 'twice fail inelig.', '50% passing inelig.', 'Math/CS 50% inelig.', '24 units inelig.');
			fputcsv($fp, $array); 
			foreach ($students as $list){
				
				fputcsv($fp, $list);
			}
		
		$this->load_view('eligibilitytesting_view', compact('students', 'terms', 'activeyear', 'activetermid', 'show24Units'));
		fclose(fp);
		*/
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

