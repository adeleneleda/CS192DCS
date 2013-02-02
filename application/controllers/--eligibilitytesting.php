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
		
		$this->load_view('eligibilitytesting_view', compact('students', 'terms', 'activeyear', 'activetermid'));
	}
}

