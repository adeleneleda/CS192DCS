<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class StudentRankings extends CI_Controller {
	public function __construct() {
		parent::__construct();
		$this->load->model('StudentRankings_Model', 'Model');
	}
    
    public function get_students()
    {
        $yearlevel = $this->input->post("year");
        $year = $this->Model->get_years();
        $semester = $this->input->post('semester');
        $sem = $yearlevel*10 + $semester; 
        $name = $this->Model->get_gwa($sem, $yearlevel);
        $this->load_view('studentrankings_view', compact('name', 'year', 'sem'));
    }
    
    
    public function index()
    {
        $year = $this->Model->get_years();
        $this->load_view('studentrankings_view', compact('year'));
    }   
}
?>