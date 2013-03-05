<?
require_once('base_model.php');
class StudentRankings_Model extends Base_Model {

    function __construct()
    {
        // Call the Model constructor
        parent::__construct();
    }
     
    function get_gwa($sem, $year)
    {
        $results = $this->db->query('SELECT DISTINCT studentno, lastname, firstname, middlename, gwa, cwa, csgwa, mathgwa
        FROM viewclasses v where v.termid = ' . $sem .' AND v.studentno LIKE \''.$year.'%\';');
        $results = $results->result_array();
		return $results;
    }
	
	function make_csv($sem, $year){
	$results = $this->db->query('SELECT a.lastname, a.firstname, a.middlename, gwa(a.studentid,' . $sem .'), xcwa69(a.studentid,' . $sem .'+1), csgwa(a.studentid), mathgwa(a.studentid)
        FROM (SELECT DISTINCT lastname, firstname, middlename, studentid from viewclasses v where v.termid = ' . $sem .' AND v.studentno LIKE \''.$year.'%\') as a;');

		
	if($results->num_rows() > 0)
		{
			$this->load->dbutil();
			$delimiter = ",";
			$newline = "\r\n";
			$temp = $this->dbutil->csv_from_result($results, $delimiter, $newline);
			
			return $temp;
		}
	return false;    
	}    
}