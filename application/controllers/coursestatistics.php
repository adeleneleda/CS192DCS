<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Coursestatistics extends Main_Controller {	

	public function __construct() {
		echo "aaa";
		parent::__construct(true);
		echo "aaa";
		$this->load->model('Coursestatistics_Model', 'Model');
		echo "aaa";
	}
	
	
   public function index()
	{
	$this->Model->search();
    $this->load_view('frontpage');
	}
	
	public function search() {
	
	
	
	}
	
	public function view_Statistics() {
	
	}
   
}

