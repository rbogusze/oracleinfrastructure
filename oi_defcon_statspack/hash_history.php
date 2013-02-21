<?php
/* $Id: hash_history.php,v 1.1 2011/07/27 18:52:22 remikcvs Exp $ */

//Include HTML header
require("/home/oracle/scripto/php/my_library.php");
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


// Open a known directory, and proceed to read its contents to array 
// Prepare a table with every statspack file
if (is_dir($dir)) {
   if ($dh = opendir($dir)) {
      while (($file = readdir($dh)) !== false) {
        //echo "filename: $file : filetype: " . filetype($dir . $file) . "<BR>";
	if (filetype($dir . $file) == file) {

          // find extention
          if ( strstr( $file, ".lst") ) { 
            //echo "<BR> filename: $file ";
            // determine if file is in the requested time range 
            if ( $history_range != "unlimited") {
              $date_to_check = substr ($file, 5, 10);
              $today = date("Y-m-d");
              $date_to_check_unix = mktime(0, 0, 0, substr($date_to_check, 5, 2), substr($date_to_check, 8, 2), substr($date_to_check, 0,4));
              $today_unix = mktime(0, 0, 0, substr($today, 5, 2), substr($today, 8, 2), substr($today, 0,4));
              //echo "Number of sec between: " . ($today_unix - $date_to_check_unix);
              # Check if number of scends elapsed bigger than history_range
              if (($today_unix - $date_to_check_unix) > ($history_range * 24 * 60 * 60)) {
                //echo "Bigger!!!";
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



//show_array($filenames_array);
//exit;

//loop through list of files and fileter them to your needs
//Get data values from every file in provided table, for provided hash and return arrays with values for desired section.
//20070809 I thing it should the data not from the statspack files, but from the hash files
function get_data_from_statspack_files($dir, $filenames_array, $section_name, $hash_value) {
  
  $data_values_counter = 0;
  $module_name = "";

  //Translate section_name values to section search string
  if ($section_name == "Buffer_Gets") { 
    $section_str = "  Buffer Gets    Executions "; 
    $section_str_end = "  Physical Rds   Executions ";
    $data_values1_label = "Buffer Gets";
    $data_values2_label = "Executions";
    $data_values3_label = "Gets per Exec";
    $data_values4_label = "%Total";
    $data_values5_label = "CPU Time (s)";
    $data_values6_label = "Elapsd Time (s)";
    $data_values7_label = "Elapsd Time (s) per Exec";
  }
  if ($section_name == "Physical_Reads") { 
    $section_str = "  Physical Rds   Executions "; 
    $section_str_end = " Executions   Rows Processed ";
    $data_values1_label = "Physical Reads";
    $data_values2_label = "Executions";
    $data_values3_label = "Reads per Exec";
    $data_values4_label = "%Total";
    $data_values5_label = "CPU Time (s)";
    $data_values6_label = "Elapsd Time (s)";
    $data_values7_label = "Elapsd Time (s) per Exec";
  }
  if ($section_name == "Executions_Rows") { 
    $section_str = " Executions   Rows Processed "; 
    $section_str_end = " Parse Calls   Executions "; 
    $data_values1_label = "Executions";
    $data_values2_label = "Rows Processed";
    $data_values3_label = "Rows per Exec";
    $data_values4_label = "CPU per Exec (s)";
    $data_values5_label = "Elap per Exec (s)";
    $data_values6_label = "";
  }
  if ($section_name == "Parse_Calls") { 
    $section_str = " Parse Calls   Executions "; 
    $section_str_end = "Memory (KB) Memory (KB)";
    $data_values1_label = "Parse Calls";
    $data_values2_label = "Executions";
    $data_values3_label = "% Total Parses";
    $data_values4_label = "";
    $data_values5_label = "";
    $data_values6_label = "";
  }
  if ($section_name == "Sharable_Mem") { 
    $section_str = "Memory (KB) Memory (KB)"; 
    $section_str_end = "   Count    Count    Count ";
    $data_values1_label = "Sharable Mem (b)";
    $data_values2_label = "Executions";
    $data_values3_label = "% Total";
    $data_values4_label = "";
    $data_values5_label = "";
    $data_values6_label = "";
  }
  //print_r ($filenames_array);
  //echo "Set env: $section_name $section_str $section_str_end";
  for($i=0; $i<count($filenames_array); $i++)
  {
    rsort($filenames_array);
    // open file
    $fh = fopen ("$dir/$filenames_array[$i]", "r") or die("Could not open file");
    // read file
    //echo "$filenames_array[$i] ";
    while (!feof($fh))
    {
      $data = fgets($fh);
      // Search for the proper section
      if (strstr ( $data, $section_str )) { $section_found = 1; }
       
      // I am in the proper section, now let us have hash_value
      if (strstr ( $data, $hash_value ) && $section_found) { 
        //echo "<font color='blue'>" . $data . "</font></a> <BR>"; 
        // Extract from the filename data time of creation nedded for char legend
        $chart_leg[$data_values_counter] = substr ( $filenames_array[$i], 5, 10);
        
        // Create array with data
        $data = preg_replace('/\s\s+/', ' ', $data); 	// I need to stripe multiple spaces
        $data = trim($data);				// Delete the leading space
        // Separate the string into pieces
        $data = str_replace(",", "", $data);
        list($data_values1[$data_values_counter], $data_values2[$data_values_counter], $data_values3[$data_values_counter], $data_values4[$data_values_counter], $data_values5[$data_values_counter], $data_values6[$data_values_counter]) = split(' ',$data);
        // Manually compute the Elapsed time per Exec
        $data_values7[$data_values_counter] = ($data_values6[$data_values_counter] / $data_values2[$data_values_counter]);

        //show_array($data_values[$data_values_counter]);
        $data_values_counter++; 
        
        // If module name and short sql text was not set I set it
        if ( $module_name == "" ) {
          //If this is a numeric value, then the next is module name, we need it so I take it
          $module_name = fgets($fh);
          if (strstr ($module_name, "Module: ")) {
            $module_name = str_replace("Module: ", "", $module_name);
            $module_name = substr($module_name, 0, 13);  //Trimint to first 13 char
          } else {
            $module_name = "NA";
          }
          //If this was the module name then the next is SQL text, I take it
          $sql_text = fgets($fh);
          //echo "<BR>Moooodul name: $module_name SQL: $sql_text<BR>";
        } // if ( $module_name == ""

        $section_found = 0;
        break;
      }

      // Searching for the secion end
      if (strstr ( $data, $section_str_end )) { $section_found = 0; break; }
    } // while (!feof($fh))
    fclose ($fh);
  } // for($i=0; $i<count($filenames_array

  //show_array($data_values2);
  return array($chart_leg, $data_values1, $data_values2, $data_values3, $data_values6, $data_values7, $data_values1_label, $data_values2_label, $data_values3_label, $data_values6_label, $data_values7_label, $module_name, $sql_text);

} //function get_data_from_statspack_files

//Get values from statspack files for selected section
list($chart_bg_leg, $data_bg_values1, $data_bg_values2, $data_bg_values3, $data_bg_values6, $data_bg_values7, $data_bg_values1_label, $data_bg_values2_label, $data_bg_values3_label, $data_bg_values6_label, $data_bg_values7_label, $module_bg_name, $sql_bg_text) = get_data_from_statspack_files($dir, $filenames_array, "Buffer_Gets", $hash_value);
list($chart_pr_leg, $data_pr_values1, $data_pr_values2, $data_pr_values3, $data_pr_values6, $data_pr_values7, $data_pr_values1_label, $data_pr_values2_label, $data_pr_values3_label, $data_pr_values6_label, $data_pr_values7_label, $module_pr_name, $sql_pr_text) = get_data_from_statspack_files($dir, $filenames_array, "Physical_Reads", $hash_value);


// Create a draw
// 1 - $data_values3 - array - values eg buffergets
// 2 - $chart_leg - array - timestamp
// 3 - $data_values3_label - string
// 4 - $section_name - string
// 5 - Y/N whether to print the table with SQL explain plans through history. I provide the clean hash number if yes
// 6 - $dir - directory needed for sql explain plan in the end table

// For Buffer_Gets section
if ( count($data_bg_values1) > 0 ) {
  echo "History of SQL with hash: <font color='black'> $hash_value</font>, Module: <font color='black'>$module_bg_name</font>, ";
  // The first elemnt of array $chart_leg that containst timestamp is the last data that we have statspack report
  // based on that I will present the hash history generated from the last statspacke report
  echo "<a href=\"show_file.php?filename=". $dir . "hash_history/hash_" . $hash_value . "_" . $chart_bg_leg[0] . ".lst" . "\" >Show recent full SQL with explain plan, </a>";
  echo "SQL starts with: \"<font color='black'>$sql_bg_text</font>\" <BR>";
  draw_chart($data_bg_values1, $chart_bg_leg, ($data_bg_values1_label . ", Hash: " . $hash_value . ", Module: " . $module_bg_name), "Buffer_Gets - Buffer Gets", 0, "");
  draw_chart($data_bg_values3, $chart_bg_leg, ($data_bg_values3_label . ", Hash: " . $hash_value . ", Module: " . $module_bg_name), "Buffer_Gets - Gets per Exec", 0, "");
  draw_chart($data_bg_values6, $chart_bg_leg, ($data_bg_values6_label . ", Hash: " . $hash_value . ", Module: " . $module_bg_name), "Buffer_Gets - Total Elapsed Time", 0, "");
  draw_chart($data_bg_values7, $chart_bg_leg, ($data_bg_values7_label . ", Hash: " . $hash_value . ", Module: " . $module_bg_name), "Buffer_Gets - Total Elapsed Time per Exec", 0, "");
  draw_chart($data_bg_values2, $chart_bg_leg, ($data_bg_values2_label . ", Hash: " . $hash_value . ", Module: " . $module_bg_name), "Buffer_Gets - Executions", $hash_value, $dir);
}

// For Physical_Reads section
if (count($data_pr_values1) > 0) { 
  echo "History of SQL with hash: <font color='black'> $hash_value</font>, Module: <font color='black'>$module_bg_name</font>, ";
  // The first elemnt of array $chart_leg that containst timestamp is the last data that we have statspack report
  // based on that I will present the hash history generated from the last statspacke report
  echo "<a href=\"show_file.php?filename=". $dir . "hash_history/hash_" . $hash_value . "_" . $chart_pr_leg[0] . ".lst" . "\" >Show recent full SQL with explain plan, </a>";
  echo "SQL starts with: \"<font color='black'>$sql_pr_text</font>\" <BR>";
  draw_chart($data_pr_values1, $chart_pr_leg, ($data_pr_values1_label . ", Hash: " . $hash_value . ", Module: " . $module_pr_name), "Physical_Reads - Physical Reads", 0, "");
  draw_chart($data_pr_values3, $chart_pr_leg, ($data_pr_values3_label . ", Hash: " . $hash_value . ", Module: " . $module_pr_name), "Physical_Reads - Reads per Exec", 0, "");
  draw_chart($data_pr_values6, $chart_pr_leg, ($data_pr_values6_label . ", Hash: " . $hash_value . ", Module: " . $module_pr_name), "Physical_Reads - Total Elapsed Time", 0, "");
  draw_chart($data_pr_values7, $chart_pr_leg, ($data_pr_values7_label . ", Hash: " . $hash_value . ", Module: " . $module_pr_name), "Physical_Reads - Total Elapsed Time per Exec", 0, "");
  draw_chart($data_pr_values2, $chart_pr_leg, ($data_pr_values2_label . ", Hash: " . $hash_value . ", Module: " . $module_pr_name), "Physical_Reads - Executions", $hash_value, $dir);
}

//Include footer file with navigation links
require("footer.php");
