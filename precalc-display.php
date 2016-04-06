<?php
// WDRR
// Author: Chuan Wang
// Copyright (C) 2011, Ziding Zhang's Lab
// 2011-09

if (!isset($_GET[oid])) header("location: precalc.php");
$spname = array('at'=>'Arabidopsis thaliana', 'ce'=>'Caenorhabditis elegans', 'dm'=>'Drosophila melanogaster', 'dr'=>'Danio rerio', 'hs'=>'Homo sapiens', 'mm'=>'Mus musculus', 'np'=>'Nostoc punctiforme PCC 73102', 'pf'=>'Plasmodium falciparum', 'sc'=>'Saccharomyces cerevisiae');

$species = explode("\n", chop(`ls precalc/`) );

$oid = $_GET[oid];
$acc = $_GET[acc];

$title = "Accession: $acc - WDRR: WD40 Repeat Recognition";

include('header.php');

$outfile = "precalc/$species[$oid]/$acc.fasta.wdr";
$htmlfile = "precalc/$species[$oid]/$acc.fasta.html";
$pngfile = "precalc/$species[$oid]/$acc.png";
$seqfile = "precalc/$species[$oid]/$acc.fasta";

if (file_exists("$runtime")) {
	$jobtime = file_get_contents("$runtime");
} else {
	$jobtime = substr($jobid, 5);
}

echo "<table width=\"776\" border=\"0\" cellspacing=\"0\" cellpadding=\"5\">
	  <tr>
		<td align=\"left\">";

if (file_exists("$outfile") && filesize($outfile)>0 && file_exists("$htmlfile") && filesize($htmlfile)>0) {
	$result = file_get_contents("$htmlfile");
	$result = preg_replace("/$acc.png/", $pngfile, $result);
	echo "<strong>Pre-calculated Results</strong> - <strong>Accession: $acc</strong>&nbsp;&nbsp;&nbsp;&nbsp;[<em><strong><font color=\"red\">".$spname[$species[$oid]]."</font></strong></em>]<br /><br />";
	echo "<a href=\"$outfile\">[Download result as txt]</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"$seqfile\">[Query sequence in FASTA]</a><div class='box'>$result</div>";
} else {
	echo "Cannot find entry whose Accession = <strong>$acc</strong>.<br /><br />";
}

echo "</td>
	  </tr>
	</table>
	";

$lmtime = filemtime($_SERVER['SCRIPT_FILENAME']);

include('footer.php');
?>
