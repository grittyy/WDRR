<?php
// WDRR
// Author: Chuan Wang
// Copyright (C) 2011, Ziding Zhang's Lab
// 2011-09

$title = "JobID: $jobid - WDRR: WD40 Repeat Recognition";

include('header.php');

$visits = explode("\n", chop(`ls -t visits/`));
$id = 0;
$ctime = date('Y-m-d H:i:s');

$num = 0 ;

foreach ($visits as $vf) {
	$fp = fopen("visits/$vf", 'r');	
	if ($fp) {	
		while(stream_get_line($fp,8192,"\n")){
		   $num++;
		}
	fclose($fp);
	}
}

$per = 15;
if (isset($_GET['page'])) {
	$page = $_GET['page'];
} else {
	$page = 1;
}
$pages = intval(ceil($num/$per));
if ($page > $pages) $page = $pages;
if ($page < 1) $page = 1;

echo "<strong>USER LIST</strong> - $ctime<br />";

// page navigator
echo '<table width="1000" align="center" border="0" cellpadding="0" cellspacing="0"><tr><td align="center"><div align="right">'.(($page-1)*$per+1).'-';
if ($num > $page*$per) {
	echo $page*$per;
} else {
	echo $num;
}
echo ' of '.$num.'&nbsp;&nbsp;&nbsp;&nbsp;';
if ($page > 1) {
	echo '<a href="visitors.php?page='.($page-1).'">&lt;prev</a>&nbsp;&nbsp;';
} else {
	echo '&lt;prev&nbsp;&nbsp;';
}
if ($page < $pages) {
	echo '<a href="visitors.php?page='.($page+1).'">next&gt;</a>';
} else {
	echo 'next&gt;';
}
echo '</div></td></tr></table>';

// visitor list table
echo "<table width=\"1000\" border=\"1\" bordercolor=\"#999999\" cellspacing=\"0\" cellpadding=\"2\" style=\"border-collapse:collapse;\" class=\"list\" >";
echo "<tr><td align=\"center\"><strong>ID</strong></td>";
if (preg_match("/10\.2\.43\.240/", $_SERVER['REMOTE_ADDR']) && $_SERVER['SERVER_ADDR'] == "202.112.170.199") echo "<td align=\"center\"><strong>JobID</strong></td>";
echo "<td align=\"center\"><strong>Submit time</strong></td><td align=\"center\"><strong>IP address</strong></td><td align=\"center\"><strong>Language</strong></td>";
echo "<td align=\"center\"><strong>User Agent</strong></td>";
echo "</tr>";

foreach ($visits as $file) {
	$lines = file("visits/$file");
	$lines = array_reverse($lines);
	foreach ($lines as $line) {
		if (strlen($line) < 5) continue;
		if (++$id <= $per*($page-1)) continue;
		if ($id > $per*$page) break;
		
		$row = explode('|', $line);
		
		echo "	  <tr>
				<td align=\"center\"><strong>$id</strong></td>";
		if (preg_match("/10\.2\.43\.240/", $_SERVER['REMOTE_ADDR']) && $_SERVER['SERVER_ADDR'] == "202.112.170.199") echo "<td align=\"left\"><a href=\"result.php?jobid=$row[2]\">$row[2]</a></td>";
		echo "<td><nobr>$row[0]</nobr></td><td><nobr>$row[1]</nobr></td><td><nobr>$row[3]</nobr></td>";
		echo "<td>$row[4]</td>";
		echo "</tr>";
	}
}

echo "	</table>";

?>

  <tr>
    <td align="center"><br />Your IP: <?php echo $_SERVER['REMOTE_ADDR']; ?>
    </td>
  </tr>

<?php
$lmtime = filemtime($_SERVER['SCRIPT_FILENAME']);

include('footer.php');
?>
