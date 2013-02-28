<?php
abstract class Field extends CI_Model {
	protected $values = array();
	
	public function __contruct() {
		parent::__construct();
	}
	
	public abstract function parse(&$value1, $value2, $value3);
	
	public final function insertToQuery(&$query) {
		foreach ($this->values as $key => $value)
			$query->$key = $value;
	}
}
?>