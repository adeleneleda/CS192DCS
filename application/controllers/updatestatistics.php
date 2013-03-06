<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Updatestatistics extends CI_Controller {
	private $headers_included = false;
	
	public function __construct() {
		parent::__construct();
		
		$this->load->model('student_model', 'student_model', true);
	}
	
	public function index() {
		$this->displayViewWithHeaders('upload_file', $this->uploadFileViewData());
	}
	
	/*-----------------------------------------------------start edit functions-----------------------------------------------------*/
	
	public function edit() {
		$this->editStudents();
	}
	
	public function editStudents(){
		$data['students'] = $this->student_model->getStudents();
		$this->displayView('edit_students', $data);
	}
	
	public function updateStudentInfo(){
		$changedfield_name = $_POST['changedfield_name'];
		$changedfield_value = $_POST['changedfield_value'];
		$personid = $_POST['personid'];
		
		try {
			$this->load->model('Field_factory', 'field_factory');
			$field = $this->field_factory->createFieldByName($changedfield_name);
			$field->parse($changedfield_value);
			$this->student_model->changeStudentInfo($changedfield_name, $changedfield_value, $personid);
			echo "true";
		} catch (Exception $e) {
			echo $e->getMessage();
		}
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
	}
	
	/*-----------------------------------------------------end edit functions-----------------------------------------------------*/
	
	/*-----------------------------------------------------start upload functions-----------------------------------------------------*/
	
	public function upload() {
		$this->load->view('upload_file', $this->uploadFileViewData());
	}
	
	private function uploadFileViewData()  {
		$data = array();
		$data['message'] = 'Select the XLS or CSV file with grades to be uploaded';
		$data['upload_filetype'] = "Grade File";
		$data['upload_header'] = "Grade Uploads";
		$data['dest'] = site_url('updatestatistics/performUpload');
		return $data;
	}

	// Called when a grades file is uploaded
	public function performUpload() {
		$data = array('upload_success' => false);
		$data['reset_success'] = $this->resetIfChecked();
		// maintain a table to store uploaded gradessheets?
		try {
			$filename = $this->getUploadedFile();
			$data['upload_success'] = true;
			$parse_data = $this->parse($filename);
			$data = array_merge($data, $parse_data);
		} catch (Exception $e) {
			$data['error_message'] = $e->getMessage();
		}
		$this->displayViewWithHeaders('upload_response', $data);
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
	
	private function parse($filename) {
		try {
			return $this->tryToParseUsing('xls_parser', $filename);
		} catch (Exception $e) {
			return $this->tryToParseUsing('csv_parser', $filename);
		}
	}
	
	private function tryToParseUsing($parser_classname, $filename) {
		$data = array();
		$this->load->model($parser_classname, '', true);
		$this->$parser_classname->initialize($filename);
		$data['parse_output'] = $this->$parser_classname->parse();
		$data['success_rows'] = $this->$parser_classname->getSuccessCount();
		$data['error_rows'] = $this->$parser_classname->getErrorCount();
		return $data;
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
	
	/*-----------------------------------------------------start folder functions-----------------------------------------------------*/
	
	private function getUploadsFolder() {
		$upload_dir = "./assets/uploads";
		$this->createFolderIfNotExists($upload_dir);
		return $upload_dir;
	}
	
	private function getDumpsFolder() {
		$dumps_dir = $this->getAbsoluteBasePath().'dumps/';
		$this->createFolderIfNotExists($dumps_dir);
		return $dumps_dir;
	}
	
	private function createFolderIfNotExists($folder_name) {
		if (!file_exists($folder_name))
			mkdir($folder_name, 0755);
	}
	
	private function getAbsoluteBasePath() {
		$base_url = explode('/', base_url(''), 4);
		return $_SERVER['DOCUMENT_ROOT'].'/'.$base_url[3];
	}
	
	/*-----------------------------------------------------end folder functions-----------------------------------------------------*/
	
	/*-----------------------------------------------------start backup functions-----------------------------------------------------*/
	
	public function backup() {
		$cookie = $this->input->cookie('pg_bin_dir', TRUE);
		if (isset($_POST['pg_bin_dir'])) {
			$pg_bin_dir = $_POST['pg_bin_dir'];
			if (!preg_match("@bin[\\\/]?$@", $pg_bin_dir))
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
		$backup_dir = $this->getDumpsFolder();
		ini_set('date.timezone', 'Asia/Manila');
		$backup_name = $backup_dir.$this->db->database.'--'.date("Y-m-d--H-i-s").".sql";
		$cmd = escapeshellarg($pg_dump)." -U postgres --clean --inserts -f $backup_name ".$this->db->database." 2>&1";
		putenv("PGPASSWORD=".$this->db->password);
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
			if (!preg_match("@bin[\\\/]?$@", $pg_bin_dir))
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
			$backup_filename = escapeshellarg($backup_filename);
			if (substr(php_uname(), 0, 7) == "Windows")
				$psql_location = $pg_bin_dir."/psql.exe";
			else
				$psql_location = $pg_bin_dir."/psql";
			$cmd = escapeshellarg($psql_location)." -U postgres -f $backup_filename ".$this->db->database." 2>&1";
			putenv("PGPASSWORD=".$this->db->password);
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
	
	/*-----------------------------------------------------start display functions-----------------------------------------------------*/
	
	private function displayViewWithHeaders($viewname, $data = null) {
		$update_statistics = array('update_statistics' => '');
		$this->load->view('include/header', $update_statistics);
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