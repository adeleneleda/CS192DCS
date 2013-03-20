<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Coursestatistics extends Main_Controller {	

	public function __construct() {
		parent::__construct(true);
		$this->load->model('Coursestatistics_Model', 'Model');
	}
	
   public function index()
	{
		$dropdown = $this->Model->dropdown_info();
		$section_info = $this->Model->section_info();
		$year_info = $this->Model->get_years();
		$instructor_info = $this->Model->instructor_info();
		$default_courseid = $dropdown[0]['courseid'];
		$default_startsem = '1st';
		$default_starttermid = '2007-2008';
		$default_endsem = '1st';
		$default_endtermid = '2012-2013';
		$default_instructor = "select instructorid from instructors";
		$default_section = "";
		
		
		
		if(!empty($_POST)){
			$selected['courseid'] = $_POST['courseid'];
			$selected['startsem']= $_POST['startsem'];
			$selected['starttermid']= $_POST['starttermid'];
			$selected['endsem']= $_POST['endsem'];
			$selected['endtermid'] = $_POST['endtermid'];
			$selected['instructorid'] = $_POST['instructor'];
			if($selected['instructorid'] == -1) {
				$selected['instructorid'] = "select instructorid from instructors";
			}
			$selected['sectionid'] = $_POST['section'];
			$this->session->set_userdata('coursestat', $selected);
			
			$init_dropvalues = $this->Model->change_course_ajax($selected['courseid']);
			$section_info = $init_dropvalues['sections'];
			$year_info = $init_dropvalues['years'];
			$instructor_info = $init_dropvalues['instructors'];
			$search_results = $this->Model->search($selected['courseid'],$selected['starttermid'], $selected['endtermid'], $selected['startsem'], $selected['endsem'], $selected['instructorid'], $selected['sectionid']);
		}else{
			$temp = $this->session->userdata('coursestat');
			if(empty($temp)){
				$selected['courseid'] = $default_courseid;
				$selected['startsem'] = $default_startsem;
				$selected['starttermid']= $default_starttermid;
				$selected['endsem'] = $default_endsem;
				$selected['endtermid'] = $default_endtermid;
				$selected['instructorid'] = $default_instructor;
				$selected['sectionid'] = $default_section;
				$this->session->set_userdata('coursestat', $selected);
				
				$init_dropvalues = $this->Model->change_course_ajax($selected['courseid']);
				$section_info = $init_dropvalues['sections'];
				$year_info = $init_dropvalues['years'];
				$instructor_info = $init_dropvalues['instructors'];
			}else{
				$selected = $this->session->userdata('coursestat');
				
				$init_dropvalues = $this->Model->change_course_ajax($selected['courseid']);
				$section_info = $init_dropvalues['sections'];
				$year_info = $init_dropvalues['years'];
				$instructor_info = $init_dropvalues['instructors'];
			}
			$search_results = $this->Model->search($selected['courseid'],$selected['starttermid'],$selected['endtermid'],$selected['startsem'],$selected['endsem'],$selected['instructorid'],$selected['sectionid']);
		}
		$this->load_view('coursestatistics_view', compact('selected', 'search_results', 'dropdown','section_info', 'year_info', 'instructor_info'));
	}
	
	public function getIOD($tag){
		if($tag == 1) {
			$iod = $this->Model->index_of_discrimination_perclass($_POST['classid']);
			//echo $iod;
		} else {
			$iod = $this->Model->whole_index_of_discrimination("", $_POST['courseid']);
		}
		echo json_encode($iod);
	}
	
	public function course_ajax(){
		//$elijah = array('a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5);
		echo json_encode($this->Model->change_course_ajax($_POST['courseid']));
		//echo json_encode($elijah);
	}
	
	public function acadterm_ajax(){
		echo json_encode($this->Model->change_acadtermrange_ajax($_POST['courseid'], $_POST['startsem'], $_POST['startyear'], $_POST['endsem'], $_POST['endyear']));
	}
	
	public function instructor_ajax(){
		echo json_encode($this->Model->change_instructor_ajax($_POST['courseid'], $_POST['startsem'], $_POST['startyear'], $_POST['endsem'], $_POST['endyear'], $_POST['instructorid']));
	}
	
	public function stat($tag = null) {
		$stat = $this->Model->results_chart($_POST['classid'], $_POST['courseid']);
		$stat2 = $this->Model->get_total_and_percentage($_POST['classid'], $_POST['courseid']);
		
		$dropdown = $this->Model->dropdown_info();
		$section_info = $this->Model->section_info();
		$year_info = $this->Model->get_years();
		$instructor_info = $this->Model->instructor_info();
		$selected = $this->session->userdata('coursestat');
		$classid = $_POST['classid'];
		$courseid = $_POST['courseid'];
		$course = $_POST['course'];
		$section1 = ($_POST['section'] == "") ? "Overall" : $_POST['section'];
		
		//echo "Classlist format:<br/>";
		if($classid != null) $classlist = $this->Model->get_classlist($classid);
		else $classlist = null;
		//print_r($try);
		//die();
		
		$ayterm = $_POST['ayterm'];
		$this->load_view('stat_view', compact('classlist','tag','course', 'section1', 'ayterm', 'classid','courseid','stat', 'stat2', 'selected', 'dropdown','section_info', 'year_info', 'instructor_info'));
	}

	public function generate_csv() {
		$temp = $this->Model->make_csv($_POST['csv_classid'], $_POST['csv_courseid']);
		
		if($_POST['csv_classid'] != null) $temp2 = $this->Model->get_classname($_POST['csv_classid']);
		else{ 
			$temp2['coursename'] = $this->Model->get_coursename($_POST['csv_courseid']);
			$temp2['section'] = "<>";
			$temp2['termid'] = "<>";
		}
		
		$add = "\"Index of Discrimination\", ".$_POST['csv_iod'].",\n\"Passing Rate\",\"".$_POST['csv_passingrate']."\",\n\n";
		header("Content-type: text/csv");
		$name = str_replace(' ', '', $temp2['coursename']);
		header("Content-Disposition: attachment; filename=".$name."_".$temp2['section']."_".$temp2['termid'].".csv");
		header("Content-length:". strlen($temp));
		
		echo $add.$temp;
		exit;
	}
	
}