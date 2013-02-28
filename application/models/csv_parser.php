<?php
require_once 'excel_query.php';
require_once 'fields/exceptions/nstp_exception.php';
require_once 'fields/exceptions/pe_exception.php';

class Csv_Parser extends CI_Model {
	private $query;
	private $field_parsers = array();
	private $csvfile;
	private $successcount = 0;
	private $errorcount = 0;
		
	function __construct() {
        parent::__construct();
    }
	
	public function getErrorCount() {
		// return 1;
		return $this->errorcount;
	}
	
	public function getSuccessCount() {
		return $this->successcount;
	}
	
	/** 
		$csvfile - the filename of the input csv file to be parsed
	*/
	public function initialize($csv_filename) {
		$this->load->model('excel_query', 'query');
		if (($this->csvfile = fopen($csv_filename, "r")) === FALSE)
			throw new Exception($csv_filename." could not be opened for reading");
		
		$this->load->model("Field_factory", "field_factory");
	}
	
	/** Start parsing $this->csvfile. */
	public function parse() {
		$output = "<table class='databasetable'>";
		// If 1st row is not a header, change to $i = 1
		$output .= "<tr><th>row</th>";
		if ($row = fgetcsv($this->csvfile, 1000, ",")) { // read a line
			$cols = count($row);
			for ($i = 0; $i < $cols - 2; $i++) {
				$this->field_parsers[] = $this->field_factory->createFieldByNum($i + 1);
				$output .= '<th>'.$row[$i].'</th>';
			}
		}
		$output .= "</tr>";
		
		$line_number = 1;
		while (($row = fgetcsv($this->csvfile, 1000, ",")) !== FALSE) {
			$line_number++;
			$this->query = new Excel_query;
			$output .= $this->parseRow($row, $line_number, $cols);
			$this->query->execute();
		}
		$output .= "</table>";
		return $output;
	}
	
	private function parseRow($row, $line_number, $header_col_count) {
		$success = true;
		$error = true;
		$output = "<tr><th>".$line_number."</th>";
		$cols = count($row);
		if ($cols !== $header_col_count) {
			$output .= "Inconsitent number of fields in line ".$line_number;
			$this->errorcount++;
			return $output;
		}
		for ($i = 0; $i < $cols - 2; $i++) { // last 3 columns (grades) are parsed at the same time
			$value = $row[$i];
			$orig_value = $value;
			try {
				$field = $this->field_parsers[$i];
				if ($i == $cols - 3) { // grades : include comp and secondcomp
					$compgrade = $row[$i + 1];
					$secondcompgrade = $row[$i + 2];
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
				$output .= "<td title='$message'><div class='databasecell upload_error'>$orig_value</div></td>";
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
