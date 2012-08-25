<?php

include ("db_funct.lib.php"); 
//*** get variables from outside PHP, when globals are turned off
$eUser_ser=$_GET['eUser_ser'];
$eDb_com_ser=$_GET['eDb_com_ser'];

$eTag=$_GET['eTag'];
$eMonat=$_GET['eMonat'];
$eJahr=$_GET['eJahr'];
/*
$eGraphic=$HTTP_GET_VARS['eGraphic'];
$eAnniv=$HTTP_GET_VARS['eAnniv'];
*/

//unserialize objects
$user=unserialize(stripslashes(urldecode($eUser_ser)));
$db_com=unserialize(stripslashes(urldecode($eDb_com_ser)));
//$myDay=unserialize(stripslashes(urldecode($myday_ser)));


//load language file
require("lang.en");

if (strcmp($eTag,"")==0) 
{
	$jetzt=getdate();
	$tagInWort=$jetzt[weekday];
	$tag=$jetzt[mday];
	$tagNummer=$jetzt[wday];
	$monatsNummer=$jetzt[mon];
	$monatsName=$jetzt[month];
	$jahr=$jetzt[year];
}
else
{
	$jetzt=mktime(0,0,0,$eMonat,$eTag,$eJahr);
	$jetzt=getdate($jetzt);
	$tagNummer=$jetzt[wday];
	$monatsNummer=$jetzt[mon];
	$monatsName=$jetzt[month];
	$tagInWort=$jetzt[weekday];
	$tag=$jetzt[mday];
	$jahr=$jetzt[year];
}


//the days that are in the past
for ($i=$tag-1;$i>=0;$i--)
{
	$thisMonth[]=mktime(0,0,0,$monatsNummer,$tag-$i,$jahr);
}//end for

$daysLeft=31-$tag;

//the days that are still left
//if the next month is reached, the loop ends
for ($i=1;$i<=$daysLeft;$i++)
{
	$tomorrow=mktime(0,0,0,$monatsNummer,$tag+$i,$jahr);
	$myDay=getdate($tomorrow);
	$myMonth=$myDay[mon];
	if ($myMonth!=$monatsNummer)
		break;
	else
		$thisMonth[]=$tomorrow;
}//end for

?>

<table border=0>
<tr>
<?php 
echo "<td colspan=7 align=center>$str_months[$monatsNummer] $jahr</td>"; 
?>
</tr>
<tr>

<?php

//prints the names of the days
for ($i=1;$i<=6;$i++)
{
	echo "<td>$str_weekDays[$i]</td>";
}//end for
echo "<td>$str_weekDays[0]</td>";
?>

</tr>

<?php
$firstDay=getdate($thisMonth[0]);
$dayofweek=$firstDay[wday];

//print empty cells
echo "<tr>";
for ($i=0;$i<$dayofweek-1;$i++)
{
	echo "<td>&nbsp;</td>";
}//end for


//serialize objects
$user_ser=urlencode(serialize($user));
$db_com_ser=urlencode(serialize($db_com));


//print the days
for ($i=0;$i<=sizeof($thisMonth)-1;$i++)
{
	$day=getdate($thisMonth[$i]);

	//create day instances
	eval("\$myDay".$i."=new myDay;");
	//eval("\$myDay".$i."->user=".$user->ID.";");
	eval("\$myDay".$i."->day=".$day[mday].";");
	eval("\$myDay".$i."->weekDayNum=".$day[weekday].";");
	eval("\$myDay".$i."->weekDay=".$day[wday].";");
	eval("\$myDay".$i."->month=".$day[month].";");
	eval("\$myDay".$i."->monthOfYear=".$day[mon].";");
	eval("\$myDay".$i."->year=".$day[year].";");
	eval("\$myDay".$i."->appointments=\"\";");

	eval("\$myday_ser".$i."=urlencode(serialize(\$myDay".$i."));");

	if ($day[mday]==$tag)
		echo "<td class=today align=center>";
	else
		echo "<td class=edit align=center>";

          echo "<a href=\"database.php?eTag=$day[mday]&eMonat=$day[mon]&eJahr=$day[year]&dir=$dir\" class=red>$day[mday]</a>\n </td>\n ";

	if ($day[wday]==0)
		print "</tr>\n<tr>";
}//end for

echo "</table>";

$lastMonth=getdate($thisMonth[0]);
$nextMonth=getDate($thisMonth[6]);
$lastMonthNr=$lastMonth[mon]-1;
$nextMonthNr=$nextMonth[mon]+1;

$lastday=getdate(mktime(0,0,0,$monatsNummer,$tag-1,$jahr));
$nextday=getdate(mktime(0,0,0,$monatsNummer,$tag+1,$jahr));

# << Day    Today    Day >>
print "<BR>";
#$dir=$_GET['dir'];
print "<a href=\"database.php?eTag=$lastday[mday]&eMonat=$lastday[mon]&eJahr=$lastday[year]&dir=$dir\" class=weiss><< Day</a>&nbsp;&nbsp;&nbsp;&nbsp";

print "<a href=\"database.php?dir=$dir\" class=weiss>Today</a>";

print "&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"database.php?eTag=$nextday[mday]&eMonat=$nextday[mon]&eJahr=$nextday[year]&dir=$dir\" class=weiss>Day >></a>";

# << Month     Month >>
print "<BR><BR>";
print "<a href=\"database.php?eTag=1&eMonat=$lastMonthNr&eJahr=$lastMonth[year]&dir=$dir\" class=weiss><< Month</a>&nbsp;&nbsp";


print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"database.php?eTag=1&eMonat=$nextMonthNr&eJahr=$nextMonth[year]&dir=$dir\" class=weiss>Month >></a>";
