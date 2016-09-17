<?php
/* $Id: show_file.php,v 1.1 2012-05-17 10:25:16 orainf Exp $ */
//require("header.php");

$filename=$_GET['filename'];
$syntax_highlight=$_GET['syntax_highlight'];

// There are two ways to do it

// 1. Use shell utility
//$tmp = shell_exec("txt2html $filename");
//echo $tmp;

// 2. Or do it yourself

// sanity check
if (is_file($filename) ) {
  // open file
  $fh = fopen ($filename, "r") or die("Could not open file");
  // read file
  echo "<pre>";
  $highlight = "";
  while (!feof($fh))
  {
    $data = fgets($fh);
    // remove FF char
    $data = str_replace("\f",'',$data);

    // Highlight full scans
    if (strstr ( $data, "FULL" ) ) { $highlight = "<font color='red'>"; }
    // Highlight what was requested in URL
    if (strstr ( $data, $syntax_highlight ) ) { $highlight = "<font color='blue'>"; }
   
    // If there is something to highlight do it
    if ( $highlight ) { 
      echo $highlight; 
      $highlight = ""; 
      echo $data . "</font>";
    } else {
      echo $data;
    } 
  } // while (!feof($fh))

  // close file
  fclose ($fh);
  echo "</pre>";
} else {
  echo "File could not be found.\n";
  exit(1);
}


//Include footer file with navigation links
//require("footer.php");
?>
