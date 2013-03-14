<?
require_once('base_model.php');
class StudentRankings_Model extends Base_Model {

    function __construct()
    {
        // Call the Model constructor
        parent::__construct();
    }
	
	public function recomputeStanding($studenttermid) {
		$update1 = $this->db->query('UPDATE studentterms SET cwa = xcwa69(' . $studenttermid . ') WHERE studenttermid = ' . $studenttermid . ';');
		$update2 = $this->db->query('UPDATE studentterms SET gwa = gwa(' . $studenttermid . ') WHERE studenttermid = ' . $studenttermid .';');
		$update3 = $this->db->query('UPDATE studentterms SET csgwa = csgwa(' . $studenttermid . ') WHERE studenttermid = ' . $studenttermid .';');
		$update4 = $this->db->query('UPDATE studentterms SET mathgwa = mathgwa(' . $studenttermid . ') WHERE studenttermid = ' . $studenttermid .';');
	}
     
    function get_gwa($sem, $year)
    {
		// old query
        // $results = $this->db->query('SELECT DISTINCT studentno, lastname, firstname, middlename, gwa, cwa, csgwa, mathgwa
        // FROM viewclasses v where v.termid = ' . $sem .' AND v.studentno LIKE \''.$year.'%\';');
		
		$results = $this->db->query('SELECT studentno, lastname, firstname, middlename, gwa, cwa, csgwa, mathgwa
        FROM students JOIN persons USING (personid) JOIN studentterms USING (studentid) WHERE termid = ' . $sem .' AND studentno LIKE \''.$year.'%\';');
        $results = $results->result_array();
		return $results;
    }
	
	function make_csv($sem, $year){
	//results = $this->db->query('SELECT a.lastname, a.firstname, a.middlename, gwa(a.studentid,' . $sem .'), xcwa69(a.studentid,' . $sem .'+1), csgwa(a.studentid), mathgwa(a.studentid)
      //  FROM (SELECT DISTINCT lastname, firstname, middlename, studentid from viewclasses v where v.termid = ' . $sem .' AND v.studentno LIKE \''.$year.'%\') as a;');
		
		$results = $this->db->query('SELECT studentno, lastname, firstname, middlename, gwa, cwa, csgwa, mathgwa
        FROM students JOIN persons USING (personid) JOIN studentterms USING (studentid) WHERE termid = ' . $sem .' AND studentno LIKE \''.$year.'%\';');
		
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