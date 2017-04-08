<?php
/* $Id: database.php,v 1.8 2012-06-08 09:18:13 orainf Exp $ */

//Include HTML header
require_once("/home/orainf/scripto/php/my_library.php");
require("statspack.php");
require("header.php");

$dir=$_GET['dir'];
$filename=$_GET['filename'];


//Include statspack charts and tables 
if (is_file($dir . $filename) ) {
  //echo "File exists";
  show_statspack($dir, $filename);
} else {
  echo "File report could not be found. It means that there is no statspacke report for that date.<BR>";
}


//Include footer file with navigation links
require("footer.php");
