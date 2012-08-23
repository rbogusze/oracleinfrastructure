<?php

function ui_print_header($title)
{
  $title = htmlentities($title);
  echo <<<END
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
     "http://www.w3.org/TR/html4/strict.dtd">
  <html>
  <head>
    <meta http-equiv="Content-Type"
          content="text/html; charset=ISO-8859-1">
    <link rel="stylesheet" type="text/css" href="style.css">
    <title>Any Co.: $title</title>
  </head>
  <body>
  <h1>$title</h1>
  <form method="post" action="$posturl">
END;
}

function ui_print_footer($date)
{
  $date = htmlentities($date);
  echo <<<END
  <div class="footer">
    <div class="date">$date</div>
    <div class="company">Any Co.</div>
  </div>
  </form>
END;
}

function ui_print_table_growth_history($dept)
{
  if (!$dept) {
    echo '<p>No Data found</p>';
  }
  else {

  show_array_array2($dept);

  }

   echo <<<END
  <input type="submit" value="< Previous" name="prevdept">
  <input type="submit" value="Next >"     name="nextdept">
END;

}

function ui_print_options($select_db, $default_db)
{
  echo "Choose the right option";
  //$_SESSION['data_start'] = "cla";

  //$data_start = "aaaa";
  // Set some default values
  $data_start = $_POST['data_start'];
  $data_end = $_POST['data_end'];
  $rows_blocks = $_POST['rows_blocks'];
  if (!$data_start) $data_start = date('Y-m-d',mktime(0, 0, 0, date("m")-3, date("d"),  date("Y")));
  if (!$data_end) $data_end = date('Y-m-d',mktime(0, 0, 0, date("m"), date("d")+1,  date("Y")));
  if (!$rows_blocks) $rows_blocks = "Blocks";

  //testing
  //$query = "SELECT DISTINCT TABLE_OWNER FROM TABLE_GROWTH_HISTORY";
  //echo "connection" . $conn;
  //$array = db_get_page_data($conn, $query, 1, 100);
  //show_array($select_db);

  echo <<<END
  <table>
  <tr>
  <td>Start date</td><td><input type="text" name="data_start" value="$data_start" size="10"></td>
  <td>End date</td><td><input type="text" name="data_end" value="$data_end" size="10"></td>
  <td>Rows/Blocks</td><td><select name="rows_blocks"><option value="Rows">Rows<option value="Blocks">Blocks<option selected>$rows_blocks</select>
END;
  print "Database: ";
  html_create_dropdown_from_array("database", $select_db, $default_db);

  echo <<<END
  <input type="submit" value="update" name="Update">
  </tr>
  </table>
END;

}

//Show what comes in an array
function show_array($array)
{
  echo "<BR><table>";
  for($j=0;$j<count($array);$j++)
        {
                $row = each($array);
                print "<tr><td>" . $row["key"] . "</td><td>" . $row["value"] . "</td></tr>";
        }
  echo "</table>";
}

//Show what comes in an array
function raw_show_array($array)
{
  for($j=0;$j<count($array);$j++)
        {
                $row = each($array);
                print "Element $j: " . $row["key"] . " " . $row["value"] . "\n";
        }
}

//Store array of hashes to a plain text file. Only values.
function push_array_to_file($array, $filename)
{
  $fh = fopen($filename, 'w') or die("Could not open file for writing");  

  for($j=0;$j<count($array);$j++)
        {
                $row = each($array);
                //print "Element $j: " . $row["key"] . " " . $row["value"] . "\n";
		fwrite($fh, $row["value"] . "\n");
        }

  // close file
  fclose ($fh);

}




//Show what comes in an array
function show_array_array($array)
{
  echo "<BR><table>";
  for($j=0;$j<count($array);$j++)
        {
                $row = each($array);
                print "<tr><td>" . $row["key"] . "</td><td>" . show_array($row["value"]) . "</td></tr>";
        }
  echo "</table>";
}


//Show what comes in an array
function show_array_row($array)
{
  for($j=0;$j<count($array);$j++)
        {
                $row = each($array);
                print "<td>" . $row["value"] . "</td>";
        }
}

//Show what comes in an array
function show_array_key_row($array)
{
  for($j=0;$j<count($array);$j++)
        {
                $row = each($array);
                print "<th>" . $row["key"] . "</th>";
        }
}


//Show what comes in an array
function show_array_array2($array)
{
  echo "<BR><table border=0>";
  //Print headers
  $row = each($array);
  print "<tr>" . show_array_key_row($row["value"]) . "</tr>";

  //Reset main array with records
  reset($array);

  //Print contents of table
  for($j=0;$j<count($array);$j++)
        {
                $row = each($array);
                //print "<tr><td>" . $row["key"] . "</td>" . show_array_row($row["value"]) . "</tr>";
                print "<tr>" . show_array_row($row["value"]) . "</tr>";
        }
  echo "</table>";
}

//Create a dropdown lists from fetched arrays.
function html_create_dropdown_from_array($select_name, $array, $default_selection)
{
  
  //show_array($array);
  print "<select name=" . $select_name . ">";
  for($j=0;$j<count($array);$j++)
  {
    $row = each($array);
    if ($row["value"] == $default_selection ) {
       print "<option selected VALUE=" . $row["value"] . ">". $row["value"];
    } else {
       print "<option VALUE=" . $row["value"] . ">". $row["value"];
    }
    
  }
  print "</select>";
}


?>
