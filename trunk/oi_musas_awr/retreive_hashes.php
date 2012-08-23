<?php
/* $Id: retreive_hashes.php,v 1.2 2012-05-17 05:27:34 orainf Exp $ */

# Retreive hashes from provided statspack report
# par1 - statspack report file
# par2 - destination file
require_once("/home/orainf/scripto/php/my_library.php");

//if (!$argv[1] || !$argv[2]) { die("\nPlease provide required parameters\n"); }

$filename = $argv[1];
$output_filename = $argv[2];
//$filename = "/var/www/musas/history/PRD_192.168.220.18/snap_2007-03-15--08:07_2007-03-15--18:07.lst";
//$filename = "/var/www/html/awr_reports/KSIPDBP1/AWR_txt_hour/2012-05-15/awr_KSIPDBP1_14498_14499_2012-05-15_07:00_2012-05-15_08:00.txt";
//$output_filename = "/tmp/hash_table.txt";

$hash_array = array();
$hash_array_counter = 0;

// sanity check
if (is_file($filename) ) {
  // open file
  $fh = fopen ($filename, "r") or die("Could not open file");
  // read file
  while (!feof($fh))
  {
    $data = fgets($fh);
  if (strlen($data) == 0) { continue; }
    // Spot sections start
    if (strstr ( $data, "SQL ordered by Elapsed Time ")) { $section = 1; }

    if ( $section ) {

echo "Data: $data\n";
      // I need to stripe multiple spaces
      $data = preg_replace('/\s\s+/', ' ', $data);
      // Delete the leading space
      $data = trim($data);
      // Separate the string into pieces
      //list($trash1, $trash2, $trash3, $trash4, $trash4, $trash4, $hash_value) = split(' ',$data);
      list($trash1, $trash2, $trash3, $trash4, $trash5, $trash6, $trash7) = split(' ',$data);
      // If the all the tokens are number I assume we are in the first line describing
      // SQL with values. This is a bit naive, but I see no other way. 
      // There is a bug here too, we can only see Beffer gets and phisical_reads data only this way
      $trash1 = str_replace(",", "", $trash1);
      $trash2 = str_replace(",", "", $trash2);
      $trash3 = str_replace(",", "", $trash3);
      if ( is_numeric($trash1) && is_numeric($trash2) && is_numeric($trash3) && is_numeric($trash4) && is_numeric($trash5) && ! is_numeric($trash6) ) {
        echo "Ala ma kota, sql_id na 6 polu: $trash6\n";
        $hash_array[$hash_array_counter] = $trash6;
  	$hash_array_counter++;
      } // if ( is_numeric($trash1)
 
      if ( is_numeric($trash1) && is_numeric($trash2) && is_numeric($trash3) && is_numeric($trash4) && is_numeric($trash5) && is_numeric($trash6) && ! is_numeric($trash7) ) {
        echo "Ala ma kota, sql_id na 7 polu: $trash7\n";
        $hash_array[$hash_array_counter] = $trash7;
  	$hash_array_counter++;
      } // if ( is_numeric($trash1)

    } // if ( $section )

    // Spot sections end
    if (strstr ( $data, "SQL ordered by Parse Calls ")) { $section = 0; break; }
  }
  // close file
  fclose ($fh);
  // Remove duplicates
  $hash_array = array_flip(array_flip($hash_array)); 
echo "\n\n";
raw_show_array($hash_array);

  //Store array of hashes to a plain text file
  push_array_to_file($hash_array, $output_filename);

} else {
  echo "File could not be found.\n";
  exit(1);
}


