<?php
require_once 'gradefile_parser.php';

class Csv_Parser extends Gradefile_Parser {
	private $csvfile;
	const MAX_LINE_LENGTH = 1000;
	
	protected function nextRow() {
		++$this->row_no;
		return fgetcsv($this->csvfile, self::MAX_LINE_LENGTH, ",");
	}
	
	private function rewind() {
		rewind($this->csvfile); // return file pointer to start
		$this->row_no = 1;
	}
	
	public function initialize($csv_filename) {
		ini_set('auto_detect_line_endings', true);
		if (($this->csvfile = fopen($csv_filename, "r")) === FALSE)
			throw new Exception($csv_filename." could not be opened for reading");
		parent::initialize();
	}
}
?>