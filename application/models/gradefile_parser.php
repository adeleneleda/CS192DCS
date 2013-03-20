<?php
require_once 'upload_query.php';
require_once 'fields/exceptions/nstp_exception.php';
require_once 'fields/exceptions/pe_exception.php';

class Gradefile_Parser extends CI_Model {
	const COLS = 13;
	protected $query;
	protected $field_parsers = array();
	protected $successcount = 0;
	protected $errorcount = 0;
	protected $row_no;
	protected $affected;
		
	function __construct() {
        parent::__construct();
    }
	
	public function getErrorCount() {
		return $this->errorcount;
	}
	
	public function getSuccessCount() {
		return $this->successcount;
	}
	
	public function initialize() {
		$this->affected = array();
		$this->query = new Upload_query;
		$this->load->model("Field_factory", "field_factory");
		for ($i = 0; $i < self::COLS; $i++)
			$this->field_parsers[] = $this->field_factory->createFieldByNum($i);
		$this->row_no = 0;
	}
	
	private function headerRowHtml() {
		$output = "<tr><th>row</th>";
		$headers = $this->nextRow();
		$headers = array('Acad year','Sem','Student #','Last name','First name','Middle name','Pedigree','Classcode','Class','Grade','Instructor');
		for ($i = 0; $i < self::COLS - 2; $i++)
			$output .= '<th>'.$headers[$i].'</th>';
		$output .= "</tr>";
		return $output;
	}
	
	public function parse() {
		$output = "<table class='databasetable'>";
		$output .= $this->headerRowHtml();
		while ($row = $this->nextRow()) {
			$this->query->toBeExecuted();
			$output .= $this->parseRow($row);
			$affected_ids = $this->query->execute();
			if($affected_ids != null) {
				$this->affected['studenttermid'][] = $affected_ids['studenttermid'];
				$this->affected['studentid'][] = $affected_ids['studentid'];
			}
		}
		$this->load->model('studentrankings_model', 'studentrankings_model', true);		
		$this->affected['studenttermid'] = array_unique($this->affected['studenttermid']);
		foreach($this->affected['studenttermid'] as $studenttermid)
			$this->studentrankings_model->recomputeStanding($studenttermid);
			
		$this->load->model('eligibilitytesting_model', 'eligibilitytesting_model', true);
		$this->affected['studentid'] = array_unique($this->affected['studentid']);
		foreach($this->affected['studentid'] as $studentid)
			$this->eligibilitytesting_model->postprocessing_bystudent($studentid);
		
		$output .= "</table>";
		return $output;
	}
	
	private function parseRow($row) {
		$success = true;
		$error = true;
		$output = "<tr><th>".$this->row_no."</th>";
		if (count($row) < self::COLS) { // invalid column count
			$diff = self::COLS - count($row);
			for ($i = 0; $i < $diff; $i++)
				$row[] = ''; // blank out the rest
		}
		for ($col = 0; $col < self::COLS; $col++) {
			$value = $row[$col];
			$orig_value = $value;
			if ($col == 10 || $col == 11)
				continue; // comp and secondcomp grades: skip
			else try {
				$field = $this->field_parsers[$col];
				if ($col == 9) { // grades : include comp and secondcomp
					$compgrade = $row[10];
					$secondcompgrade = $row[11];
					$field->parse($value, $compgrade, $secondcompgrade);
				}
				else
					$field->parse($value);
				$field->insertToQuery($this->query);
				$output .= "<td class='databasecell'>$value</td>";
			} catch (NstpException $e) {
				$this->query->doNotExecute();
				$success = false;
				$error = false;
			} catch (PeException $e) {
				$this->query->doNotExecute();
				$success = false;
				$error = false;
			}
			catch (Exception $e) {
				$this->query->doNotExecute();
				$message = $e->getMessage(); // store for tooltip message
				$output .= "<td title='$message' class='databasecell upload_error'>$orig_value</td>";
				$success = false;
			}
		}
		$output .= "</tr>";
		if ($success) {
			$this->successcount++;
			return ''; // don't print the row
		}
		else if ($error) {
			$this->errorcount++;
			return $output; // add row for printing;
		}
		else { // neither success nor error (NSTP/PE)
			return '';
		}
	}
}
?>