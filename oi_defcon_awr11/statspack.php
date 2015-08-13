<?php
/* $Id: statspack.php,v 1.2 2012-05-17 11:04:09 orainf Exp $ */

error_reporting(E_ERROR);

// Draw Pictures with section data
function draw_chart_section($dir, $filename, $chart_data, $chart_leg, $data_module, $section_name, $data_values_executions, $timestamp, $width, $height) {
  //$tmp1 = base64_encode(serialize(array_reverse($chart_data)));
  //$tmp2 = base64_encode(serialize(array_reverse($chart_leg)));
  $tmp1 = base64_encode(serialize($chart_data));
  $tmp2 = base64_encode(serialize($chart_leg));

  //Digesting SID from dir path, again not elegant and errorprone but...
  list($trash, $trash, $trash, $trash, $trash, $db_sid)=split('/', $dir);
  //echo "<BR> db_sid: $db_sid ";

  //echo "<BR> filename: $filename";
  // Digest constant file part from awr filename that is present in hash file too
  $file_part= str_replace("awr_$db_sid" , '', $filename ); 
  //echo "<BR> file_part: $file_part";

  echo "<table><tr><td> Module-exp </td><td> FullHistor </td><td> Exec</td></tr>";
  echo "<tr><td></td><td></td><td></td><td rowspan=50><img src=\"draw_chart_section.php?chart_data=$tmp1&chart_leg=$tmp2&chart_title=$section_name&chart_width=$width&chart_height=$height\" border=0 align=center width= height=></td></tr>";

  //Now the rest of table
  for($j=0;$j<count($chart_data);$j++)
  {
    //$each_chart_data = each($chart_data);
    $each_chart_leg = each($chart_leg);
    $each_data_module = each($data_module);
    $each_data_executions = each($data_values_executions);
    print "<tr><td>";
    //print "<a href=\"show_file.php?filename=". $dir . "hash_history/hash_" . $each_chart_leg["value"] . "_" . $timestamp . ".lst" .  "\" > " . $each_data_module["value"] . "</a>";
    print "<a href=\"show_file.php?filename=". $dir . "hash_history/awr_" . $db_sid . "_" . $each_chart_leg["value"] . $file_part .  "\" > " . $each_data_module["value"] . "</a>";
    print "</td><td>";
    print "<a href=\"hash_history.php?dir=" . $dir . "hash_history/" . "&hash_value=" . $each_chart_leg["value"] . "\" >" . $each_chart_leg["value"] . "</a>"; 
    print "</td><td>";
    print $each_data_executions["value"];

    print "</td></tr>";
  }
  echo "</table>";

} //function draw_chart_section

// This the major function here
// $dir - directory
// $filename - filename to analyse
function show_statspack($dir, $filename) {

//Include
require_once("/home/orainf/scripto/php/my_library.php");

// sanity check
if (is_file($dir . $filename) ) {

// open file
$fh = fopen ($dir . $filename, "r") or die("Could not open file");
//echo "<BR> file: $filename in dir: $dir <BR>";


//some variables
$hosts_array = array();
$hosts_array_counter = 0;
$data_values1_counter = 0;
$data_values2_counter = 0;
$data_values3_counter = 0;
$data_values4_counter = 0;
$data_values5_counter = 0;
$section = 0;

// Extract from the filename data time of creation nedded for hash view
preg_match ("/....-..-../", $filename, $match_result);
$timestamp=$match_result[0];

//echo "<BR> timestamp: $timestamp";

// Heading
//print "<h2>" . substr($dir . $filename, 29) . "</h2>";

// read file
while (!feof($fh))
{
  $data = fgets($fh);

  // remove any cariage return and new line characters
  //$data = str_replace("\r",'',$data);
  //$data = str_replace("\n",'',$data);
  // remove FF char
  $data = str_replace("\f",'',$data);

  if (strlen($data) == 0) { continue; }

  // Spot sections start
  if (strstr ( $data, "SQL ordered by Elapsed Time ")) { echo "<font color='red'>"; $section = 1; }

  // echo "<br> data: $data <br>";

  // Spot sections
  if (strstr ( $data, "SQL ordered by Gets  ")) { echo "<font color='green'>"; $section_name = "Buffer_Gets"; }
  if (strstr ( $data, "SQL ordered by Reads  ")) { echo "<font color='green'>"; $section_name = "Physical_Reads"; }
  if (strstr ( $data, "SQL ordered by CPU ")) { echo "<font color='green'>"; $section_name = "CPU_Usage"; }
  if (strstr ( $data, "SQL ordered by Elapsed ")) { $section_name = "Elapsed_Time"; }
  if (strstr ( $data, "SQL ordered by Executions ")) { echo "<font color='green'>"; $section_name = "Executions_Rows"; }
  if (strstr ( $data, "SQL ordered by Parse Calls ")) { echo "<font color='green'>"; $section_name = "Parse_Calls"; }
  if (strstr ( $data, "SQL ordered by Sharable Memory ")) { echo "<font color='green'>"; $section_name = "Sharable_Mem"; }

  if ( $section ) {
    // I need to stripe multiple spaces
    $data = preg_replace('/\s\s+/', ' ', $data);

    // Delete the leading space
    $data = trim($data);

    // Separate the string into pieces
    list($trash1, $trash2, $trash3, $trash4, $trash5, $trash6, $trash7) = split(' ',$data);

    // If the all the tokens are number I assume we are in the first line describing
    // SQL with values. This is a bit naive, but I see no other way
    $trash1 = str_replace(",", "", $trash1);  // | Buffer Gets	|
    $trash2 = str_replace(",", "", $trash2);  // | Executions	|
    $trash3 = str_replace(",", "", $trash3);  // | Gets per Exec|
    $trash4 = str_replace(",", "", $trash4);  // | %Total	|
    $trash5 = str_replace(",", "", $trash5);  // | CPU Time (s)	|
    $trash6 = str_replace(",", "", $trash6);  // | Elapsd Time (|
    if ( is_numeric($trash1) && is_numeric($trash2) && is_numeric($trash3) ) { 
      //echo "<BR> section_name: $section_name , trash1: $trash1 , trash2: $trash2 , trash3: $trash3 , trash4: $trash4 , trash5: $trash5 , trash6: $trash6 , trash7: $trash7 <BR>";
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
      //echo "<BR>Moooodul name: $module_name <BR>";
      
      // Bulding arrays with hash and values
      if ($section_name == "Buffer_Gets") {
        $data_values1[$data_values1_counter] = $trash1;			//Buffer Gets
        $data_values1_label[$data_values1_counter] = $trash7;	//SQL Id
        $data_values1_module[$data_values1_counter] = $module_name;
        $data_values1_sql[$data_values1_counter] = $sql_text;
        $data_values1_executions[$data_values1_counter] = $trash2;	//Executions
        $data_values1_elapsedtime[$data_values1_counter] = $trash6;	//Elapsed Time (s)
        $data_values1_counter++;
      }
      if ($section_name == "Physical_Reads") {
        $data_values2[$data_values2_counter] = $trash1;		//Physical Reads
        $data_values2_label[$data_values2_counter] = $trash7; //SQL Id
        $data_values2_module[$data_values2_counter] = $module_name;
        $data_values2_sql[$data_values2_counter] = $sql_text;
        $data_values2_executions[$data_values2_counter] = $trash2; //Executions
        $data_values2_elapsedtime[$data_values2_counter] = $trash6;	//Elapsed Time (s)
        $data_values2_counter++;
      }
      if ($section_name == "CPU_Usage") {
        $data_values3[$data_values3_counter] = $trash1;		// CPU Time (s)
        $data_values3_label[$data_values3_counter] = $trash6;    //sql_id
        $data_values3_module[$data_values3_counter] = $module_name;  //module name
        $data_values3_sql[$data_values3_counter] = $sql_text;
        $data_values3_executions[$data_values3_counter] = $trash3;
        $data_values3_counter++;
      }
      if ($section_name == "Parse_Calls") {
        $data_values4[$data_values4_counter] = $trash1;
        $data_values4_label[$data_values4_counter] = $hash_value;
        $data_values4_module[$data_values4_counter] = $module_name;
        $data_values4_sql[$data_values4_counter] = $sql_text;
        $data_values4_counter++;
      }
      if ($section_name == "Elapsed_Time") {
        $data_values5[$data_values5_counter] = $trash1; //Elapsed Time (s)
        $data_values5_label[$data_values5_counter] = $trash6; //sql_id
        $data_values5_module[$data_values5_counter] = $module_name;
        $data_values5_sql[$data_values5_counter] = $sql_text;
        $data_values5_executions[$data_values5_counter] = $trash3;
        $data_values5_counter++;
      } 
    } // if ( is_numeric($trash1)

  } // if ( $section )

  // Spot sections end
  if (strstr ( $data, "Instance Activity Stats ")) { echo "<font color='blue'>"; $section = 0; }

  //echo $data . "</font>";
  echo "</font>";

  // End the line
  //echo "<BR></a>";

}

// close file
fclose ($fh);

//show_array($data_values2);
//show_array($data_values2_label);
//show_array($data_values2_elapsedtime);
//show_array($data_values2_executions);

echo "<table><tr><td>";

draw_chart_section($dir, $filename, $data_values3, $data_values3_label, $data_values3_module, "CPU_Usage", $data_values3_executions, $timestamp, 400, 500);
echo "</td><td>";
draw_chart_section($dir, $filename, $data_values1, $data_values1_label, $data_values1_module, "Buffer_Gets", $data_values1_executions, $timestamp, 400, 500);
echo "</td>";
echo "</tr><tr>";
echo "<td>";
draw_chart_section($dir, $filename, $data_values2, $data_values2_label, $data_values2_module, "Physical_Reads", $data_values2_executions, $timestamp, 400, 500);
echo "</td><td>";
draw_chart_section($dir, $filename, $data_values5, $data_values5_label, $data_values5_module, "Elapsed_Time", $data_values5_executions, $timestamp, 400, 500);
echo "</td></tr><tr><td>";

//Now I need to build a large array and sort it by time elapsed
// not needed from 10g
//$data_merged_label = array_merge($data_values1_label, $data_values2_label);
//$data_merged_elapsedtime = array_merge($data_values1_elapsedtime, $data_values2_elapsedtime);
//$data_merged_module = array_merge($data_values1_module, $data_values2_module);
//$data_merged_executions = array_merge($data_values1_executions, $data_values2_executions);
//array_multisort($data_merged_elapsedtime, $data_merged_label, $data_merged_module, $data_merged_executions);
//draw_chart_section($dir, array_reverse($data_merged_elapsedtime), array_reverse($data_merged_label), array_reverse($data_merged_module), "Elapsed time - in seconds", array_reverse($data_merged_executions), $timestamp, 400, 900);

echo "</td></tr></table>";

} else {
echo "File could not be found. <BR>";
}

} // function show_statspack
