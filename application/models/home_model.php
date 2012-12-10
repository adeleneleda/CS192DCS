<?
class Home_Model extends CI_Model {

    function __construct()
    {
        // Call the Model constructor
        parent::__construct();
    }
    
	function check_userdata($userdata) {
		$results = $this->db->query('SELECT * FROM users WHERE username="'.$userdata['login'].'" AND password="'.substr(md5($userdata['password']),0,20).'";');
		
		if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			return $temp[0];
		}
		return false;
	}
	
	function get_details($userid) {
		$results = $this->db->query('SELECT * FROM proponent JOIN updesignation USING(updesignation_id) WHERE user_id='. $userid .';');
		
		if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			return $temp[0];
		}
		return false;
	}
	
	function get_loginerror($userdata) {
		$results = $this->db->query('SELECT * FROM users WHERE username="'.$userdata['login'].'";');
		
		if($results->num_rows() > 0)
		{
			return "UP Webmail and password do not match.";
		}
		return "Invalid UP Webmail account.";
	}
	
	function get_userroles($userid) {
		$results = $this->db->query('SELECT usertype FROM user_roles WHERE user_id='.$userid.';');
		if($results->num_rows() > 0)
		{
			$temp = $results->result_array();
			return $temp;
		}
		return false;
	}
	
	function get_approved_proposal_titles() {
		$results = $this->db->query('SELECT proposal_id, title, date(status_date) as status_date, abstract FROM proposals WHERE status = "APPROVED";');
		$results = $results->result_array();
		return $results;
	}
	
	function get_authors($proposal_id) {
		$results = $this->db->query('SELECT proposal_id, lastname, firstname, middlename FROM proponent JOIN proposes USING (proponent_id) WHERE proposal_id  = '.$proposal_id.';');
		$results = $results->result_array();
		return $results;
	
	}
	
	function get_years() {
		$results = $this->db->query('SELECT DISTINCT extract(year from status_date) as year from proposals where status = "APPROVED";');
		$results = $results->result_array();
		return $results;	
	}
	
	function proponent_search($proponent) {
	
	$query_long = "SELECT proponent_id, lastname, firstname, middlename from proponent p1
	where (concat_ws(' ', firstname, middlename, lastname) like '%".$proponent."%' OR
	concat_ws(' ', middlename, firstname, lastname) like '%".$proponent."%' OR
	concat_ws(' ', lastname, middlename, firstname) like '%".$proponent."%' OR
	concat_ws(' ', middlename, lastname, firstname) like '%".$proponent."%' OR
	concat_ws(' ', firstname, lastname, middlename) like '%".$proponent."%' OR
	concat_ws(' ', lastname, firstname, middlename) like '%".$proponent."%' )
	AND EXISTS (select proposal_id from proposes p2 join proposals using (proposal_id) where p1.proponent_id = p2.proponent_id and status = 'APPROVED');";
	
	
	$results = $this->db->query($query_long);
	$results = $results->result_array();
	return $results;


	
	
	}
	
	function search_all($proponent, $year, $keyword) {
	

	
	
	$query_long = "SELECT proposal_id, title, status_date from proposals join proposes using (proposal_id) join proponent using (proponent_id) where
	proponent_id in 
	(SELECT proponent_id from proponent p1
	where (concat_ws(' ', firstname, middlename, lastname) like '%".$proponent."%' OR
	concat_ws(' ', middlename, firstname, lastname) like '%".$proponent."%' OR
	concat_ws(' ', lastname, middlename, firstname) like '%".$proponent."%' OR
	concat_ws(' ', middlename, lastname, firstname) like '%".$proponent."%' OR
	concat_ws(' ', firstname, lastname, middlename) like '%".$proponent."%' OR
	concat_ws(' ', lastname, firstname, middlename) like '$".$proponent."%' )
	AND EXISTS (select proposal_id from proposes p2 join proposals using (proposal_id) where p1.proponent_id = p2.proponent_id and status = 'APPROVED')
	)
	
	AND 
	
	extract(year from status_date) like '%".$year."%'
	
	AND
	
	(title like '%".$keyword."%' OR abstract like '%".$keyword."%');";
	
	
	$results = $this->db->query($query_long);
	$results = $results->result_array();
	return $results;	
	
	
	}
	
	function search_proponent($proponent_id, $year, $keyword) {
	

	
	
	$query_long = "SELECT proposal_id, title, status_date from proposals join proposes using (proposal_id) join proponent using (proponent_id) where
	proponent_id = ".$proponent_id."	AND 
	
	extract(year from status_date) like '%".$year."%'
	
	AND
	
	(title like '%".$keyword."%' OR abstract like '%".$keyword."%');";
	
	
	$results = $this->db->query($query_long);
	$results = $results->result_array();
	return $results;	
	
	
	}
	
	function get_info($proposal_id) {
	$query_long = "SELECT title, abstract, date(status_date) as status_date from proposals where proposal_id = ".$proposal_id.";";
	$results = $this->db->query($query_long);
	$results = $results->result_array();
	return $results;	
	
	
	}
	
	
}