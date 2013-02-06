<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Updatestatistics extends Main_Controller {	

	public function __construct() {
		parent::__construct(true);	
	}
	
   public function index()
	{
	
	$this->load_view('updatestatistics_view');
		
		
	}
	
}