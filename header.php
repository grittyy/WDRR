<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><?php echo $title; ?></title>
<link href="wdrr.css" rel="stylesheet" type="text/css" />
<?php
if ($slide == 1) {
  echo '<script type="text/javascript" src="slidingpanel-1.js"></script> 
<script type="text/javascript"> 
<!--
var slidingPanel            = null,
	slowSlidingPanel        = null,
	matteSlidingPanel       = null,
	iconSlidingPanel        = null,
	labelSlidingPanel       = null,
	iconLabelSlidingPanel   = null;
 
function setup() {
	//slidingPanel2_help = new SlidingPanel(\'panel2_help\');
	slidingPanel_opt = new SlidingPanel(\'opt\');
}//end setup()
-->
</script>';
?>
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-29061411-1']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

<script type="text/javascript" src="js/swfobject.js"></script>
<script type="text/javascript">

swfobject.embedSWF(
"open-flash-chart.swf", "my_chart",
"700", "700", "9.0.0", "expressInstall.swf",
{"data-file":"precalc-data.php", "loading":"Please wait while calculating..."} );

function barClicked(index, onClickText)
{
   window.location = 'precalc-list.php?' + 'oid=' + index + '&r=' + encodeURIComponent(onClickText);
}

</script>

</head>
 
<body onload="setup()">
<?php
} else {
  echo '</head>
 
<body>
';
}
?>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td align="center" class="title"><br />
      <a href="."><strong>WDRR</strong>: <strong>WD</strong>40 <strong>R</strong>epeat <strong>R</strong>ecognition</a><br />
    </td>
  </tr>
  <tr>
    <td align="center">
      <table width="1000" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
          <td align="right"><a href=".">[HOME]</a>&nbsp;&nbsp;&nbsp;<a href="./joblist.php">[JOB LIST]</a>&nbsp;&nbsp;&nbsp;<a href="./precalc.php">[PRE-CALCULATED RESULTS]</a>&nbsp;&nbsp;&nbsp;<a href="./visitors.php">[VISITORS]</a>&nbsp;&nbsp;&nbsp;<a href="./about.php">[ABOUT]</a></td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td align="center"><hr align="center" width="1000" size="1" noshade="noshade" /></td>
  </tr>
  <tr>
    <td align="center">
