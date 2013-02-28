<?php
class PeException extends Exception {
	public function __construct() {
		parent::__construct("PE classes are not accepted");
    }
}
?>