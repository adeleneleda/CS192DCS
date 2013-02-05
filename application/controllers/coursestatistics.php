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
		
		$default_courseid = $dropdown[0]['courseid'];
		$default_starttermid = 0;
		$default_endtermid = 10000000;
		$default_instructor = "select instructorid from instructors";
		$default_section = "";
		
		if(!empty($_POST)){
			$selected['courseid'] = $_POST['courseid'];
			$selected['starttermid']= $_POST['starttermid'];
			$selected['endtermid'] = $_POST['endtermid'];
			if($selected['endtermid'] == -1) {
				$selected['endtermid'] = 10000000;
			}
			$selected['instructorid'] = $_POST['instructor'];
			if($selected['instructorid'] == -1) {
				$selected['instructorid'] = "select instructorid from instructors";
			}
			$selected['sectionid'] = $_POST['section'];
			$this->session->set_userdata('coursestat', $selected);
			$search_results = $this->Model->search($selected['courseid'],$selected['starttermid'], $selected['endtermid'],  $selected['instructorid'], $selected['sectionid']);
			//print_r($search_results);
			//die();
			//meli adelen
			$iod = array();
			foreach($search_results as $indiv_search) {
				$iod[] = $this->Model->index_of_discrimination($indiv_search['ayterm'], $selected['courseid'], $indiv_search['instructorname']);
			}
			//meli end
		}else{
			$temp = $this->session->userdata('coursestat');
			if(empty($temp)){
				$selected['courseid'] = $default_courseid;
				$selected['starttermid']= $default_starttermid;
				$selected['endtermid'] = $default_endtermid;
				$selected['instructorid'] = $default_instructor;
				$selected['sectionid'] = $default_section;
				$this->session->set_userdata('coursestat', $selected);
			}else{
				$selected = $this->session->userdata('coursestat');
			}
			$search_results = $this->Model->search($selected['courseid'],$selected['starttermid'],$selected['endtermid'],$selected['instructorid'],$selected['sectionid']);
			//meli and adleen
			$iod = array();
			foreach($search_results as $indiv_search) {
				//echo "HEREEEEEEEEEEEEEE";
				$iod[] = $this->Model->index_of_discrimination($indiv_search['ayterm'], $selected['courseid'], $indiv_search['instructorname']);
			}
			//meli end
		}
		$this->load_view('coursestatistics_view', compact('iod','selected', 'search_results', 'dropdown','section_info', 'term_info', 'instructor_info'));
	}
	
	public function stat() {
		$stat = $this->Model->results_chart($_POST['classid'], $_POST['courseid']);
		$stat2 = $this->Model->get_total_and_percentage($_POST['classid'], $_POST['courseid']);
		$iod = $_POST['iod'];
		//$stat = $this->Model->results_graph(1, 1);
		//print_r($stat);
		$dropdown = $this->Model->dropdown_info();
		$section_info = $this->Model->section_info();
		$term_info = $this->Model->term_info();
		$instructor_info = $this->Model->instructor_info();
		$selected = $this->session->userdata('coursestat');
		$classid = $_POST['classid'];
		$courseid = $_POST['courseid'];
		$this->load_view('stat_view', compact('classid','courseid','iod','stat', 'stat2', 'selected', 'dropdown','section_info', 'term_info', 'instructor_info'));
	}

	public function generate_csv() {
		$temp = $this->Model->make_csv($_POST['csv_classid'], $_POST['csv_courseid']);
		$temp2 = $this->Model->get_classname($_POST['csv_classid']);

		$add = "\"Index of Discrimination\", ".$_POST['csv_iod'].",\n\"Passing Rate\",\"".$_POST['csv_passingrate']."\",\n\n";
		//echo $add.$temp;
		//die();
		
		header("Content-type: text/csv");
		header("Content-length:". strlen($temp));
		header("Content-Disposition: attachment; filename=".$temp2['coursename']."_".$temp2['section']."_".$temp2['termid'].".csv");
		
		echo $add.$temp;
		exit;
	}
	
}


