<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class About extends Main_Controller {	

	public function __construct() {
		parent::__construct(true);
		$this->load->model('About_Model', 'Model');
	}
	
	
   public function index()
	{	
    $this->load_view('about_view');
	}
}

