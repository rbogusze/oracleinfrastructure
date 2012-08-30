<?php
/* $Id: database.php,v 1.8 2012-06-08 09:18:13 orainf Exp $ */

//Include HTML header
require_once("/home/orainf/scripto/php/my_library.php");
require("statspack.php");
require("header.php");

$eTag=$_GET['eTag'];
$eMonat=$_GET['eMonat'];
$eJahr=$_GET['eJahr'];
// full path
$dir=$_GET['dir'];

list($trash, $trash, $trash, $trash, $trash, $sid)=split('/', $dir);

echo "<tt>DEFCON for DB: <B> $sid, </B> <a href=\"index.php\" >Back to DB list</a> <BR></tt>";
echo "<table><td width=550 valign=top>";
//echo "<table><td valign=top>";

if (!$eJahr or !$eMonat or !$eJahr) {
  echo "No date was specified, so I chose the last full working day";
  $getFilenameDate = date("Y-m-d", mktime(0, 0, 0, date("m")  , date("d")-1, date("Y")));
  // Make sure it is not a weekend
  $tmp = date("D", mktime(0, 0, 0, date("m")  , date("d")-1, date("Y"))); 
  if ($tmp == "Sun") {
    $getFilenameDate = date("Y-m-d", mktime(0, 0, 0, date("m")  , date("d")-3, date("Y")));
  }
  if ($tmp == "Sat") {
    $getFilenameDate = date("Y-m-d", mktime(0, 0, 0, date("m")  , date("d")-2, date("Y")));
  }
    
} else {
  //echo "Date provided: $eJahr-$eMonat-$eTag";
  //convert to date with leading zeros
  $getFilenameDate= date("Y-m-d", mktime(0,0,0,$eMonat,$eTag,$eJahr));
}

echo "<BR>Date selected : ";
echo "<font color='black'> $getFilenameDate </font><BR>";

// Now let us construct the filename
//$filename = "snap_" . "$getFilenameDate";
//$filename = "$getFilenameDate" . "_16:00.txt";
$filename = "$getFilenameDate";
//echo "<BR> Ala ma kota $filename dir: $dir<BR> ";

if (is_dir($dir)) {
   if ($dh = opendir($dir)) {
      while (($file = readdir($dh)) !== false) {
        //echo "filename: $file : filetype: " . filetype($dir . $file) . "<BR>";
        if ((filetype($dir . $file) == file)) {
          //echo "filename: $file <BR>";
          // Search for constructed string
          if ( strstr( $file, "$filename") ) {
            //echo "<BR>ZZZ:  $file <BR>";
            $filename = $file;
	    break;
	  }
        }
      }
   closedir($dh);
   }
}

//Include link to raw statspack file
echo "<BR>Raw statspack file : ";
echo "<a href=\"show_file.php?filename=$dir$filename\" >$filename </a>";
echo "<BR><BR>";
echo "<a href=\"db_statistics.php?dir=$dir&filename=$filename\" >Database Statistics</a>";

//Show diagnostics for the current date
//echo "<BR><BR> Diagnostic scripts ( includes contents of cache ) <BR>";
//echo "<BR><BR> ( not implemented ) <BR>";
$dir_diagnostic = $dir . "diagnostic_scripts/";
if (is_dir($dir_diagnostic)) {
   if ($dh = opendir($dir_diagnostic)) {
      while (($file = readdir($dh)) !== false) {
        //echo "filename: $file : filetype: " . filetype($dir_diagnostic . $file) . "<BR>";
        // Select file from diagnostic_scripts directory with current date
        if ((filetype($dir_diagnostic . $file) == file) && (strstr($file, "$getFilenameDate")) ) {
          //echo "<BR> filename: $file ";
          echo "<a href=\"buffer_cache.php?dir=$dir&filename=$file\" >$file </a>";
        }
      }
   closedir($dh);
   }
}


//Incude calendar
echo "</td><td valign=top>";
require("calendar/month.php");

//Include waits from rrdora
echo "</td><td valign=top>";
echo "<img src=\"http://logwatch/rrdora_history/$getFilenameDate/$sid/12hour_waits.gif\" border=0 align=center width= height=>";
echo "</td></table>";

//Include statspack charts and tables 
if (is_file($dir . $filename) ) {
  //echo "File exists";
  show_statspack($dir, $filename);
} else {
  echo "File report could not be found. It means that there is no statspacke report for that date.<BR>";
}


//Include footer file with navigation links
require("footer.php");
