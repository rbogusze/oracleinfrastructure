<?php
/* $Id: db_statistics.php,v 1.4 2012/07/12 11:19:54 orainf Exp $ */

//Include HTML header
require_once("/home/orainf/scripto/php/my_library.php");
require("header.php");
echo "<tt>Database Wait Events <BR></tt>";
#echo "<table><td width=1000 valign=top border=1>";

$dir=$_GET['dir'];
$filename=$_GET['filename'];

echo "<BR> dir: $dir";
echo "<BR> filename: $filename";

echo "<table border=1>";
echo "<tr><td>Event</td><td>Waits</td><td>%Timout</td><td>Total Wait Time (s)</td><td>Avg wait (ms)</td></tr>";
//Open the file and read the Statistics section
if (is_file($dir . $filename) ) {
  $fh = fopen ($dir . $filename, "r") or die("Could not open file");
  while (!feof($fh))
  {
    $data = fgets($fh);
    // remove FF char
//    $data = str_replace("\f",'',$data);
    if (strlen($data) == 0) { continue; }
    // Spot sections start
    if (strstr ( $data, "Wait Events (fg and bg) ")) { echo "<font color='black'>"; $section = 1; }
    // Spot section end, then exit the while loop.
    if (strstr ( $data, "Wait Event Histogram")) { echo "<font color='red'>"; $section = 0; break; }
    if ( $section ) {
      // I need to stripe multiple spaces
//      $data = preg_replace('/\s\s+/', ' ', $data);
      // Delete the leading space
//      $data = trim($data);
      // Separate the string into pieces
      //echo "<br> data: $data <br>";
      //list($trash1, $trash2, $trash3, $trash4, $trash5, $trash6, $trash7) = split('  ',$data);
      list($trash1, $trash2, $trash3, $trash4, $trash5, $trash6, $trash7) = preg_split("/[\s][\s]+/",$data);
      //echo "<br> trash1: $trash1 | trash2: $trash2 | trash3: $trash3 | trash4: $trash4 <br>";
    
      //tras1 - event name 
      $trash2 = str_replace(",", "", $trash2);  // | Waits   |
      $trash3 = str_replace(",", "", $trash3);  // | %Timout   |
      $trash4 = str_replace(",", "", $trash4);  // | Total Wait Time (s)   |
      $trash5 = str_replace(",", "", $trash5);  // | Avg wait (ms)   |

      if ( is_numeric($trash2) && is_numeric($trash3)  ) {
        //echo "<br> data: $data <br>";
        echo "<tr><td><a href=\"db_wait_events_history.php?dir="  . $dir . "&statname=" . $trash1 . "\" >" . $trash1 . "</a>" . "</td><td>$trash2</td><td>$trash3</td><td>$trash4</td><td>$trash5</td></tr>";
      } // if ( is_numeric($trash2)

    } // if ( $section )
  } //  while (!feof($fh))
} // if (is_file($dir . $filename) ) 

// close file
fclose ($fh);

echo "</table>";


//Include footer file with navigation links
require("footer.php");
exit;
