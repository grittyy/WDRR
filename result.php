<?php
// WDRR
// Author: Chuan Wang
// Copyright (C) 2011, Ziding Zhang's Lab
// 2011-09

$jobid = $_GET[jobid];

$title = "JobID: $jobid - WDRR: WD40 Repeat Recognition";

include('header.php');

$refresh = rand(5,10);

$cmdfile = "tmp/$jobid/cmd";
$psall   = "ps aux | grep apache | grep wdrr | wc -l";

$runtime = "tmp/$jobid/starttime";
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

echo "<table width=\"776\" border=\"0\" cellspacing=\"0\" cellpadding=\"5\">
	  <tr>
		<td align=\"left\">";

if (file_exists("$outfile") && filesize($outfile)>0 && file_exists("$htmlfile") && filesize($htmlfile)>0) {
	$cost = filemtime($outfile) - $jobtime;
	//$result = file_get_contents("$outfile");
	$result = file_get_contents("$htmlfile");
	echo "<strong>JobID: $jobid</strong>&nbsp;&nbsp;&nbsp;&nbsp;Submitted: ".date('Y-m-d H:i:s', substr($jobid, 5))."<br /><br />";
	echo "You can bookmark this page for further accessing the result in the future.<br />Results on this server will be retained for 30 days.<br /><br />Job status:&nbsp;&nbsp;[<strong><font color=green>Done</font></strong>] Total run time: <strong>$cost</strong> seconds.&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"$outfile\">[Download result as txt]</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"$seqfile\">[Query sequence in FASTA]</a><div class='box'>$result</div>";
	system("rm -rf tmp/$jobid/seq.fasta.bst >/tmp/null 2>&1 &");
	system("rm -rf tmp/$jobid/seq.fasta.pfl >/tmp/null 2>&1 &");
	system("rm -rf tmp/$jobid/seq.fasta.pssm >/tmp/null 2>&1 &");
	//system("rm -rf tmp/$jobid/seq.fasta.ss2 >/tmp/null 2>&1 &");
//} elseif (file_exists("$errfile") && filesize($errfile)>0 && `$psgrep` < 2) {
} elseif (file_exists("$errfile") && `$psgrep` < 2) {
	$cost = filemtime($errfile) - $jobtime;
	$result = file_get_contents("$errfile");
	$info = file_get_contents($seqinfo);
	echo "<strong>JobID: $jobid</strong>&nbsp;&nbsp;&nbsp;&nbsp;Submitted: ".date('Y-m-d H:i:s', substr($jobid, 5))."<br /><br />";
	echo "Job status:&nbsp;&nbsp;[<strong><font color=red>Error</font></strong>] Total run time: <strong>$cost</strong> seconds.&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"$seqfile\">[Query sequence in FASTA]</a><div class='box'><pre>$info$result</pre></div>";
	system("rm -rf tmp/$jobid/seq.fasta.bst >/tmp/null 2>&1 &");
	system("rm -rf tmp/$jobid/seq.fasta.pfl >/tmp/null 2>&1 &");
	system("rm -rf tmp/$jobid/seq.fasta.pssm >/tmp/null 2>&1 &");
	//system("rm -rf tmp/$jobid/seq.fasta.ss2 >/tmp/null 2>&1 &");
} elseif (`$psgrep` > 0 && file_exists("$runtime")) {
	$duration = time() - $jobtime;
	if ($duration > 30) $refresh = 30;
	$info = file_get_contents($seqinfo);
	echo "<strong>JobID: $jobid</strong>&nbsp;&nbsp;&nbsp;&nbsp;Submitted: ".date('Y-m-d H:i:s', substr($jobid, 5))."&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"$errfile\" target=\"_blank\">[View STDERR file]</a><br /><br />This page will update automatically after <strong><font size=5 color=green>".$refresh."</font></strong> seconds.<br />You can bookmark this page for accessing the result in the future.<br />Close this page will not affect the result.<br /><br />Job status:&nbsp;&nbsp;[<strong><font color=blue>Running</font></strong>] <strong>$duration</strong> seconds. Please wait...<div class='box'><pre>$info</pre></div>";
	header("refresh: ".$refresh);
} elseif (file_exists("$cmdfile") && !file_exists("$runtime")) {
	$jobs = explode("\n", chop(`ls tmp/`));
	$early = 0;
//	foreach ($jobs as $jobone) {
//		if (substr($jobone,5) < substr($jobid,5) && !file_exists("tmp/$jobone/starttime")) {
//			$early = 1;
//			break;
//		}
//	}

	if (`$psall` > 5 || $early == 1) {
		echo "<strong>JobID: $jobid</strong>&nbsp;&nbsp;&nbsp;&nbsp;Submitted: ".date('Y-m-d H:i:s', substr($jobid, 5))."&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"$errfile\" target=\"_blank\">[View STDERR file]</a><br /><br />This page will update automatically after <strong><font size=5 color=green>".$refresh."</font></strong> seconds.<br />You can add this page to favorites to access the result in the future.<br />Do <strong>NOT</strong> close this page, or your job will not be submitted until your open this page again.<br /><br />Job status:&nbsp;&nbsp;[<strong><font color=grey>Queued</font></strong>] Please wait...<br />";
		header("refresh: ".$refresh);
	} else {
		echo "<strong>JobID: $jobid</strong>&nbsp;&nbsp;&nbsp;&nbsp;Submitted: ".date('Y-m-d H:i:s', substr($jobid, 5))."&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"$errfile\" target=\"_blank\">[View STDERR file]</a><br /><br />This page will update automatically after <strong><font size=5 color=green>".$refresh."</font></strong> seconds.<br />You can add this page to favorites to access the result in the future.<br />Close this page will not affect the result.<br /><br />Job status:&nbsp;&nbsp;[<strong><font color=grey>Submitted</font></strong>] Please wait...<br />";
		$start = fopen("$runtime", "w");
		fwrite($start, time());
		fclose($start);
		system("sh $cmdfile");
		header("refresh: 0");
	}
} else {
	echo "Cannot find job whose JobID = <strong>$jobid</strong>.<br /><br />Job expired or deleted, please resubmit you job.";
}

echo "</td>
	  </tr>
	</table>
	";

$lmtime = filemtime($_SERVER['SCRIPT_FILENAME']);

include('footer.php');
?>
