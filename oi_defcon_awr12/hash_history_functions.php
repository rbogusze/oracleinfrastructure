<?php
/* $Id: hash_history_functions.php,v 1.8 2012-06-06 12:32:21 orainf Exp $ */

// Return value if value id odd
function odd($var)
{
   return($var & 1);
}
// Drop every even row in an array
function rem_array_filter($array)
{
  $array2 = array();
  $array2_counter = 0;
  for($j=0;$j<count($array);$j++) {
    $row = each($array);
    if (odd($row["key"])) {
      $array2[$array2_counter] = $row["value"];
      $array2_counter++;
    } // if
  } // for
  return $array2;
} //function rem_array_filter



// add to dates some milestones, so that it is easy to corelate changes in the graph 
// (or lack of the change) to some major events
function rem_add_events($array,$dir)
{
  #$array[10]="ala ma kota asasasasas" . " " . $array[10];
  #echo "<BR>";
  #print_r ($array);
  #echo "<BR>";
  #echo "lala ma kkota";
  #print_r ($dir);
  # Getting CN from dir
  list($trash0, $trash1, $trash2, $trash3, $trash4, $trash5) = split('/',$dir);
  list($cn) = split('_',$trash5);
  #echo "<BR> $cn <BR>";

  // open history file with events
  // sanity check
  $filename = "/var/www/html/oi_defcon_awr12/history.txt";
  if (is_file($filename) ) {
  // open file
  $fh = fopen ($filename, "r") or die("Could not open file");
  // read file
  while (!feof($fh))
  {
    $data = fgets($fh);
    // remove FF char
    $data = str_replace("\f",'',$data);

    list($data_date,$data_cn,$data_legend) = split('#',$data);
    #print "<BR>" . $data . " - " . $data_date . " - " . $data_cn . " - " . $data_legend . "<BR>" ;
    #print "<BR> data_date: " . $data_date;
    #print "<BR> data_cn: " . $data_cn;
    #print "<BR> cn: " . $cn;
    #print "<BR>";

    //loop through the array, and if the matching date is found add the legend
    for($j=0;$j<count($array);$j++)
    {
      #print "Checking: " . $array[$j] . "<br>";
      if ( $array[$j] == $data_date AND $data_cn == $cn ) {
        $array[$j] = $data_legend . " " . $array[$j];
        #$array[$j] = $array[$j] . $data_legend;
        #echo $array[$j] . "<br>";
        $array[$j] = preg_replace("/[^A-Za-z0-9 -=_]/", '', $array[$j]);
      }
    }
    #echo "Done for $data";
    $j=0;


  } // while (!feof($fh))

  // close file
  fclose ($fh);
  } else {
  echo "No history file found. Ignoring.\n";
  }

  #echo "<BR>";
  #print_r ($array);
  #echo "<BR>";




  return $array;
} //rem_add_events


// Draw the chart
// $data_values - array - Values eg 2500 PIO
// $data_values_label - array - Timestamp 
// $chart_data_label - string Hash
// $section_name - string
// $draw_sql_explain - sring - clean hash Y/N
function draw_chart($data_values, $data_values_label, $chart_data_label, $section_name, $draw_sql_explain, $dir, $filenames_array) {
  // add to dates some milestones, so that it is easy to corelate changes in the graph 
  // (or lack of the change) to some major events
  $data_values_label=rem_add_events($data_values_label,$dir);

  $tmp1 = base64_encode(serialize(array_reverse($data_values)));
  $tmp2 = base64_encode(serialize(array_reverse($data_values_label)));
  sort($filenames_array);

  // There is a problem with URI beeing too long: Request-URI Too Large, which can prevent
  // some images from appearing. Default is: LimitRequestLine 8190 
  // I will try to detect the size of a strig passed.
  //show_array($data_values);
  //show_array($data_values_label);
  if (( strlen($tmp2) + strlen($tmp1) + strlen($chart_data_label) + strlen($section_name) ) > 8190) {
    //There is more data that I can transmit using URI parameter. I will shred some data.
    echo "<BR> There is more data that I can reasonably display. I will shred some data. <BR>";
    $filtered_data_values = rem_array_filter($data_values);
    $filtered_data_values_label = rem_array_filter($data_values_label);
    //show_array($filtered_data_values);
    //echo "<BR> ala ma kota wielkiego";
    //show_array($filtered_data_values_label);
    draw_chart($filtered_data_values, $filtered_data_values_label, $chart_data_label, $section_name, $draw_sql_explain, $dir);
  } else {

    // Description of draw_chart.php
    // chart_data - values like 2500 PIO
    // chart_leg - legent to values like timestamp
    // chart_data_label - Subtitle
    // echo "<BR> ala ma kota wielkiego";
    //show_array($data_values);
    //show_array($data_values_label);

    echo "<img src=\"draw_chart.php?chart_data=$tmp1&chart_leg=$tmp2&chart_data_label=$chart_data_label&chart_title=$section_name\" border=0 align=center width= height=>";
    // For troubleschooting
    // echo "<a href=\"draw_chart.php?data_values=$tmp1&chart_leg=$tmp2&data_values_label=$data_values_label&chart_title=$section_name\" >aaa </a>";

    // Create a table with SQL explain plan for every day.
    // I will not create a separate function because all the same parameters should be passed to decide
    // when to shred data
    // I use here only: 
    // $data_values_label - array - timestamp, already shreded if needed
    // $draw_sql_explain - string - hash_value
    if ( $draw_sql_explain ) { 
      echo "<BR> Explain plan and full SQL text of selected days <BR><table border = 0><tr>";
      $tmp_array = array_reverse($data_values_label);
      for($j=0;$j<count($tmp_array);$j++)
      {
        $row = each($tmp_array);
        //echo "<td>" . $row["value"] . "</td>";
        //echo "<td>" . "a <BR>" . "b" . "</td>";
        // To obtain text rotated 90 degrees I print every character divided by <BR> :)
        $tmp = chunk_split($row["value"], 1, "<BR>");
        // If file exists I print a link
	//echo "<BR>Link: ". $dir . $filenames_array[$j];
	//echo "<BR>filename: $filenames_array[$j]";
        if (is_file($dir . $filenames_array[$j])) {
          // I show the html file now, another dity trick
          //txt org version echo "<td>" . "<a href=\"show_file.php?filename=". $dir . $filenames_array[$j] . "\" > " . $tmp . "</a></td>";
          echo "<td>" . "<a href=\"show_file.php?filename=". str_replace("AWR_txt_day","AWR_html_day",$dir) . str_replace(".txt",".html",$filenames_array[$j]) . "\" > " . $tmp . "</a></td>";
        } else {
          echo "<td>" . $tmp . "</td>";
        } //if (is_file
      } // for($j=0;
      echo "</tr></table>";

      
    } // if ( $draw_sql_explain )

  } // ...ection_name) ) > 8190)
} // function draw_chart

//loop through list of files and fileter them to your needs
//Get data values from every file in provided table, for provided hash and return arrays with values for desired section.
//20070809 I thing it should the get the data not from the statspack files, but from the hash files
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

//Loop through provided files and get values for selected statistic
// Input: dir, array with files to look into
// Output, three arrays with the values of the selected statistic, per Statement, per Execution and %Snap as presented
//   in hte sql_id report
function get_values_from_sql_id_files($dir, $filenames_array, $stat_name) 
{
  //echo "dir: $dir";
  //echo "filenames_array:";
  //show_array($filenames_array);
  //echo "stat_name: $stat_name";

  $data_values_counter = 0;
  for($i=0; $i<count($filenames_array); $i++)
  {
    rsort($filenames_array);
    // open file
    $fh = fopen ("$dir/$filenames_array[$i]", "r") or die("Could not open file");
    // read file
    //echo "<BR> Checking for file: $filenames_array[$i] ";

    preg_match ("/....-..-../", $filenames_array[$i], $match_result);

    $timestamp[$data_values_counter] = $match_result[0];
    while (!feof($fh))
    {
      $data = fgets($fh);

      // Wait for the Statistics Section 'Stat Name                                Statement   Per Execution % Snap '
      if (strstr ( $data, 'Stat Name' )) { $section_found = 1; }

      // Search for the proper statistic
      if (strstr ( $data, $stat_name ) && $section_found ) 
      { 
        //echo "<BR> data: $data";
	$data = str_replace($stat_name, "", $data);	// remove stat name
        $data = str_replace(",", "", $data);		// remove ,
        $data = preg_replace('/\s\s+/', ' ', $data);    // I need to stripe multiple spaces
	//It can happen that string '##########' appears that idicates that the value is too high.
	//I pu the 99999999999 instead to indicate that this is really big and avoid the error in graph
	$data = str_replace("##########", "9999999", $data);
        list($trash0, $trash1, $trash2, $trash3) = split(' ',$data);
        #echo "<BR> trash0: $trash1 trash1: $trash1 trash2: $trash2 trash3: $trash3";

        $data_values1[$data_values_counter] = $trash1;
        $data_values2[$data_values_counter] = $trash2;
        $data_values3[$data_values_counter] = $trash3;

	$section_found = 0;
        break;
      } else {
        // If I do not file the statistics section in a file. This means a problem.
        $data_values1[$data_values_counter] = -100;
        $data_values2[$data_values_counter] = -100;
        $data_values3[$data_values_counter] = -100;
      }
    } // while (!feof($fh))
    $data_values_counter++;
    fclose ($fh);
  } // for($i=0; $i<count($filenames_array

//  show_array($timestamp);
//  show_array($data_values1);
//  show_array($data_values2);
//  show_array($data_values3);

  return array($timestamp, $data_values1, $data_values2, $data_values3);
} //get_values_from_sql_id_files

?>
