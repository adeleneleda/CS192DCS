<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class StudentRankings extends CI_Controller {
	public function __construct() {
		parent::__construct();
		$this->load->model('StudentRankings_Model', 'Model');
	}
    
    public function get_students()
    {
        $year = $this->input->post("year");
        $semester = $this->input->post('semester');
        $name = $this->Model->get_gwa($semester);
		//$math_gwa = $this->Model->get_math_gwa($year);
        //$cs_gwa = $this->Model->get_cs_gwa($year);
        //$gwa = $this->Model->get_gwa($semester, $year);
        $this->load_view('studentrankings_view', compact('name'));
    }
    
    
    public function index()
    {
        $name = $this->Model->get_gwa(20091);
        //$a = $this->Model->get_true();
        //$name = array("Adelen", "Carmeli", "Josh", "Elijah", "Dan", "Ray");
        $this->load_view('studentrankings_view', compact('name'));
    }   
}
?>