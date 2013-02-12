<?php
/**
* @package WD-VIDEOS
* @subpackage flashSQL
* @version flashsql.php - Version 1
* @author Julien Veuillet - © wakdev Prod. [http://www.wakdev.com]
* @copyright Copyright(C) 2009 - Today. All rights reserved.
* @license GNU/GPL
*/

$host = "localhost";
$login = "root";
$password = "";
$database_name = "database";



if (isset($_POST["query"]) && $_POST["cmd"] == "query")
{

	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	echo "<root>\n";
	
	
	
	$database = mysql_connect($host, $login, $password) or die ("<checkchild error='errorconnexion'></checkchild>");	
	mysql_select_db($database_name, $database) or die ("<checkchild error='errorconnexion'></checkchild>");
	
	
	
	$query_result = mysql_query(stripslashes($_POST["query"]),$database) or die ("<checkchild error='errorquery'></checkchild>");
			
	$numfields = mysql_num_fields($query_result);
	

	for($i=0;$i<$numfields;$i++)
	{
		$fieldname[$i]=mysql_field_name($query_result, $i);
	}

	while($row=mysql_fetch_row($query_result))
	{
	
	   echo "<sqlresult>"; 
	   
		for($i=0;$i<$numfields;$i++)
		{
			echo "<field name='".$fieldname[$i]."'>";
			echo "<value><![CDATA[".utf8_encode($row[$i])."]]></value>";
			echo "</field>";
		}
		
		echo "</sqlresult>\n";
	}
	
	
	
	echo "</root>";
	echo "<checkchild error='noerror'></checkchild>";
	
	
	mysql_free_result($query_result); //libère la mémoire
		
	mysql_close();
}


if (isset($_POST["query"]) && $_POST["cmd"] == "command")
{
	
	$database = mysql_connect($host, $login, $password) or die ("");	
	mysql_select_db($database_name, $database) or die ("");
	
	$query_result = mysql_query(stripslashes($_POST["query"]),$database) or die ("<checkchild error='errorquery'></checkchild>");
	
	mysql_free_result($query_result); //libère la mémoire
		
	mysql_close();
}


?>