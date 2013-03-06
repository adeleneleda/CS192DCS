<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class StudentRankings extends CI_Controller {
	public function __construct() {
		parent::__construct();
		$this->load->model('StudentRankings_Model', 'Model');
	}
    
    public function get_students()
    {
        $yearlevel = $this->input->post("year");
        $year = $this->Model->get_studentyears();
        $semester = $this->input->post('semester');
        $yearlvl = $this->input->post('cyear');
        $sem = ($yearlvl)*10 + $semester; 
        $name = $this->Model->get_gwa($sem, $yearlevel);
        $this->session->set_userdata('thisyear', $yearlevel);
        $this->session->set_userdata('thissem', $semester);
        $this->session->set_userdata('thisacadyear', $yearlvl);
        $currentyear = $this->session->userdata('thisyear');
        $currentsem = $this->session->userdata('thissem');
        $semarray = $this->Model->get_semesters();
        $y = $this->Model->get_years();
        $this->load_view('studentrankings_view', compact('name', 'year', 'sem', 'currentyear', 'currentsem', 'yearlvl', 'semarray', 'y'));
    }
    
    public function index()
    {
        $year = $this->Model->get_studentyears();
		$y = $this->Model->get_years();
		$currentyear = $this->session->userdata('thisyear');
		$currentsem = $this->session->userdata('thissem');
		$yearlvl = $this->session->userdata('thisacadyear');
		if(empty($currentyear)) $currentyear = $year[0]['yearid'];
		if(empty($yearlvl)) $yearlvl = $y[0]['yearid'];
        if(empty($currentsem))$currentsem = 1;
		$yearlevel = $currentyear;
		$semester = $currentsem;
		$sem = $yearlevel*10 + $semester; 
		$name = $this->Model->get_gwa($sem, $yearlevel);
        $semarray = $this->Model->get_semesters();
        $this->load_view('studentrankings_view', compact('name', 'year', 'sem', 'currentyear', 'currentsem', 'yearlvl', 'semarray', 'y', 'yearlvl'));
    }   
	
	public function generate_csv()
    {
		//$yearlevel= $_POST['csv_year'];
		//$semester = $_POST['csv_sem'];
		$yearlevel = $this->session->userdata('thisyear');
		$semester = $this->session->userdata('thissem');
		$sem = $yearlevel*10 + $semester; 
		$temp = $this->Model->make_csv($sem, $yearlevel);
		header("Content-type: text/csv");
		header("Content-length:". strlen($temp));
		header("Content-Disposition: attachment; filename=".$yearlevel."_".$semester.".csv");
		
		echo $temp;
		exit;
    }   
}
?>
