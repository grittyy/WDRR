    </td>
  </tr>
  <tr>
    <td align="center"><hr align="center" width="1000" size="1" noshade="noshade" /></td>
  </tr>
  <tr>
    <td align="center">
      <table width="1000" align="center" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td width="25%" align="right">
<?php
if (preg_match("/visitors.php/", $_SERVER['SCRIPT_NAME'])) {
?>
<p id="logo"><a href="https://www.google.com/analytics/settings/home"></a></p>
<?php
}
?>
          </td>
          <td width="50%" align="center" valign="middle">
        Copyright &copy; 2012-2015 <a href="http://protein.cau.edu.cn" target="_blank">Ziding Zhang's Lab</a>, <a href="http://www.cau.edu.cn" target="_blank">China Agricultural University</a><br />
    Powered and maintained by <a href="mailto:grittyy-at-cau.edu.cn" target="_blank">Chuan Wang</a><br />Last modified: <?php echo date('d M Y', $lmtime); ?></td>
          <td width="25%" align="left">
          
<?php
if (preg_match("/index.php|about.php|visitors.php/", $_SERVER['SCRIPT_NAME'])) {
?>

<a href="http://www2.clustrmaps.com/counter/maps.php?url=http://protein.cau.edu.cn/gppat" id="clustrMapsLink"><img src="http://www2.clustrmaps.com/counter/index2.php?url=http://protein.cau.edu.cn/gppat" style="border:0px;" alt="Locations of visitors to this page" title="Locations of visitors to this page" id="clustrMapsImg" onerror="this.onerror=null; this.src='http://clustrmaps.com/images/clustrmaps-back-soon.jpg'; document.getElementById('clustrMapsLink').href='http://clustrmaps.com';" width="80" height="60" />
</a>

<?php
}
?>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
</body>
</html>
