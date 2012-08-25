<?php
/*****************************************************
* 
*	phpMyCalendar
*	Author: Balazs Bezeczky
*			phpMyCalendar@gmx.net
*	http://phpmycalendar.sourceforge.net/
*
*	Last Modified: April 23, 2003
*	Version: 1.1.2
*
*	Please read the README file for more information
*	to install see INSTALL
*
*****************************************************/


//********************************************
// You'll need to fill these things in

$myID="root";	//your username for the MySQL database
$myPwd="";	//your password for the MySQL database
$myHost="localhost";	//the host you're allowed to connect from
$myDB="myCalendar";	//the name of the db phpMyCalendar runs
$myUserTable="user";	//the table where the user infos are stored
$myDataTable="data";	//the table where the appointments are stored
$myAnnivTable="anniversaries";	//the table where the anniversaries are stored

//*******************************************

//leave these as they are
$resultat="";
$dataExists=false;

//require($languageFile);

//*** myUser object definition
class myUser
{
	var $ID;
	var $username;
	var $pwd;
	var $email;
	var $lang;

	//*** object constructor
	function myUser($ID,$username,$pwd,$email,$lang)
	{
		$this->ID=$ID;
		$this->username=$username;
		$this->pwd=$pwd;
		$this->email=$email;
		$this->lang=$lang;
	}//end myUser
}//end myUser

//*** myDay object definition
class myDay
{
	var $user;
	var $appointments;
	var $day;
	var $weekDay;
	var $weekDayNum;
	var $month;
	var $monthOfYear;
	var $year;
		
/*
	//*** object constructor
	function myDay($times, $date)
	{
		$this->$appointments=$times;
		$this->$date=$date;
	}//end myDay
*/
	//*** inserts an appointment into today's todo-list
	function add_appointment($time, $toDo)
	{
		$this->appointments[$time]=$toDo;
	}//end addAppointment

	//*** 
	function show_appointments($CSSclass)
	{
		$k=8;
		if (sizeof($this->appointments)==0)
			$this->appointments=array("eEight"=>"", "eNine"=>"", "eTen"=>"", "eEleven"=>"", "eTwelve"=>"", "eThirteen"=>"", "eFourteen"=>"", "eFifteen"=>"", "eSixteen"=>"", "eSeventeen"=>"", "eEighteen"=>"", "eNineteen"=>"", "eTwenty"=>"", "eTwentyone"=>"", "eTwentytwo"=>"");

		while (list($key,$value) = each($this->appointments))
		{
			if ($k < 10)
				$t="0".$k;
			else
				$t=$k;

			if (strcmp($value,"")==0)
				$value="&nbsp;";

			echo "
				<tr><td class=\"$CSSclass\" width=40 valign=top>
				<font class=black>$t:00</font></td><td class=\"$CSSclass\" width=160 valign=top>\n
				$value</td></tr>\n
				";
			$k++;
		}//end while
	}//end showAppointments

	//*** 
	function get_date()
	{
		return $this->day."-".$this->month."-".$this->year;
	}//end get_date

	//*** 
	function get_appointments()
	{
		return $this->appointments;
	}//end get_appointments
}//end myDay

//*** db_class object definition
class db_class
{
	var $connection;
	var $DB;
	var $sqlError;
	var $sqlErrNo;
	var $host;
	var $pwd;
	var $result;
	var $result_num;
	var $table;
	var $user;
	
	//*** object constructor
	function db_class($DB,$host,$pwd,$table,$user)
	{
		$this->DB=$DB;
		$this->host=$host;
		$this->pwd=$pwd;
		$this->table=$table;
		$this->user=$user;
	}//end 

	//*** connects to the db
	function db_connect()
	{
		if (!$this->connection = mysql_connect($this->host,$this->user,$this->pwd))
		{
			$this->sqlErrNo=mysql_errno();
			$this->sqlError=mysql_error();
			return false;
		}
		else
		{
			return true;
		}//end if
	}//end db_connect

	//*** closes connection to the db
	function db_disconnect()
	{
		if (mysql_close($this->connection))
			return true;
		else
			return false;
	}//end db_disconnect

	//*** runs an sql-query
	function db_query($query)
	{
		if (!$this->result=mysql_query($query))
		{
			$this->sqlErrNo=mysql_errno();
			$this->sqlError=mysql_error();
			return false;
		}
		else
		{
			if (strstr($query, "SELECT")!=false)
				$this->result_num=mysql_num_rows($this->result);
			return true;
		}//end if
	}//end db_query

	//*** selects a db
	function db_select_db()
	{
		if (mysql_select_db($this->DB,$this->connection))
		{
			return true;
		}
		else
		{
			$this->sqlErrNo=mysql_errno();
			$this->sqlError=mysql_error();
			return false;
		}//end if
	}//end db_select_db

	//*** returns the next row from the last query's result
	function db_next_result($type)
	{
		if (!$this->result)
		{
			$this->sqlErrNo=99;
			$this->sqlError="Result set is empty";
			return false;
		}
		else
		{
			if (strcmp($type, "")==0)
				return mysql_fetch_array($this->result);
			else
				return mysql_fetch_array($this->result, $type);
		}
	}//end db_next_result
}//end db_class


//*** logs some text into a logfile - used just for testing
function exec_log($text)
{
	$fp=fopen("/tmp/php_log.txt", "a");
	fwrite($fp,$text);
}//end exec_log


//*** sends username/password promt
function authenticate() 
{
    header("WWW-Authenticate: Basic realm=\"phpMyCalendar Login\"");
    header( "HTTP/1.0 401 Unauthorized");
    echo "You must enter a valid login ID and password to access this resource\n";
    exit;
}//end authenticate


//*** creates an instance of the user object
function createUser($userName)
{
	global $user, $db_com, $myUserTable;
	
	$db_com->db_query("SELECT * FROM ".$myUserTable." WHERE user='".$userName."'");
	if ($db_com->result_num==1)
	{
		$login=$db_com->db_next_result('');
		$user=new myUser($login[0],$login[1],$login[2],$login[3],$login[4]);
	}

}//end 


//*** checks the database for the entered username/password combination
function checkDB($userName,$pwd)
{
	global $user;

	createUser($userName);

	if ($user->username==$userName and $user->pwd == $pwd)
	{
		$cookieInfo=$user->username."_".$user->pwd;
		header ("Set-Cookie: phpMyCalendar=$cookieInfo; expires=Friday, 16-Jan-2037 00:00:00 GMT; path=/;"); 
		return true;
	}
	else
	{
		return false;
	}//end if
	
}//end checkDB


//*** check whether there is a cookie with stored username/password
function checkCookie()
{
	global $user, $HTTP_SERVER_VARS, $HTTP_COOKIE_VARS;

	$PHP_AUTH_PW=$HTTP_SERVER_VARS['PHP_AUTH_PW'];
	$PHP_AUTH_USER=$HTTP_SERVER_VARS['PHP_AUTH_USER'];
	$phpMyCalendar=$HTTP_COOKIE_VARS['phpMyCalendar'];
	
	//no cookie:
	if (strcmp($phpMyCalendar, "")==0)
	{
		if (checkDB($PHP_AUTH_USER, md5($PHP_AUTH_PW))==false)
			return false;
		else
			return true;
	}
	//cookie found:
	else
	{
		$login=explode("_", $phpMyCalendar);
		if (
			(strcmp($login[0], $PHP_AUTH_USER)!=0 or strcmp($login[1], md5($PHP_AUTH_PW))!=0)  and
			(checkDB($login[0], $login[1])==false)
			)
		{
			return false;
		}
		else
		{
			createUser($PHP_AUTH_USER);
			return true;
		}
	}//end if

}//end checkCookie


?>
