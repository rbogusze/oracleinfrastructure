<?php
/* $Id: hash_history.php,v 1.6 2012-05-25 08:28:34 orainf Exp $ */

//Include HTML header
require_once("/home/orainf/scripto/php/my_library.php");
require("header.php");
require("hash_history_functions.php");
echo "<tt>SQL History <BR></tt>";
echo "<table><td width=1000 valign=top>";

$hash_value=$_GET['hash_value'];

$dir=$_GET['dir'];
$history_range=$_GET['history_range'];

$filenames_array = array();
$filenames_array_counter = 0;

$data_values = array();
$data_values_counter = 0;

// Present the urls with different history range
if (! $history_range) {
  $history_range = 60;
}
echo "<a href=\"hash_history.php?dir=". $dir . "&hash_value=" . $hash_value . "&history_range=30" . "\" >Last 30 days </a>";
echo "<a href=\"hash_history.php?dir=". $dir . "&hash_value=" . $hash_value . "&history_range=60" . "\" >Last 60 days </a>";
echo "<a href=\"hash_history.php?dir=". $dir . "&hash_value=" . $hash_value . "&history_range=180" . "\" >Last 180 days </a>";
echo "<a href=\"hash_history.php?dir=". $dir . "&hash_value=" . $hash_value . "&history_range=360" . "\" >Last 360 days </a>";
echo "<a href=\"hash_history.php?dir=". $dir . "&hash_value=" . $hash_value . "&history_range=unlimited" . "\" >Unlimited days </a>";

echo "<BR>Current History Range: $history_range <BR>";


echo "<BR> hash_value: $hash_value <BR>";
// Open a known directory, and proceed to read its contents to array 
// Prepare a table with every statspack file
if (is_dir($dir)) {
   if ($dh = opendir($dir)) {
      while (($file = readdir($dh)) !== false) {
        //echo "filename: $file : filetype: " . filetype($dir . $file) . "<BR>";
	if (filetype($dir . $file) == file) {

          // find extention
          if ( strstr( $file, $hash_value) & strstr( $file, ".txt") ) { 
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
          } // if ( strstr( $file, ".lst")


	} // if (filetype($dir . $file) == file) 
      } //while (($file = readdir($dh)) !== false)
   closedir($dh);
   } // if ($dh = opendir($dir))
} // if (is_dir($dir))


//echo "<BR> ala ma kota";
//show_array($filenames_array);

//Get vales for selected statistic from sql_id files provied.
list($a_elapsed_time_timestamp, $a_elapsed_time, $a_elapsed_time_per_exec, $a_trash ) = get_values_from_sql_id_files($dir, $filenames_array, "Elapsed Time (ms)");
list($a_cpu_time_timestamp, $a_cpu_time, $a_cpu_time_per_exec, $a_trash ) = get_values_from_sql_id_files($dir, $filenames_array, "CPU Time (ms)");
list($a_executions_timestamp, $a_executions, $a_executions_per_exec, $a_trash ) = get_values_from_sql_id_files($dir, $filenames_array, "Executions");
list($a_buffer_gets_timestamp, $a_buffer_gets, $a_buffer_gets_per_exec, $a_trash ) = get_values_from_sql_id_files($dir, $filenames_array, "Buffer Gets");


//show_array($a_timestamp);
//show_array($a_elapsed_time);
//show_array($a_elapsed_time_per_exec);

//Draw a picture
// Create a draw
// 1 - $data_values3 - array - values eg buffergets
// 2 - $chart_leg - array - timestamp
// 3 - $data_values3_label - string
// 4 - $section_name - string
// 5 - Y/N whether to print the table with SQL explain plans through history. I provide the clean hash number if yes
// 6 - $dir - directory needed for sql explain plan in the end table

echo "<BR><HR><B>Per instance statistics</B><BR>";
draw_chart($a_elapsed_time, $a_elapsed_time_timestamp, ("Sql Id: " . $hash_value ), "Elapsed Time (ms)", 0, "");
draw_chart($a_cpu_time, $a_cpu_time_timestamp, ("Sql Id: " . $hash_value ), "CPU Time (ms)", 0, "");
draw_chart($a_executions, $a_executions_timestamp, ("Sql Id: " . $hash_value ), "Executions", 0, "");
draw_chart($a_buffer_gets, $a_buffer_gets_timestamp, ("Sql Id: " . $hash_value ), "Buffer Gets", "$hash_value", "$dir", $filenames_array);

echo "<BR><HR><B>Per execution statistics</B><BR>";

draw_chart($a_cpu_time_per_exec, $a_cpu_time_timestamp, ("Sql Id: " . $hash_value ), "CPU Time (ms) per execution", 0, "");
draw_chart($a_elapsed_time_per_exec, $a_elapsed_time_timestamp, ("Sql Id: " . $hash_value ), "Elapsed Time (ms) per execution", 0, "");
draw_chart($a_buffer_gets_per_exec, $a_buffer_gets_timestamp, ("Sql Id: " . $hash_value ), "Buffer Gets per execution", "$hash_value", "$dir", $filenames_array);
//Include footer file with navigation links
require("footer.php");
exit;
