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
        //$results = $this->db->query('select true');
        print_r($results);
		return $results;
	}
    
    function get_true()
    {
        $results = $this->db->query('select true;');
        $results = $results->result_array();
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
    
    function get_gwa($sem)
    {
        $results = $this->db->query('SELECT DISTINCT a.lastname, a.firstname, a.middlename, gwa(a.studentid,' . $sem .'), cwaproto3(a.studentid), csgwa(a.studentid)
FROM (SELECT lastname, firstname, middlename, studentid from viewclasses v where v.termid = ' . $sem .') as a;');
        $results = $results->result_array();
        return $results;
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