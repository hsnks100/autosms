<?php 
//$tt = shell_exec("ls /home/gsoo/icpc");
//echo $tt;

//exec('cat /home/gsoo/public_html/test.pl', $output, $error);
//echo "<pre>";
//print_r($output);
//print_r($error);
//echo "</pre>";

$username = "gsoo";
$password = "asdqwe";

exec("/usr/bin/perl  /home/gsoo/public_html/test.pl ",$output, $error);
echo "<pre>";
print_r($output);
print_r($error);
echo "</pre>";
?>
