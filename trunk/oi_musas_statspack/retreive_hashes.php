<?php
/* $Id: retreive_hashes.php,v 1.1 2011/07/26 13:09:41 remikcvs Exp $ */

# Retreive hashes from provided statspack report
# par1 - statspack report file
# par2 - destination file
require_once("/home/oracle/scripto/php/my_library.php");

if (!$argv[1] || !$argv[2]) { die("\nPlease provide required parameters\n"); }

$filename = $argv[1];
$output_filename = $argv[2];
//$filename = "/var/www/musas/history/PRD_192.168.220.18/snap_2007-03-15--08:07_2007-03-15--18:07.lst";
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
    if (strstr ( $data, "SQL ordered by CPU ")) { $section = 1; }

    if ( $section ) {
      // I need to stripe multiple spaces
      $data = preg_replace('/\s\s+/', ' ', $data);
      // Delete the leading space
      $data = trim($data);
      // Separate the string into pieces
      list($trash1, $trash2, $trash3, $trash4, $trash4, $trash4, $hash_value) = split(' ',$data);
      // If the all the tokens are number I assume we are in the first line describing
      // SQL with values. This is a bit naive, but I see no other way. 
      // There is a bug here too, we can only see Beffer gets and phisical_reads data only this way
      $trash1 = str_replace(",", "", $trash1);
      $trash2 = str_replace(",", "", $trash2);
      $trash3 = str_replace(",", "", $trash3);
      if ( is_numeric($trash1) && is_numeric($trash2) && is_numeric($trash3) && is_numeric($hash_value) ) {
        //echo "Ala ma kota: $hash_value\n";
        $hash_array[$hash_array_counter] = $hash_value;
  	$hash_array_counter++;
      } // if ( is_numeric($trash1)
    } // if ( $section )

    // Spot sections end
    if (strstr ( $data, "Instance Activity Stats ")) { $section = 0; break; }
  }
  // close file
  fclose ($fh);
  // Remove duplicates
  $hash_array = array_flip(array_flip($hash_array)); 
  //echo "\n\n";
  //raw_show_array($hash_array);

  //Store array of hashes to a plain text file
  push_array_to_file($hash_array, $output_filename);

} else {
  echo "File could not be found.\n";
  exit(1);
}


