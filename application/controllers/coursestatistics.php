<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Coursestatistics extends Main_Controller {	

	public function __construct() {
		parent::__construct(true);
		$this->load->model('Coursestatistics_Model', 'Model');
	}
	
	
   public function index()
	{
	//$this->Model->search();
	//display all?
	$dropdown = $this->Model->dropdown_info();
	
	$section_info = $this->Model->section_info();
	$term_info = $this->Model->term_info();
	$instructor_info = $this->Model->instructor_info();
	
	
	
    $this->load_view('coursestatistics_view', compact('dropdown','section_info', 'term_info', 'instructor_info'));
	}
	
	public function search() {
	$dropdown = $this->Model->dropdown_info();
	
	$section_info = $this->Model->section_info();
	$term_info = $this->Model->term_info();
	$instructor_info = $this->Model->instructor_info();
	
	
	/*
	$coursename = '';
	$starttermid = '0';
	$endtermid = '20151';
	$instructorid = 'select instructorid from instructors';
	$section = '';
	*/
	
	/*print_r($_POST);
	echo($_POST['courseid']);
	echo($_POST['starttermid']);
	echo($_POST['instructor']);
	echo($_POST['section']);*/
	
	$search_results = $this->Model->search($_POST['courseid'],$_POST['starttermid'], $_POST['endtermid'],  $_POST['instructor'], $_POST['section']);
	//print_r($search_results);
	//die();
    $this->load_view('coursestatistics_view', compact('search_results', 'dropdown','section_info', 'term_info', 'instructor_info'));
	}
	
	public function sample() {
		$this->load->view('sample');
	}
	
	public function stat() {
	
	$stat = $this->Model->results_graph($_POST['classid'], $_POST['courseid']);
	//print_r($stat);
	$dropdown = $this->Model->dropdown_info();
	$section_info = $this->Model->section_info();
	$term_info = $this->Model->term_info();
	$instructor_info = $this->Model->instructor_info();
    $this->load_view('stat', compact('stat', 'dropdown','section_info', 'term_info', 'instructor_info'));
	}
   
}

