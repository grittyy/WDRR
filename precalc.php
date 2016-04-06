<?php
// WDRR
// Author: Chuan Wang
// Copyright (C) 2011, Ziding Zhang's Lab
// 2011-09

$slide =1;

$title = 'Precalculated Results - WDRR: WD40 Repeat Recognition';

$spname = array('at'=>'Arabidopsis thaliana', 'ce'=>'Caenorhabditis elegans', 'dm'=>'Drosophila melanogaster', 'dr'=>'Danio rerio', 'hs'=>'Homo sapiens', 'mm'=>'Mus musculus', 'np'=>'Nostoc punctiforme PCC 73102', 'pf'=>'Plasmodium falciparum', 'sc'=>'Saccharomyces cerevisiae');

$species = explode("\n", chop(`ls precalc/`) );

include('header.php');

echo "<strong>PRE-CALCULATED RESULTS in 9 model organisms</strong>";
echo "<br /><br />";

echo "<table border=\"1\" cellspacing=\"0\" cellpadding=\"2\" style=\"border-collapse:collapse;border-color:#999999\" class=\"list\">";
echo "<tr><td align=\"center\" rowspan=\"2\"><strong>Organism</strong></td><td height=\"24\" align=\"center\" colspan=\"19\"><strong>WD40 repeat containing proteins of different repeat numbers</strong></td></tr><tr>";
echo "<td align=\"center\" width=\"32\" height=\"24\"><strong>&lt;4</strong></td>";
for ($isp = 4; $isp<19; $isp++) {
    echo "<td align=\"center\" width=\"32\"><strong>$isp</strong></td>";
}
echo "<td align=\"center\" width=\"32\"><strong>&gt;18</strong></td>";
echo "<td align=\"center\" width=\"32\"><strong>Total(all)</strong></td>";
echo "<td align=\"center\" width=\"32\"><strong>Total(&gt;3)</strong></td>";
echo "</tr>";

$oid = 0;
foreach ($species as $sp) {
    echo "<tr><td align=\"right\" height=\"24\"><em>$spname[$sp]</em></td>";
    $numlt4 = 0;
    $numgt18 = 0;
    $sumgt4 = 0;
    for ($isp = 1; $isp<4; $isp++) {
        $numwd = `grep '^$isp WD40-repeats found' precalc/$sp/*.wdr | wc -l`;
        $numlt4 += $numwd;
    }
    echo "<td align=\"center\"><a href=\"precalc-list.php?oid=$oid&r=4-\">$numlt4</a></td>";
    for ($isp = 4; $isp<19; $isp++) {
        $numwd = `grep '^$isp WD40-repeats found' precalc/$sp/*.wdr | wc -l`;
        $sumgt4 += $numwd;
		$numwd = $numwd == 0 ? $numwd : "<a href=\"precalc-list.php?oid=$oid&r=$isp\">$numwd</a>";
        echo "<td align=\"center\">$numwd</td>";
    }
    for ($isp = 19; $isp<50; $isp++) {
        $numwd = `grep '^$isp WD40-repeats found' precalc/$sp/*.wdr | wc -l`;
        $numgt18 += $numwd;
    }
    $sumgt4 += $numgt18;
    $sumall = $sumgt4 + $numlt4;
	$numgt18 = $numgt18 == 0 ? $numgt18 : "<a href=\"precalc-list.php?oid=$oid&r=18".urlencode('+')."\">$numgt18</a>";
    echo "<td align=\"center\">$numgt18</td>";
    echo "<td align=\"center\"><a href=\"precalc-list.php?oid=$oid&r=all\">$sumall</a></td>";
    echo "<td align=\"center\"><a href=\"precalc-list.php?oid=$oid&r=4".urlencode('+')."\">$sumgt4</a></td>";
    echo "</tr>";
	$oid++;
}

echo "</table><br />";

echo "<div id=\"my_chart\"></div>";

$lmtime = filemtime($_SERVER['SCRIPT_FILENAME']);

include('footer.php');
?>
