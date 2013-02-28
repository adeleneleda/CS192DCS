<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Updatestatistics extends CI_Controller {
	private $headers_included = false;
	
	public function __construct() {
		parent::__construct();
		
		//load model
		$this->load->model('student_model', 'student_model', true);
	}
	
	public function index() {
		$this->headers_included = true;
		$this->load->view('include/header');
		$this->load->view('include/header-teamc');
		$this->displayUploadFileView();
		$this->load->view('include/footer-teamc');
		$this->load->view('include/footer');
	}
	
	/*-----------------------------------------------------start edit functions-----------------------------------------------------*/
	
	public function edit() {
		$this->editStudents();
	}
	
	public function editStudents(){
		$data['students'] = $this->student_model->getStudents();
		$this->displayView('edit_students', $data);
	}
	
	public function editGrades($personid = null) {
		$this->load->model('grades_model', 'grades_model', true);
		
		$data['student_info'] = $this->grades_model->getStudentInfo($personid);
		$data['term_grades'] = $this->grades_model->getGrades($personid);
		$this->displayView('edit_grades', $data);
	}
	
	public function updateGrade() {
		$studentclassid = $_POST['studentclassid'];
		$grade = $_POST['grade'];
		
		try {
			$this->load->model('Field_factory', 'field_factory');
			$field = $this->field_factory->createFieldByName('Grade');
			$field->parse($grade, '', ''); //will throw an exception if grade format is wrong
			
			$this->load->model('grades_model', 'grades_model', true);
			$this->grades_model->changeGrade($grade, $studentclassid);
			echo "true";
		} catch (Exception $e) {
			echo $e->getMessage();
		}
	}//end update grade
	
	public function updateStudentInfo(){
		$changedfield_name = $_POST['changedfield_name'];
		$changedfield_value = $_POST['changedfield_value'];
		$personid = $_POST['personid'];
		
		try {
			$this->load->model('Field_factory', 'field_factory');
			$field = $this->field_factory->createFieldByName($changedfield_name);
			$field->parse($changedfield_value); //will throw an exception if grade format is wrong
			
			$this->student_model->changeStudentInfo($changedfield_name, $changedfield_value, $personid);
			echo "true";
		} catch (Exception $e) {
			echo $e->getMessage();
		}
	}//end update student info
	
	/*-----------------------------------------------------end edit functions-----------------------------------------------------*/
	
	/*-----------------------------------------------------start upload functions-----------------------------------------------------*/
	
	public function upload() {
		$this->displayUploadFileView();
	}
	
	private function getUploadsFolder() {
		$upload_dir = "./assets/uploads";
		if (!file_exists($upload_dir))
			mkdir($upload_dir, 0755);
		return $upload_dir;
	}
	
	private function getAbsoluteBasePath() {
		$base_url = explode('/', base_url(''), 4);
		return $_SERVER['DOCUMENT_ROOT'].'/'.$base_url[3];
	}
	
	private function dumpExcelTable($file) {
		$reader_file = './application/models/excel_reader.php';
		require_once $reader_file;
		
		// dump the input excel file
		$printer = new Spreadsheet_Excel_Reader($file);
		//$excel_dump = @$printer->dump(true,true);
		//return $excel_dump;
	}
	
	private function parse($file, &$data) {
		$this->load->model('excel_parser', 'parser');
		$this->parser->initialize($file);
		$data['parse_output'] = $this->parser->parse();
		$success_rows = $this->parser->getSuccessCount();
		$error_rows = $this->parser->getErrorCount();
		$data['success_rows'] = $success_rows;
		$data['error_rows'] = $error_rows;
	}
	
	private function displayUploadFileView($data = null)  {
		$data['message'] = 'Select the xls file with grades to be uploaded';
		$data['upload_filetype'] = "Grade File";
		$data['upload_header'] = "Grade Uploads";
		$data['dest'] = site_url('updatestatistics/performUpload');
		$this->load->view('upload_file', $data);
	}
	
	private function getUploadedFile() {
		$filename = $_FILES['upload_file']['name'];
		$filetype = $_FILES['upload_file']['type'];
		$filesize = $_FILES['upload_file']['size'];
		
		// customize filename for ease of access?
		// check for filetypes that are allowed?
		$target = $this->getUploadsFolder().'/'.$filename;
		if (move_uploaded_file($_FILES['upload_file']['tmp_name'], $target)) {
			return $target;
		} else
			throw new Exception("Error: $filename could not be uploaded.");
	}

	// Called when an excel file is uploaded
	public function performUpload() {
		$data = array('upload_success' => false);
		$data['reset_success'] = $this->resetIfChecked();
		// maintain a table to store uploaded gradessheets?
		try {
			$file = $this->getUploadedFile();
			$data['excel_dump'] = $this->dumpExcelTable($file);
			$data['upload_success'] = true;
			$this->parse($file, $data);
		} catch (Exception $e) {
			$data['error_message'] = $e->getMessage();
		}
		$this->displayViewWithHeaders('upload_response', $data);
	}
	
	/*-----------------------------------------------------end upload functions-----------------------------------------------------*/
	
	/*-----------------------------------------------------start reset functions-----------------------------------------------------*/
	
	private function resetDatabase(){
		$query = "TRUNCATE studentclasses, studentterms, instructorclasses, instructors, classes, students, persons";
		$this->db->query($query);
	}
	
	private function resetIfChecked() {
		if(isset($_POST['reset']) && $_POST['reset']) {
			$this->resetDatabase();
			return true;
		}
		else
			return false;
	}
	
	/*-----------------------------------------------------end reset functions-----------------------------------------------------*/
	
	/*-----------------------------------------------------start backup functions-----------------------------------------------------*/
	
	public function backup() {
		$cookie = $this->input->cookie('pg_bin_dir', TRUE);
		if (isset($_POST['pg_bin_dir'])) {
			$pg_bin_dir = $_POST['pg_bin_dir'];
			if (!preg_match("/bin$/", $pg_bin_dir))
				$pg_bin_dir .= "/bin";
			$this->performBackup($pg_bin_dir);
		}
		else if (!empty($cookie))
			$this->performBackup($cookie);
		else if (substr(php_uname(), 0, 7) == "Windows") {
			$data['dest'] = 'updatestatistics/backup';
			$this->displayView('postgres_bin', $data);
		}
		else
			$this->performBackup('/usr/bin');
	}
	
	private function performBackup($pg_bin_dir) {
		$pg_dump = $pg_bin_dir."/pg_dump";
		if (substr(php_uname(), 0, 7) == "Windows")
			$pg_dump .= ".exe";
		$backup_dir = $this->getAbsoluteBasePath().'dumps/';
		if (!file_exists($backup_dir))
			mkdir($backup_dir, 0755);
		$backup_name = $backup_dir.$this->db->database.date("m-d-Y_h-i-s").".sql";
		$cmd = escapeshellarg($pg_dump)." -U postgres ".$this->db->database." > $backup_name 2>&1";
		exec($cmd, $output, $status);
		$success = ($status == 0);
		if ($success) { // save cookie
			$cookie = array('name'=>'pg_bin_dir', 'value'=>$pg_bin_dir, 'expire'=>'1000000');
			$this->input->set_cookie($cookie);
		}
		$data['backup_location'] = $backup_name;
		$data['output'] = $output;
		$data['success'] = $success;
		$this->displayView('backup_response', $data);
	}
	
	/*-----------------------------------------------------end backup functions-----------------------------------------------------*/
	
	/*-----------------------------------------------------start restore functions-----------------------------------------------------*/
	public function restore() {
		$cookie = $this->input->cookie('pg_bin_dir', TRUE);
		if (isset($_POST['pg_bin_dir'])) {
			$pg_bin_dir = $_POST['pg_bin_dir'];
			if (!preg_match("/bin$/", $pg_bin_dir))
				$pg_bin_dir .= "/bin";
			$this->showRestoreDialog($pg_bin_dir);
		}
		else if (!empty($cookie))
			$this->showRestoreDialog($cookie);
		else if (substr(php_uname(), 0, 7) == "Windows") {
			$data['dest'] = 'updatestatistics/restore';
			$this->displayView('postgres_bin', $data);
		}
		else
			$this->showRestoreDialog('/usr/bin');
	}
			
	private function showRestoreDialog($pg_bin_dir) {
		$data['message'] = 'Select the database backup to restore';
		$data['upload_header'] = "Database Restore";
		$data['upload_filetype'] = "Back-Up File";
		$data['dest'] = site_url('updatestatistics/performRestore');
		$data['pg_bin_dir'] = $pg_bin_dir;
		$this->displayView('upload_file', $data);
	}
	
	public function performRestore() {
		$pg_bin_dir = $_POST['pg_bin_dir'];
		
		$data['reset_success'] = $this->resetIfChecked();
		try {
			$backup_filename = $this->getAbsoluteBasePath().$this->getUploadedFile();
			if (substr(php_uname(), 0, 7) == "Windows"){
				$abs_basepath = $this->getAbsoluteBasePath();
				$psql_location = $pg_bin_dir."/psql.exe";
			} 
			else { 
				$psql_location = $pg_bin_dir."/psql";
			}
			$cmd = escapeshellarg($psql_location)." -U postgres ".$this->db->database." < $backup_filename 2>&1";
			exec($cmd, $output, $status);
			$success = ($status == 0);
			if ($success) { // save cookie
				$cookie = array('name'=>'pg_bin_dir', 'value'=>$pg_bin_dir, 'expire'=>'1000000');
				$this->input->set_cookie($cookie);
			}
			$data['output'] = $output;
			$data['restore_success'] = $success;
		} catch (Exception $e) {
			$data['output'] = array();
			$data['restore_success'] = false;
		}
		$this->displayViewWithHeaders('restore_response', $data);
	}
	
	/*-----------------------------------------------------end restore functions-----------------------------------------------------*/
	
	/*-----------------------------------------------------start sql functions-----------------------------------------------------*/
	
	public function sql() {
		$data['message'] = 'Select the sql file to run';
		$data['upload_filetype'] = "SQL File";
		$data['upload_header'] = "Execute SQL";
		$data['dest'] = site_url('updatestatistics/performSqlQuery');
		$this->displayView('upload_file', $data);
	}
	
	public function performSqlQuery() {
		$this->resetIfChecked();
		$sql_file = $this->getUploadedFile();
		$sql_text = $this->load->file($sql_file, true);
		$this->db->query($sql_text);
		$data['success'] = true;
		$this->displayViewWithHeaders('sql_response', $data);
	}
	
	/*-----------------------------------------------------end sql functions-----------------------------------------------------*/
	
	private function saveAsDialog($saveas_filename) {
		header ("Content-Type: application/download");
		header ("Content-Disposition: attachment; filename=$saveas_filename");
		header ("Content-Length: " . filesize("$saveas_filename"));
		$fp = fopen("$saveas_filename", "r");
		fpassthru($fp);
	}
	
	private function getResetSql(){
		$filename = "Create Tables.sql";
		$upload_dir = "./db files";
		if (!file_exists($upload_dir))
			mkdir($upload_dir, 0755);

		$target = $upload_dir.'/'.$filename;
		return $target;
	}
	
	/*-----------------------------------------------------start display functions-----------------------------------------------------*/
	
	private function displayViewWithHeaders($viewname, $data = null) {
		$this->headers_included = true;
		$this->load->view('include/header');
		$this->load->view('include/header-teamc');
		$this->load->view($viewname, $data);
		$this->load->view('include/footer-teamc');
		$this->load->view('include/footer');
	}
	
	private function displayView($viewname, $data = null) {
		// if ($this->headers_included)
			$this->load->view($viewname, $data);
		// else
			// $this->displayViewWithHeaders($viewname, $data);
	}
	
	/*-----------------------------------------------------end display functions-------------------------------------------------*/
}

/* Location: ./application/controllers/updatestatistics.php */
