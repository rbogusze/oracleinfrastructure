<?php
/* $Id: index.php,v 1.2 2012-05-17 11:04:09 orainf Exp $ */

//Include HTML header
require("header.php");

//Global variables
$min_size = 10;
$max_size = 100;


$oczy = array(
  "oko1" => array (
     "description" => "hejo",
     "location" => "garaż",
     "video_url" => "http://192.168.1.232:8081",
     "hostname" => "192.168.1.232",
     "rank" => 400
  ),
  "oko2" => array (
     "description" => "hejo",
     "location" => "pokój Adasia",
     "video_url" => "http://192.168.1.233:8081",
     "hostname" => "192.168.1.233",
     "rank" => 400
  ),
/*  "oko3" => array (
     "description" => "hejo",
     "location" => "salon kominek",
     "video_url" => "http://192.168.1.234:8081",
     "hostname" => "192.168.1.233",
     "rank" => 400
  ),
*/
  "oko4" => array (
     "description" => "hejo",
     "location" => "salon kominek",
     "video_url" => "http://192.168.1.236:8081",
     "hostname" => "192.168.1.236",
     "rank" => 400
  )
);

// measure the activity and based on that change the rank value
$dir = "";



// loop through the array
$last = count($oczy) - 1;
echo "<BR>";

print "<table border=1>";
print "<tr><td colspan=3>";
#print "<img src=http://192.168.1.234:8081/ border=0 width=600</a>";
print "<img src=http://192.168.1.227/video.cgi border=0 width=600</a>";
#print "</td><td colspan=3>";
print "<img src=http://192.168.1.226/video.cgi border=0 width=600</a>";
print "</td></tr>";
print "<tr><td>";
foreach ($oczy as $i => $row)
{
  $isFirst = ($i == 0);
  $isLast = ($i == $last);

  echo "<a><img src=" . $row['video_url'] . "/ border=0 width=" . $row['rank'] . "></a>";
  //echo "<BR" . $i . " " . $row['location'] . "<BR>";
  echo "<br><a>" . $i . ": " . $row['location'] . "</a>";

  print "</td><td>";
}
print "</td></tr>";

print "</table>";


//Include footer file with navigation links
require("footer.php");

