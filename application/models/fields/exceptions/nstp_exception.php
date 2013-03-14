<?php
class NstpException extends Exception {
	public function __construct() {
		parent::__construct("NSTP classes are not accepted");
    }
}
?>