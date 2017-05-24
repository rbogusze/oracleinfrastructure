<?php
/* $Id: db_statistics_history.php,v 1.6 2012/07/12 13:27:23 orainf Exp $ */

//Include HTML header
require_once("/home/orainf/scripto/php/my_library.php");
require("header.php");
require("hash_history_functions.php");
#echo "<table><td width=1000 valign=top border=1>";

$dir=$_GET['dir'];
$statname=$_GET['statname'];
$date_with_time=$_GET['date_with_time'];
$date_no_history=$_GET['date_no_history'];
$history_range=$_GET['history_range'];
$silent=$_GET['silent'];

if (! $history_range) {
  $history_range = 180;
}

// do not show any messages / options when silent switch is on
if ( ! $silent ) {
echo "<tt>Wait Events History<BR></tt>";
echo "<br>dir:" . $dir . "<br>statname:" . $statname . "<br>";

echo "<table><tr><td>";
$date_with_range = 'http://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'] . '&history_range=30';
echo "<a href=\"$date_with_range\" >Last 30 days</a> ";
echo "</td><td>";
$date_with_range = 'http://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'] . '&history_range=60';
echo "<a href=\"$date_with_range\" >Last 60 days</a> ";
echo "</td><td>";
$date_with_range = 'http://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'] . '&history_range=180';
echo "<a href=\"$date_with_range\" >Last 180 days</a> ";
echo "</td><td>";
$date_with_range = 'http://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'] . '&history_range=360';
echo "<a href=\"$date_with_range\" >Last 360 days</a> ";
echo "</td><td>";
$date_with_range = 'http://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'] . '&history_range=unlimited';
echo "<a href=\"$date_with_range\" >Unlimited days</a> ";
echo "</td><td>";

echo "Current History Range: $history_range ";
echo "</td></tr><tr><td>";
$back_url = $_SERVER['HTTP_REFERER'];
echo "<a href=\"$back_url\" >Previous</a> ";

echo "</td><td>";
echo "<a href=\"index.php\" >Back to DB list</a> ";
echo "</td><td>";
$date_with_time_url = 'http://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'] . '&date_with_time=Y';
echo "<a href=\"$date_with_time_url\" >Dates with time</a> ";
echo "</td><td>";
$date_no_history_url = 'http://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'] . '&date_no_history=Y';
echo "<a href=\"$date_no_history_url\" >Dates with no history</a> ";
echo "</td><td>";
echo "</td></tr></table>";

} //if ( $silent)

$filenames_array = array();
$filenames_array_counter = 0;
// Open a known directory, and proceed to read its contents to array 
// Prepare a table with every statspack file
if (is_dir($dir)) {
   if ($dh = opendir($dir)) {
      while (($file = readdir($dh)) !== false) {
        //echo "filename: $file : filetype: " . filetype($dir . $file) . "<BR>";
        if (filetype($dir . $file) == file) {

            //echo "<BR> Found: file: $file zzzz <BR>";
            // determine if file is in the requested time range 
            if ( $history_range != "unlimited") {
              //get creation file time as a baseline. Prone to copying of files.
              //or get it from filename. Prone to filename format change.
//echo "<BR> file: $file";
              //old statspack one$date_to_check = substr ($file, 5, 10);
              preg_match ("/....-..-../", $file, $match_result);
              $date_to_check=$match_result[0];
              //echo "<BR> date_to_check: $date_to_check";
              $today = date("Y-m-d");
              $date_to_check_unix = mktime(0, 0, 0, substr($date_to_check, 5, 2), substr($date_to_check, 8, 2), substr($date_to_check, 0,4));
              $today_unix = mktime(0, 0, 0, substr($today, 5, 2), substr($today, 8, 2), substr($today, 0,4));
              //echo "<BR> today_unix: $today_unix";
              //echo "<BR> date_to_check_unix: $date_to_check_unix";
              
              //echo "<BR> Number of sec between: " . ($today_unix - $date_to_check_unix . "<BR>");
              # Check if number of scends elapsed bigger than history_range
              if (($today_unix - $date_to_check_unix) > ($history_range * 24 * 60 * 60)) {
                //echo "<BR> Bigger!!! skipping this file. <BR>";
                continue;  //To skip adding this filename to filenames array
              } 
            }
            // create an array
            $filenames_array[$filenames_array_counter] = $file;
            $filenames_array_counter++;


        } // if (filetype($dir . $file) == file) 
      } //while (($file = readdir($dh)) !== false)
   closedir($dh);
   } // if ($dh = opendir($dir))
} // if (is_dir($dir))


//echo "<BR> ala ma kota";
rsort($filenames_array);
//show_array($filenames_array);



// Now I have the list of files in an array. Get to them and look for statistic.
$data_values_counter = 0;
for($i=0; $i<count($filenames_array); $i++)
{
  // open file
  $fh = fopen ("$dir/$filenames_array[$i]", "r") or die("Could not open file");
  // read file
  // echo "<br>Reading file: $filenames_array[$i] ";

  $section = 0;
  while (!feof($fh))
  {
    $data = fgets($fh);
    if (strlen($data) == 0) { continue; }
    // Spot sections start
    if (strstr ( $data, "Load Profile ")) { echo "<font color='green'>"; $section = 1; }
    // Spot section end, then exit the while loop.
    if (strstr ( $data, "Instance Efficiency ")) { echo "<font color='red'>"; $section = 0; break; }
    if ( $section ) {
      //echo "<br> data: $data <br>";
      //echo "<br> Searching for statname: $statname <br>";
      if (strstr ( $data, $statname ) ) { 
        //echo "<br> pos: " . strpos( $data, $statname );
        if ( strpos( $data, $statname ) > 0 ) {
          //echo "<br> data: $data <br>";
          list($trash1, $trash2, $trash3, $trash4, $trash5) = preg_split("/[\s][\s]+/",$data);
          $trash2 = str_replace(",", "", $trash2);  // | 
          $trash3 = str_replace(",", "", $trash3);  // | 
          $trash4 = str_replace(",", "", $trash4);  // | 
          $trash5 = str_replace(",", "", $trash5);  // | 

          // echo "<br> trash1: $trash1 | trash2: $trash2 | trash3: $trash3 | trash4: $trash4 <br>";

          if ( is_numeric($trash3) && is_numeric($trash4)  ) {
             //echo "<br> data: $data <br>";
            //echo "<tr><td><a href=\"db_statistics_history.php?dir="  . $dir . "&statname=" . $trash1 . "\" >" . $trash1 . "</a>" . "</td><td>$trash2</td><td>$trash3</td><td>$trash4</td></tr>";
            $data_values1[$data_values_counter] = $trash3;
            //$data_values2[$data_values_counter] = $trash3;
            //$data_values3[$data_values_counter] = $trash4;
            //$data_values4[$data_values_counter] = $trash5;
            
          } // if ( is_numeric($trash2)
          $section_found = 0;
          break;
        } else {
        // If I do not file the statistics section in a file. This means a problem.
        $data_values1[$data_values_counter] = -100;
        //$data_values2[$data_values_counter] = -100;
        //$data_values3[$data_values_counter] = -100;
        //$data_values4[$data_values_counter] = -100;
        }

      }
    } // if ( $section )
  } // while (!feof($fh))
  $data_values_counter++;
  fclose ($fh);
  //exit;
} // for($i=0; $i<count($filenames_array

//show_array($data_values3);
echo "<br> $filenames_array[0]";
// Extract from the filename data time of creation 
for($i=0; $i<count($filenames_array); $i++)
{
  if ( $date_with_time ) {
    //echo "Preserving date with time";
    preg_match ("/....-..-.._..:../", $filenames_array[$i], $match_result);
    $filenames_array_date[$i]=$match_result[0];
    //echo "<br> zebra $match_result[0] $date_with_time";
  } else {
    //echo "Standard date only to legend";
    preg_match ("/....-..-../", $filenames_array[$i], $match_result);
    $filenames_array_date[$i]=$match_result[0];
    //echo "<br> zebra $match_result[0] $date_with_time";
  }

} // for

echo "<br>";

//echo "<BR>before the draw";
//show_array($data_values1);
//echo "<BR>before the draw2";
//show_array($filenames_array_date);

draw_chart($data_values1, $filenames_array_date, ("Statistik: " . $statname), "Per Second", 0, $dir, "");



//Include footer file with navigation links
require("footer.php");
exit;
