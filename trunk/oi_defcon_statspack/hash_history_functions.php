<?php
/* $Id: hash_history_functions.php,v 1.1 2011/07/27 18:52:22 remikcvs Exp $ */

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


// Draw the chart
// $data_values - array - Values eg 2500 PIO
// $data_values_label - array - Timestamp 
// $chart_data_label - string Hash
// $section_name - string
// $draw_sql_explain - sring - clean hash Y/N
function draw_chart($data_values, $data_values_label, $chart_data_label, $section_name, $draw_sql_explain, $dir) {
  $tmp1 = base64_encode(serialize(array_reverse($data_values)));
  $tmp2 = base64_encode(serialize(array_reverse($data_values_label)));

  // There is a problem with URI beeing too long: Request-URI Too Large, which can prevent
  // some images from appearing. Default is: LimitRequestLine 8190 
  // I will try to detect the size of a strig passed.
  //show_array($data_values);
  //show_array($data_values_label);
  //echo "<BR> Ala ma kota:" . (strlen($tmp2) + strlen($tmp1) + strlen($chart_data_label) + strlen($section_name)) . " <BR>";
  if (( strlen($tmp2) + strlen($tmp1) + strlen($chart_data_label) + strlen($section_name) ) > 8190) {
    //There is more data that I can transmit using URI parameter. I will shred some data.
    echo "<BR> There is more data that I can reasonably display. I will shred some data. <BR>";
    $filtered_data_values = rem_array_filter($data_values);
    $filtered_data_values_label = rem_array_filter($data_values_label);
    //show_array($filtered_data_values);
    //show_array($filtered_data_values_label);
    draw_chart($filtered_data_values, $filtered_data_values_label, $chart_data_label, $section_name, $draw_sql_explain, $dir);
  } else {

    // Description of draw_chart.php
    // chart_data - values like 2500 PIO
    // chart_leg - legent to values like timestamp
    // chart_data_label - Subtitle
    echo "<img src=\"draw_chart.php?chart_data=$tmp1&chart_leg=$tmp2&chart_data_label=$chart_data_label&chart_title=$section_name\" border=0 align=center width= height=>";
    // For troubleschooting
    //echo "<a href=\"draw_chart.php?data_values=$tmp1&chart_leg=$tmp2&data_values_label=$data_values_label&chart_title=$section_name\" >aaa </a>";

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
        //echo "<td>" . $tmp . "</td>";
        // If file exists I print a link
        if (is_file($dir . "hash_history/hash_" . $draw_sql_explain . "_" . $row["value"] . ".lst")) {
          echo "<td>" . "<a href=\"show_file.php?filename=". $dir . "hash_history/hash_" . $draw_sql_explain . "_" . $row["value"] . ".lst" . "\" > " . $tmp . "</a></td>";
        } else {
          echo "<td>" . $tmp . "</td>";
        } //if (is_file
      } // for($j=0;
      echo "</tr></table>";

      
    } // if ( $draw_sql_explain )

  } // ...ection_name) ) > 8190)
} // function draw_chart

?>
