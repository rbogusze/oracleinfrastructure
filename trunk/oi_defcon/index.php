<?php
/* $Id: index.php,v 1.2 2012-05-17 11:04:09 orainf Exp $ */

//Include HTML header
require_once("/home/orainf/scripto/php/my_library.php");
require("header.php");

//$dir="/var/www/html/musas1x/history/";
$dir="/var/www/html/awr_reports/";
$filenames_array = array();
$filenames_array_counter = 0;


// Select available databases
// Open a known directory, and proceed to read its contents to array
if (is_dir($dir)) {
   if ($dh = opendir($dir)) {
      while (($file = readdir($dh)) !== false) {
        //echo "filename: $file : filetype: " . filetype($dir . $file) . "<BR>";
        if ((filetype($dir . $file) == dir) && ($file != '.') && ($file != '..')) {
            // echo "filename: $file <BR>";
            // create an array
            $filenames_array[$filenames_array_counter] = $file;
            $filenames_array_counter++;
        }
      }
   closedir($dh);
   }
}

// Print the list of databases
echo "<tt>DEFCON is even more alive! Now it is DEFCON_AWR - View AWR Info <BR></tt>";
echo "<tt>Please select the database you are interested in</tt>";
echo "<BR><table>";
for($j=0;$j<count($filenames_array);$j++) 
{
   $row = each($filenames_array);
   print "<tr><td>";
   print "<a href=\"database.php?dir=" . $dir . $row["value"] . "/AWR_txt_day/\" >" . $row["value"] . "</a>";
   print "</td></tr>";
}
echo "</table>";


//Include footer file with navigation links
require("footer.php");

