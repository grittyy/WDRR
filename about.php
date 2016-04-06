<?php
// WDRR
// Author: Chuan Wang
// Copyright (C) 2011, Ziding Zhang's Lab
// 2011-09

$title = "JobID: $jobid - WDRR: WD40 Repeat Recognition";

include('header.php');
?>

<table width="700" border="0" cellspacing="0" cellpadding="2" style="border-color:#EEEEEE" >
  <tr>
    <td align="center"><p>This server was constructed using the following systems and softwares:    
    </p>
    <p><img src="img/logo_rh_home.png" alt="RedHat Enterprise Linux 5" width="96" height="31" /><img src="img/apache.logo.jpg" alt="Apache" width="75" height="31" /><img src="img/php_log.png" alt="PHP" width="60" height="31" /><img src="img/camel_head.png" alt="Perl" width="30" height="31" /></p></td>
  </tr>
</table>

<?php
$lmtime = filemtime($_SERVER['SCRIPT_FILENAME']);

include('footer.php');
?>
