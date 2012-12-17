<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Eligibilitytesting extends Main_Controller {	

	public function __construct() {
		parent::__construct(true);
		$this->load->model('EligibilityTesting_Model', 'Model');
	}
	
	
	public function index() {
		$this->load_students();
	}

	public function load_students() {
		$activetermid = $this->input->post('termid');
		$activeyear = $this->input->post('year');
		
		if (empty($activetermid)) {
			$activetermid = 20091;
		}
		if (empty($activeyear)) {
			$activeyear = '%';
		}
		
		$students = $this->Model->get_studentsofterm($activetermid, $activeyear);
		$terms = $this->Model->get_terms();
		// print_r($terms);
		
		$this->load_view('eligibilitytesting_view', compact('students', 'terms', 'activeyear', 'activetermid'));
	}
}

