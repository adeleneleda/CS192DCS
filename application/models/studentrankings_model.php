<?
class StudentRankings_Model extends CI_Model {

    function __construct()
    {
        // Call the Model constructor
        parent::__construct();
    }
    
    function get_students() {
        $results = $this->db->query('SELECT lastname FROM persons JOIN students using (personid) where curriculumid = 1;');
		$results = $results->result_array();
        print_r($results);
		return $results;
	}
    
    function get_years()
    {
        $termresults = $this->db->query('SELECT termid FROM terms;');
        $termresults = $termresults->result_array();
        $results = array();
        $ctr = 0;
        $termctr = 0;
        for($ctr = 0; $ctr < sizeof($termresults)/3; $ctr++)
        {
            $results[$ctr] = ($termresults[$termctr]['termid']/10) - (($termresults[$termctr]['termid']%10)/10);
            $termctr = $termctr+3;
        }
        return $results;
    }
    /*
    function get_cs_gwa()
    {
        $results = $this->db->query('SELECT students.studentid, SUM(grades.gradevalue * courses.credits) / SUM(courses.credits)

                                    FROM students JOIN persons USING (personid)
                                    JOIN studentterms USING (studentid)
                                    JOIN studentclasses USING (studenttermid)
                                    JOIN grades USING (gradeid)
                                    JOIN classes USING (classid)
                                    JOIN courses USING (courseid)

                                    WHERE courses.coursename LIKE 'cs%'
                                    GROUP BY students.studentid;');
        $results = $results->result_array();
        return $results;
    }
    
    function get_math_gwa()
    {
        $results = $this->db->query('SELECT students.studentid, SUM(grades.gradevalue * courses.credits) / SUM(courses.credits)

                                    FROM students JOIN persons USING (personid)
                                    JOIN studentterms USING (studentid)
                                    JOIN studentclasses USING (studenttermid)
                                    JOIN grades USING (gradeid)
                                    JOIN classes USING (classid)
                                    JOIN courses USING (courseid)

                                    WHERE courses.coursename LIKE 'math%'
                                    GROUP BY students.studentid;');
        $results = $results->result_array();
        return $results;
    }*/
    
    function get_gwa($sem, $year)
    {
        $results = $this->db->query('SELECT DISTINCT a.lastname, a.firstname, a.middlename, gwa(a.studentid,' . $sem .'), cwaproto4(a.studentid), csgwa(a.studentid), mathgwa(a.studentid)
        FROM (SELECT lastname, firstname, middlename, studentid from viewclasses v where v.termid = ' . $sem .' AND v.studentno LIKE \''.$year.'%\') as a;');
        $results = $results->result_array();
		return $results;
    }
	
	function make_csv($sem, $year){
	$results = $this->db->query('SELECT DISTINCT a.lastname, a.firstname, a.middlename, gwa(a.studentid,' . $sem .'), cwaproto4(a.studentid), csgwa(a.studentid), mathgwa(a.studentid)
        FROM (SELECT lastname, firstname, middlename, studentid from viewclasses v where v.termid = ' . $sem .' AND v.studentno LIKE \''.$year.'%\') as a;');

		
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
    //working
    /*function get_gwa($sem)
    {
        $results = $this->db->query('SELECT persons.lastname, persons.firstname, persons.middlename, gwa(s.studentid, ' . $sem . ') as gwa
            FROM students s
            JOIN persons USING (personid)
            ORDER BY gwa ASC;');
        $results = $results->result_array();
        return $results;
    }*/
    
    
 
    
    
}