<?php
// WDRR
// Author: Chuan Wang
// Copyright (C) 2010, Ziding Zhang's Lab
// 2010-07

function cmp($a, $b) {
	if (substr($a, 5) == substr($b, 5)) return 0;
	return substr($a, 5) < substr($b, 5) ? 1:-1;
}


$title = "Job List - WDRR: WD40 Repeat Recognition";

include('header.php');

if (isset($_GET['deletejob']) && $_SERVER['REMOTE_ADDR'] == "10.2.43.113") system("rm -rf tmp/$_GET[deletejob]");


$jobs = explode("\n", chop(`ls tmp/`));
usort($jobs, "cmp");
$id = 0;
$ctime = date('Y-m-d H:i:s');

$num = count($jobs);
$per = 15;
if (isset($_GET['page'])) {
	$page = $_GET['page'];
} else {
	$page = 1;
}
if ($page < 1) $page = 1;
$pages = intval(ceil($num/$per));
if ($page > $pages) $page = $pages;

echo "<strong>JOB LIST</strong> - $ctime<br />";

// page navigator
echo '<table width="1000" align="center" border="0" cellpadding="0" cellspacing="0"><tr><td align="center"><div align="right">'.(($page-1)*$per+1).'-';
if ($num > $page*$per) {
	echo $page*$per;
} else {
	echo $num;
}
echo ' of '.$num.'&nbsp;&nbsp;&nbsp;&nbsp;';
if ($page > 1) {
	echo '<a href="joblist.php?page='.($page-1).'">&lt;prev</a>&nbsp;&nbsp;';
} else {
	echo '&lt;prev&nbsp;&nbsp;';
}
if ($page < $pages) {
	echo '<a href="joblist.php?page='.($page+1).'">next&gt;</a>';
} else {
	echo 'next&gt;';
}
echo '</div></td></tr></table>';

// job list table
echo "<table width=\"1000\" border=\"1\" bordercolor=\"#999999\" cellspacing=\"0\" cellpadding=\"2\" style=\"border-collapse:collapse;\" class=\"list\" >";
echo "<tr><td align=\"center\"><strong>&nbsp;</strong></td><td align=\"center\"><strong>JobID</strong></td>";
echo "<td align=\"center\"><strong>Query</strong></td><td align=\"center\"><strong>Len</strong></td><td align=\"center\"><strong>SF</strong></td><td align=\"center\"><strong>DB</strong></td><td align=\"center\"><strong>E-value</strong></td><td align=\"center\"><strong>Iter</strong></td>";
echo "<td align=\"center\"><strong>Submit time</strong></td><td align=\"center\"><strong>Run(s)</strong></td><td align=\"center\"><strong>Status</strong></td><td align=\"center\"><strong>Rpts</strong></td>";

if (preg_match("/10\.2\.43\.113/", $_SERVER['REMOTE_ADDR']) && $_SERVER['SERVER_ADDR'] == "202.112.170.199") echo "<td align=\"center\"><strong>Del</strong></td>";
echo "</tr>";

foreach ($jobs as $jobid) {
	if (strlen($jobid) < 5) continue;
	if (++$id <= $per*($page-1)) continue;
	if ($id > $per*$page) break;
	
	$runtime = "tmp/$jobid/starttime";
	$cmdfile = "tmp/$jobid/cmd";
	$outfile = "tmp/$jobid/$jobid.wdr";
	$htmlfile = "tmp/$jobid/$jobid.html";
	$seqfile = "tmp/$jobid/seq.fasta";
	$seqinfo = "tmp/$jobid/seq.info";
	$errfile = "tmp/$jobid/seq.err";
	$psgrep  = "ps aux | grep apache | grep wdrr | grep $jobid | wc -l";

	if (file_exists("$runtime")) {
		$jobtime = file_get_contents("$runtime");
	} else {
		$jobtime = substr($jobid, 5);
	}
	
	$out  = file_get_contents($seqinfo);
	$info = preg_match("/Query = (\S+) \(Len=(\d+)\).*Method = (\S+)  /s", $out, $match);
	$info = preg_match("/Database = (\S+)  E-value = (\S+)  Iteration = (\d+)/s", $out, $match2);
	$info = preg_match("/(\S+) WD40-repeats/s", $out, $rpts);
	if ($rpts[1] == 'No') $rpts[1] = 0;
	
	echo "	  <tr>
			<td align=\"center\"><strong>$id</strong></td><td align=\"center\"><a href=\"result.php?jobid=$jobid\">$jobid</a></td>";
	echo "<td align=\"center\">$match[1]</td><td align=\"center\">$match[2]</td><td align=\"center\">$match[3]</td><td align=\"center\">$match2[1]</td><td align=\"center\">$match2[2]</td><td align=\"center\">$match2[3]</td>";
	
	if (file_exists("$outfile") && filesize($outfile)>0 && file_exists("$htmlfile") && filesize($htmlfile)>0) {
		$cost   = filemtime($outfile) - $jobtime;
		$result = "Done";
		$scolor = "#BBFFBB";
	//} elseif (file_exists("$errfile") && filesize($errfile)>0 && `$psgrep` < 2) {
	} elseif (file_exists("$errfile") && `$psgrep` < 2) {
		$cost   = filemtime($errfile) - $jobtime;
		$result = "Error";
		$scolor = "#FFBBBB";
	} elseif (`$psgrep` > 0 && file_exists("$runtime")) {
		$cost   = time() - $jobtime;
		$result = "Running";
		$scolor = "#BBBBFF";
	} elseif (file_exists("$cmdfile") && !file_exists("$runtime")) {
		$cost   = "0";
		$result = "Queued";
		$scolor = "#CCCCCC";
	} else {
		$cost   = filemtime($errfile) - $jobtime;
		$result = "Error";
		$scolor = "#FFBBBB";
	}
	echo "<td align=\"center\">".date('Y-m-d H:i:s', substr($jobid, 5))."</td><td align=\"center\">$cost</td><td align=\"center\" bgcolor=\"$scolor\"><a href=\"result.php?jobid=$jobid\">$result</a></td><td align=\"center\">$rpts[1]</td>";
	if (preg_match("/10\.2\.43\.113/", $_SERVER['REMOTE_ADDR']) && $_SERVER['SERVER_ADDR'] == "202.112.170.199") {
		echo "<td align=\"center\">";
		if ($result != 'Queued' && $result != 'Running') echo "<a href=\"joblist.php?page=$page&deletejob=$jobid\">X</a>";
		echo "</td>";
	}
	echo "</tr>";
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
