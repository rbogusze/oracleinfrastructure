<?php
/* $Id: draw_chart.php,v 1.1 2011/07/26 20:54:59 remikcvs Exp $ */

include ("/var/www/html/defcon1x/jpgraph-1.20.5/src/jpgraph.php");
include ("/var/www/html/defcon1x/jpgraph-1.20.5/src/jpgraph_bar.php");

$chart_data=unserialize(base64_decode($_GET['chart_data']));
$chart_leg=unserialize(base64_decode($_GET['chart_leg']));
$chart_title=$_GET['chart_title'];
$chart_data_label=$_GET['chart_data_label'];

//echo "<BR> ala ma kota draw chart <BR>";
//print_r($chart_data);
//print_r($chart_leg);


$graph = new Graph(1250,250,"auto");
$graph->SetScale("textint");
$graph->img->SetMargin(100,30,50,75);
$graph->AdjBackgroundImage(0.4,0.7,-1); //setting BG type
$graph->SetShadow();
$graph->title->Set($chart_title);
$graph->subtitle->Set($chart_data_label);

$graph->xaxis->SetFont(FF_ARIAL,FS_NORMAL,8); 
$graph->xaxis->SetLabelAngle(90);
$graph->xaxis->SetTickLabels($chart_leg);

function yLabelFormat($aLabel) {
    // Format '1000 english style
    return number_format($aLabel);
    // Format '1000 french style
    //return number_format($aLabel, 2, ',', ' ');
} 
$graph->yaxis->SetLabelFormatCallback('yLabelFormat');


$bplot = new BarPlot($chart_data);
$bplot->SetFillColor("lightgreen"); // Fill color
//$bplot->value->Show();
//$bplot->value->SetFont(FF_ARIAL,FS_BOLD);
//$bplot->value->SetAngle(45);
$bplot->value->SetColor("black","navy");
$graph->Add($bplot);
$graph->Stroke();

?>
