<?php
require_once 'excel_reader.php';
require_once 'gradefile_parser.php';

class Xls_Parser extends Gradefile_Parser {
	private $xlsfile;
	private $rows;
	
	public function initialize($xls_filename) {
		$this->xlsfile = new Spreadsheet_Excel_Reader($xls_filename, false);
		$this->rows = $this->xlsfile->rowcount();
		parent::initialize();
	}
	
	protected function nextRow() {
		++$this->row_no;
		if ($this->row_no > $this->rows)
			return false;
		$row = array();
		for ($i = 0; $i < self::COLS; $i++)
			$row[] = $this->xlsfile->val($this->row_no, $i + 1);
		return $row;
	}
}
?>
