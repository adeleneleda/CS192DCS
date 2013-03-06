<?php
require_once 'upload_query.php';
require_once 'fields/exceptions/nstp_exception.php';
require_once 'fields/exceptions/pe_exception.php';

class Gradefile_Parser extends CI_Model {
	const COLS = 12;
	protected $query;
	protected $field_parsers = array();
	protected $successcount = 0;
	protected $errorcount = 0;
	protected $row_no;
	
	//dan
	protected $affected = array();
		
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
		$this->query = new Upload_query;
		$this->load->model("Field_factory", "field_factory");
		for ($i = 0; $i < $this->cols - 2; $i++) // last 3 columns (grades) are parsed at the same time
			$this->field_parsers[] = $this->field_factory->createFieldByNum($i);
		$this->row_no = 0;
	}
	
	private function headerRowHtml() {
		$output = "<tr><th>row</th>";
		$headers = $this->nextRow();
		$cols = count($headers) - 2; // last 2 fields are also grades
		for ($i = 0; $i < $cols; $i++)
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
			//$this->query->execute(); commented out by Dan
			//Dan
			$studenttermid = $this->query->execute();
			if($studenttermid > -1)
				$affected[] = $studenttermid;
		}
		$affected = array_unique($affected);
		//start Dan's precomputing
		//can I please have also a loading bar? :)) Gusto ko nakasulat "Precomputing metrics..." para pogi ahahahahaha
		foreach($affected as $studenttermid) {
            $update1 = $this->db->query('UPDATE studentterms SET cwa = xcwa69(' . $studenttermid . ') WHERE studenttermid = ' . $studenttermid . ';');
            $update2 = $this->db->query('UPDATE studentterms SET gwa = gwa(' . $studenttermid . ') WHERE studenttermid = ' . $studenttermid .';');
			$update3 = $this->db->query('UPDATE studentterms SET csgwa = csgwa(' . $studenttermid . ') WHERE studenttermid = ' . $studenttermid .';');
			$update4 = $this->db->query('UPDATE studentterms SET mathgwa = mathgwa(' . $studenttermid . ') WHERE studenttermid = ' . $studenttermid .';');
        }
		
		//end Dan's precomputing
		
		$output .= "</table>";
		return $output;
	}
	
	private function parseRow($row) {
		$success = true;
		$error = true;
		$output = "<tr><th>".$this->row_no."</th>";
		if (count($row) < self::COLS) { // invalid column count
			$this->query->doNotExecute();
			return $output."<td colspan='10' title='Invalid column count' class='databasecell upload_error'><center>Invalid column count</center></td>";
		}
		
		for ($col = 0; $col < $this->cols - 2; $col++) { // last 3 columns (grades) are parsed at the same time
			$value = $row[$col];
			$orig_value = $value;
			try {
				$field = $this->field_parsers[$col];
				if ($col == $this->cols - 3) { // grades : include comp and secondcomp
					$compgrade = $row[$col + 1];
					$secondcompgrade = $row[$col + 2];
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
