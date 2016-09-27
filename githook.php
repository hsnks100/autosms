<?php

//$output = shell_exec( 'cd /home/gsoo/public_html && git reset --hard HEAD && git pull origin master' );
//echo $output;
//echo "end";
//
shell_exec('cd /home/gsoo/public_html');
//exec("git add -A");
//exec('git commit -a -m "hook"');
exec("pwd && git pull" , $output, $error);
print_r($output);
print_r($error);

?>
