<?php
/* $Id: index.php,v 1.2 2012-05-17 11:04:09 orainf Exp $ */

//Include HTML header
require("header.php");

print "ala ma kota";
print "</table>";
print "<tr><td>";
print "</table>";

//Global variables
$min_size = 10;
$max_size = 100;


$oczy = array(
  "oko1" => array (
     "description" => "hejo",
     "location" => "pracownia",
     "video_url" => "http://192.168.1.232:8081",
     "rank" => 100
  ),
  "oko2" => array (
     "description" => "hejo",
     "location" => "nie wiem gdzie",
     "video_url" => "http://192.168.1.233:8081",
     "rank" => 100
  ),
  "oko3" => array (
     "description" => "hejo",
     "location" => "hej tam",
     "video_url" => "http://192.168.1.234:8081",
     "rank" => 100
  )
);


//Include footer file with navigation links
require("footer.php");

