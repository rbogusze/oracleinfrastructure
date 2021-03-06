<?php
/* $Id: db_statistics.php,v 1.4 2012/07/12 11:19:54 orainf Exp $ */

//Include HTML header
require_once("/home/orainf/scripto/php/my_library.php");
require("header.php");
echo "<tt>Database Statistics <BR></tt>";

//Statistics for which I want to see graph, for other display link
$interesting_stats = array("db block changes", "execute count", "logons cumulative", "parse count (total)", "parse time elapsed", "physical reads", "physical writes", "redo size", "user calls", "sorts (memory)", "user logons cumulative", "gc cr blocks received", "PX local messages sent", "Parallel operations not downgrad", "physical write IO requests", "");

$dir=$_GET['dir'];
$filename=$_GET['filename'];

echo "<a href=\"index.php\" >Back to DB list</a> <BR></tt>";

echo "<BR> dir: $dir";
echo "<BR> filename: $filename";

echo "<table border=1>";
echo "<tr><td>Statistic</td><td>Total</td><td>per Second</td><td>per Trans</td></tr>";
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
    if (strstr ( $data, "Instance Activity Stats ")) { echo "<font color='black'>"; $section = 1; }
    // Spot section end, then exit the while loop.
    if (strstr ( $data, "Instance Activity Stats - Absolute Values")) { echo "<font color='red'>"; $section = 0; break; }
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
     
      $trash2 = str_replace(",", "", $trash2);  // | Total   |
      $trash3 = str_replace(",", "", $trash3);  // | per Second   |
      $trash4 = str_replace(",", "", $trash4);  // | per Trans   |

      if ( is_numeric($trash2) && is_numeric($trash3)  ) {
        //echo "<br> data: $data <br>";
        echo "<tr><td><a href=\"db_statistics_history.php?dir="  . $dir . "&statname=" . $trash1 . "\" >" . $trash1 . "</a>" . "</td><td>$trash2</td><td>$trash3</td><td>$trash4</td></tr>";

        //As there is too many statistics to display them all (little point) I select only those I am interested in
        if (in_array($trash1, $interesting_stats)) {
        //replace space with %20
          $trash1 = str_replace(" ", "%20", $trash1); 
          $remote_url = "db_statistics_history.php?dir="  . $dir . "&statname=" . $trash1 . "&history_range=118&silent=1" ;
          echo "<tr><td colspan=4>";
          //echo "<br> remote_url: $remote_url <br>";
          echo file_get_contents("http://logwatch/oi_defcon_awr12/" . $remote_url);
          echo "</tr></td>";
        } //if (in_array($trash1, $interesting_stats))
        echo "</tr></td>";
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
