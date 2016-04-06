<?php
// WDRR
// Author: Chuan Wang
// Copyright (C) 2011, Ziding Zhang's Lab
// 2011-09

$title = 'WDRR: WD40 Repeat Recognition';

include('header.php');
//exit;
function randStr($i){
	$str = strtoupper("abcdefghijklmnopqrstuvwxyz0123456789");
	$finalStr = "";
	for($j=0;$j<$i;$j++){
		$finalStr .= substr($str,rand(0,35),1);
	}
	return $finalStr;
}

$jobid = randStr(5).time();

$seqfile = "tmp/$jobid/seq.fasta";
$outfile = "tmp/$jobid/$jobid.wdr";
$cmdfile = "tmp/$jobid/cmd";
$path = "../../bin";

// check data
$upload = 0;
if ($_POST['seq'] != '') {
	if (preg_match("/^>\S+[^\n]*\n([A-Za-z_ \n-]+)\*?/", $_POST['seq'], $tmpseq)) {
		if (strlen($tmpseq[1]) > 29) {
			mkdir("tmp/$jobid", 0777);
			$seqf = fopen("$seqfile","w");
			if (!preg_match("/^>/", $_POST['seq'])) {
				$seq = ">seq-$jobid\n";
			}
			fwrite($seqf, "$seq$_POST[seq]\n");
			fclose($seqf);
			$upload = 1;
		}
	}
} elseif (isset($_FILES['seqfile'])) {
	if (is_uploaded_file($_FILES['seqfile']['tmp_name'])) {
		if ($_FILES['seqfile']['size'] > 102400) {
			echo "<div valign=\"middle\" style=\"height:64px\"><strong>Error: Sequence file size must not beyond 100K!</strong></div>";
			unlink($_FILES['seqfile']['tmp_name']);
		} else {
			mkdir("tmp/$jobid", 0777);
			move_uploaded_file($_FILES['seqfile']['tmp_name'],"tmp/$jobid/seq.fasta");
			$upload = 1;
		}
	}
}

if ($upload == 1) {

	// record submit clients' info
	$vfile = "visits/log";
	if (file_exists($vfile)) {
		$tag="a";
		if (filesize($vfile) > 1000000) {
			$idx = chop(`ls visits/ | wc -l`);
			rename($vfile, $vfile.$idx);
			$tag="w";
		}
	} else {
		$tag="w";
	}
	$vis = fopen($vfile, $tag);
	fwrite($vis, date('Y-m-d H:i:s',substr($jobid,5))."|$_SERVER[REMOTE_ADDR]|$jobid|$_SERVER[HTTP_ACCEPT_LANGUAGE]|$_SERVER[HTTP_USER_AGENT]\n");
	fclose($vis);

	// submit job
	echo "<div valign=\"middle\" style=\"height:64px\">Submitting your job ($jobid)...</div>";

	if ($_POST[scoring] == 'b62') {
		$go = " -g 9";
		$ge = " -x 1";
	}
	if ($_POST[scoring] == 'dp') {
		$go = " -g 2";
		$ge = " -x 0";
	}
	if ($_POST[scoring] == 'bdp') {
		$go = " -g 50";
		$ge = " -x 3";
	}
	if ($_POST[scoring]) $gapparam = "-m $_POST[scoring] $go$ge";
	if ($_POST[db]) $gapparam .= " -d /home/pub/blastdb/$_POST[db]";
	if ($_POST[evalue])	$gapparam .= " -e $_POST[evalue]";
	if ($_POST[iter]) $gapparam .= " -j $_POST[iter]";

	//$cmd = "perl $path/wdrr.pl -i $seqfile $gapparam -cpu 3 -o $outfile 2>tmp/$jobid/seq.err >tmp/$jobid/seq.info &";
	$cmd = "cd tmp/$jobid\nperl $path/wdrr.pl -i seq.fasta $gapparam -cpu 3 -h 1 -o $jobid.wdr -html $jobid.html 2>seq.err >seq.info &\ncd ../../\n";
	
	$cmdf = fopen("$cmdfile", "w");
	fwrite($cmdf, $cmd);
	fclose($cmdf);
	//system("$cmd");
		
	header("location: result.php?jobid=$jobid");
} else {
	echo "<div valign=\"middle\" style=\"height:64px\"><strong>Error: Invalid sequence submitted!</strong></div><div align=\"center\"><pre>$_POST[seq]</pre></div>";
}

$lmtime = filemtime($_SERVER['SCRIPT_FILENAME']);

include('footer.php');
?>
