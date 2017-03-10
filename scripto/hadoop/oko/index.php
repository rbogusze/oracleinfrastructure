<?php
/* $Id: index.php,v 1.2 2012-05-17 11:04:09 orainf Exp $ */

//Include HTML header
require_once("/home/remik/scripto/php/my_library.php");
require("header.php");

#echo "<body onload=\"parent.window.location.reload()\">"; 

//Global variables
$min_size = 10;
$max_size = 100;


$oczy = array(
  "oko1" => array (
     "description" => "hejo",
     "location" => "garaż",
     "video_url" => "http://192.168.1.232:8081",
     "hostname" => "192.168.1.232",
     "hot" => 0,
     "rank" => 610
  ),
  "oko2" => array (
     "description" => "hejo",
     "location" => "pokój Adasia",
     "video_url" => "http://192.168.1.233:8081",
     "hostname" => "192.168.1.233",
     "hot" => 0,
     "rank" => 610
  ),
/*  "oko3" => array (
     "description" => "hejo",
     "location" => "salon kominek",
     "video_url" => "http://192.168.1.234:8081",
     "hostname" => "192.168.1.233",
     "hot" => 0,
     "rank" => 400
  ),
*/
  "oko4" => array (
     "description" => "hejo",
     "location" => "salon kominek",
     "video_url" => "http://192.168.1.236:8081",
     "hostname" => "192.168.1.236",
     "hot" => 0,
     "rank" => 610
  ),
  "okox" => array (
     "description" => "hejo",
     "location" => "R&D",
     "video_url" => "http://192.168.1.235:8081",
     "hostname" => "192.168.1.235",
     "hot" => 0,
     "rank" => 610
  )
);

// measure the activity and based on that change the rank value
$dir = "";


// decide what camera is hot

$folder = "/OKO";
$images = array();
foreach (scandir($folder) as $node) {
    $nodePath = $folder . DIRECTORY_SEPARATOR . $node;
    if (is_dir($nodePath)) continue;
    $images[$nodePath] = filemtime($nodePath);
}
arsort($images);
$newest = array_slice($images, 0, 5);

//show_array($oczy);
//show_array($newest);

$hot_base=300;
$hot_counter = 1;
foreach(array_keys($newest) as $paramName) {
  //echo $paramName . "<br>";
  list($trash1, $trash2, $trash3, $trash4) = split('_',$paramName);
//  echo "<BR> ala ma kota " . $trash4;
//  echo "<BR> rank: " . $oczy[$trash4]['rank'];
//  echo "<BR> hot before: " . $oczy[$trash4]['hot'];
  $oczy[$trash4]['hot'] = ($hot_base / $hot_counter); 
//  echo "<BR> hot after: " . $oczy[$trash4]['hot'];
  $hot_counter++;
}


// loop through the array
$last = count($oczy) - 1;
echo "<BR>";

print "<table border=0>";
print "<tr><td>";
print "<img src=http://192.168.1.227/video.cgi border=0 width=610</a>";
print "</td><td>";
echo "<a><img src=" . $oczy['oko1']['video_url'] . "/ border=0 width="  . $oczy['oko1']['rank'] . "></a>";
print "</td></tr>";
print "</table>";
print "<table border=0>";
print "<tr><td>";
echo "<a><img src=" . $oczy['oko2']['video_url'] . "/ border=0 width="  . $oczy['oko2']['rank'] . "></a>";
print "</td><td>";
echo "<a><img src=" . $oczy['oko4']['video_url'] . "/ border=0 width="  . $oczy['oko4']['rank'] . "></a>";
print "</td></tr>";
print "</table>";

//Include footer file with navigation links
require("footer.php");

/*
print "<tr><td>";
foreach ($oczy as $i => $row)
{
  $isFirst = ($i == 0);
  $isLast = ($i == $last);

  echo "<a><img src=" . $row['video_url'] . "/ border=0 width=" . ($row['rank'] + $row['hot']) . "></a>";
  echo "<br><a>score: " . ($row['rank'] + $row['hot']) . "</a>";
  echo "<br><a>" . $i . ": " . $row['location'] . "</a>";

  print "</td><td>";
}
print "</td></tr>";
print "</table>";

*/

