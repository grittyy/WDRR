<?php
// WDRR
// Author: Chuan Wang
// Copyright (C) 2010, Ziding Zhang's Lab
// 2010-07

if (!isset($_GET[oid])) header("location: precalc.php");

$spname = array('at'=>'Arabidopsis thaliana', 'ce'=>'Caenorhabditis elegans', 'dm'=>'Drosophila melanogaster', 'dr'=>'Danio rerio', 'hs'=>'Homo sapiens', 'mm'=>'Mus musculus', 'np'=>'Nostoc punctiforme PCC 73102', 'pf'=>'Plasmodium falciparum', 'sc'=>'Saccharomyces cerevisiae');


$species = explode("\n", chop(`ls precalc/`) );

$oid = $_GET[oid];
$r = isset($_GET[r]) ? "$_GET[r]" : '4+';

if ($r == '4-') {
	$hitwd = explode("\n", chop(`grep '^[123] WD40-repeats found' precalc/$species[$oid]/*.wdr`));
} elseif ($r == '18+') {
	$hitwd = explode("\n", chop(`grep '^[1-9][0-9] WD40-repeats found' precalc/$species[$oid]/*.wdr | awk '{sub(/[^:]+:/,"",$1); if ($1>18){ print $0 }}' `));
} elseif ($r == 'all') {
	$hitwd = explode("\n", chop(`grep '^[0-9]* WD40-repeats found' precalc/$species[$oid]/*.wdr`));
} elseif ($r == '4+') {
	$hitwd = explode("\n", chop(`grep '^[0-9]* WD40-repeats found' precalc/$species[$oid]/*.wdr | awk '{sub(/[^:]+:/,"",$1); if ($1>3){ print $0 }}' `));
} else {
	$hitwd = explode("\n", chop(`grep '^$r WD40-repeats found' precalc/$species[$oid]/*.wdr`));
}

$title = $spname[$species[$oid]]." (with $r repeats) - WDRR: WD40 Repeat Recognition";

include('header.php');

$id = 0;

$num = count($hitwd);
$per = 40;
if (isset($_GET['page'])) {
	$page = $_GET['page'];
} else {
	$page = 1;
}
if ($page < 1) $page = 1;
$pages = intval(ceil($num/$per));
if ($page > $pages) $page = $pages;

echo "<strong>Pre-calculated Results</strong> - <em><strong><font color=\"red\">".$spname[$species[$oid]]."</font></strong></em> (with <strong><font color=\"blue\">$r</font></strong> repeats)<br />";

// page navigator
echo '<table width="1000" align="center" border="0" cellpadding="0" cellspacing="0"><tr><td align="center"><div align="right">'.(($page-1)*$per+1).'-';
if ($num > $page*$per) {
	echo $page*$per;
} else {
	echo $num;
}
echo ' of '.$num.'&nbsp;&nbsp;&nbsp;&nbsp;';
if ($page > 1) {
	echo '<a href="precalc-list.php?oid='.$oid.'&r='.urlencode($r).'&page='.($page-1).'">&lt;prev</a>&nbsp;&nbsp;';
} else {
	echo '&lt;prev&nbsp;&nbsp;';
}
if ($page < $pages) {
	echo '<a href="precalc-list.php?oid='.$oid.'&r='.urlencode($r).'&page='.($page+1).'">next&gt;</a>';
} else {
	echo 'next&gt;';
}
echo '</div></td></tr></table>';

// protein list table
echo "<table width=\"1000\" cellspacing=\"0\" cellpadding=\"0\" style=\"border-collapse:collapse;\" ><tr><td align=\"center\" valign=\"top\">";

echo "<table width=\"450\" border=\"1\" bordercolor=\"#999999\" cellspacing=\"0\" cellpadding=\"2\" style=\"border-collapse:collapse;\" class=\"list\" >";
echo "<tr><td align=\"center\"><strong>&nbsp;</strong></td>";
echo "<td align=\"center\"><strong>Accession</strong></td><td align=\"center\"><strong>Length</strong></td><td align=\"center\"><strong>Repeats</strong></td></tr>";

foreach ($hitwd as $hitid) {
	if (strlen($hitid) < 5) continue;
	if (++$id <= $per*($page-1)) continue;
	if ($id > $per*$page) break;

	if ($id == $per*$page-19) {
		echo "</table></td><td align=\"center\" valign=\"top\">";
		echo "<table width=\"450\" border=\"1\" bordercolor=\"#999999\" cellspacing=\"0\" cellpadding=\"2\" style=\"border-collapse:collapse;\" class=\"list\" >";
		echo "<tr><td align=\"center\"><strong>&nbsp;</strong></td>";
		echo "<td align=\"center\"><strong>Accession</strong></td><td align=\"center\"><strong>Length</strong></td><td align=\"center\"><strong>Repeats</strong></td></tr>";
	}

	$info = preg_match("/(\d+) WD40.+QUERY=(\S+) .+Len=(\d+)/s", $hitid, $match);
	
	$outfile = "precalc/$species[$oid]/$match[2].fasta.wdr";
	$htmlfile = "precalc/$species[$oid]/$match[2].fasta.html";
	$pngfile = "precalc/$species[$oid]/$match[2].png";

	echo "	  <tr>
			<td align=\"center\"><strong>$id</strong></td><td align=\"center\"><a href=\"precalc-display.php?oid=$oid&acc=$match[2]\" target=\"_blank\">$match[2]</a></td>";
	echo "<td align=\"center\">$match[3]</td><td align=\"center\">$match[1]</td>";
	echo "</tr>";
}

echo "	</table></td></tr></table>";

$lmtime = filemtime($_SERVER['SCRIPT_FILENAME']);

include('footer.php');
?>
