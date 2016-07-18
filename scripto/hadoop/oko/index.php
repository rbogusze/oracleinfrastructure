<?php
/* $Id: index.php,v 1.2 2012-05-17 11:04:09 orainf Exp $ */

//Include HTML header
require("header.php");

print "ala ma kota";

//Global variables
$min_size = 10;
$max_size = 100;


$oczy = array(
  "oko1" => array (
     "description" => "hejo",
     "location" => "pracownia",
     "video_url" => "http://192.168.1.232:8081",
     "hostname" => "192.168.1.232",
     "rank" => 100
  ),
  "oko2" => array (
     "description" => "hejo",
     "location" => "nie wiem gdzie",
     "video_url" => "http://192.168.1.233:8081",
     "hostname" => "192.168.1.233",
     "rank" => 100
  ),
  "oko3" => array (
     "description" => "hejo",
     "location" => "hej tam",
     "video_url" => "http://192.168.1.234:8081",
     "hostname" => "192.168.1.233",
     "rank" => 100
  )
);

// loop through the array
$last = count($oczy) - 1;
echo "<BR>";

print "<table border=1>";
print "<tr><td>";
foreach ($oczy as $i => $row)
{
    $isFirst = ($i == 0);
    $isLast = ($i == $last);

    echo "<img src=" . $row['video_url'] . "/ border=0 ></a>";
    echo $i . " " . $row['location'] . "<BR>";
    print "</td><td>";
}
print "</tr></td>";
print "</table>";


//Include footer file with navigation links
require("footer.php");

