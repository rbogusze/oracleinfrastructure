<?php
/* $Id: draw_chart_section.php,v 1.1 2012-05-17 10:25:16 orainf Exp $ */

include ("/var/www/html/oi_defcon_awr11/jpgraph-1.20.5/src/jpgraph.php");
include ("/var/www/html/oi_defcon_awr11/jpgraph-1.20.5/src/jpgraph_bar.php");

$chart_data=unserialize(base64_decode($_GET['chart_data']));
$chart_leg=unserialize(base64_decode($_GET['chart_leg']));
$chart_title=$_GET['chart_title'];
$chart_data_label=$_GET['chart_data_label'];
$chart_width=$_GET['chart_width'];
$chart_height=$_GET['chart_height'];

//echo "<BR> ala ma kota draw chart <BR>";
//print_r($chart_data);
//print_r($chart_leg);

// Size of graph
//$width=400;
//$height=500;
//$height=1000;

// Set the basic parameters of the graph
$graph = new Graph($chart_width,$chart_height,'auto');
$graph->SetScale("textlin");

$top = 30;
$bottom = 85;
$left = 90;
$right = 30;
$graph->Set90AndMargin($left,$right,$top,$bottom);

$graph->xaxis->SetPos('min');

// Nice shadow
$graph->SetShadow();

// Setup labels
$graph->xaxis->SetTickLabels($chart_leg);

// Label align for X-axis
$graph->xaxis->SetLabelAlign('right','center','right');

// Label align for Y-axis
$graph->yaxis->SetLabelAlign('center','top');
$graph->yaxis->SetLabelAngle(90);
$graph->yaxis->SetPos('max');
function yLabelFormat($aLabel) {
    // Format '1000 english style
    return number_format($aLabel);
    // Format '1000 french style
    //return number_format($aLabel, 2, ',', ' ');
}
$graph->yaxis->SetLabelFormatCallback('yLabelFormat');

// Titles
$graph->title->Set($chart_title);

// Create a bar pot
$bplot = new BarPlot($chart_data);
$bplot->SetFillColor("orange");
$bplot->SetWidth(0.5);
//$bplot->SetYMin(1990);

//Rem additions
//$bplot->value ->Show()
//$bplot->value->Show();
//$bplot->value->SetFont(FF_ARIAL,FS_BOLD);
//$bplot->value->SetAngle(45);

$graph->Add($bplot);

$graph->Stroke();



?>
