<?php
// WDRR
// Author: Chuan Wang
// Copyright (C) 2011, Ziding Zhang's Lab
// 2011-09

$slide =1;

$title = 'WDRR: WD40 Repeat Recognition';

include('header.php');

?>
	  <script type="text/javascript">
		function example() {
			document.getElementById('seq').value = '>2AQ5:A|PDBID|CHAIN|SEQUENCE\n'+
						'MSRQVVRSSKFRHVFGQPAKADQCYEDVRVSQTTWDSGFCAVNPKFMALICEASGGGAFLVLPLGKTGRVDKNVPLVCGH\n'+
						'TAPVLDIAWCPHNDNVIASGSEDCTVMVWEIPDGGLVLPLREPVITLEGHTKRVGIVAWHPTAQNVLLSAGCDNVILVWD\n'+
						'VGTGAAVLTLGPDVHPDTIYSVDWSRDGALICTSCRDKRVRVIEPRKGTVVAEKDRPHEGTRPVHAVFVSEGKILTTGFS\n'+
						'RMSERQVALWDTKHLEEPLSLQELDTSSGVLLPFFDPDTNIVYLCGKGDSSIRYFEITSEAPFLHYLSMFSSKESQRGMG\n'+
						'YMPKRGLEVNKCEIARFYKLHERKCEPIAMTVPRKSDLFQEDLYPPTAGPDPALTAEEWLGGRDAGPLLISLKDGYVPPK\n'+
						'SR';
			return true;
		}
	  </script>	  
	  <form id="wdrr" name="wdrr" method="post" action="wdrr.php" enctype="multipart/form-data">
      <table width="600" border="0" cellspacing="0" cellpadding="5">
        <tr>
          <td align="center">Please paste your sequences in FASTA format (length &gt; 30, <a onclick="return example()" style="cursor: pointer;">example</a>), and then click &quot;<strong>Submit</strong>&quot; button.<br />
            <span style="font-size:11px;">(It would take about 80 seconds to recognize WD40-repeats in a 400 aa. length query sequence.)</span><br />
            <table width="600" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td align="center"><textarea name="seq" id="seq" cols="80" rows="10"></textarea></td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td align="center">Or upload your FASTA format sequence file, and then click &quot;<strong>Submit</strong>&quot; button.<br />
            <input type="file" name="seqfile" id="seqfile" />
          </td>
        </tr>
<!--
        <tr>
          <td align="center"><a href=# onclick="slidingPanel_opt.slide(); return false"><em><strong>Show options:</strong></em></a></td>
        </tr>
        <tr>
          <td align="center" valign="middle">
          <div id="opt" style="display:none">
          <table width="100%" border="0" cellspacing="0" cellpadding="5">
            <tr>
              <td width="25%" align="right" valign="top"><em>Scoring function</em></td>
              <td width="30%" align="left"><div id="scoringfunc">
                <label>
                  <input type="radio" name="scoring" value="b62" id="scoring_0" />
                  BLOSUM62</label>
                <br />
                <label>
                  <input type="radio" name="scoring" value="dp" id="scoring_1" />
                  Dot product</label>
                <br />
                <label>
                  <input type="radio" name="scoring" value="bdp" id="scoring_2" checked="checked" />
                  BLOSUM62 + Dot product</label>
                <br />
              </div></td>
              <td width="20%" align="right" valign="top"><em>P-value cutoff</em></td>
              <td align="left" valign="top">
                <label>
                  <select name="pvalue" id="pvalue">
                    <option value="0.0001">0.0001</option>
                    <option value="0.001">0.001</option>
                    <option value="0.005">0.005</option>
                    <option value="0.01" selected="selected">0.01</option>
                    <option value="0.05">0.05</option>
                    <option value="0.1">0.1</option>
                  </select>
                </label>
              </td>
            </tr>
            <tr>
              <td align="right" valign="top"><em>PSI-BLAST params</em></td>
              <td colspan="3" align="left"><label>
                Database 
                <select name="db" id="db" style="width:150px">
                  <option value="nrdb90">nrdb90 (291M,fast)</option>
                  <option value="nr90" selected="selected">nr90 (3.3G)</option>
                  <option value="nr">nr (8.1G,slow)</option>
                </select>
                </label>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <label>
                E-value
                  <select name="evalue" id="evalue">
                    <option value="0.0001">0.0001</option>
                    <option value="0.001" selected="selected">0.001</option>
                    <option value="0.01">0.01</option>
                    <option value="0.1">0.1</option>
                    <option value="1">1</option>
                    <option value="10">10</option>
                  </select>
                </label>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <label>Iteration
                <select name="iter" id="iter">
                  <option value="2">2</option>
                  <option value="3" selected="selected">3</option>
                  <option value="4">4</option>
                  <option value="5">5</option>
                  <option value="6">6</option>
                  <option value="7">7</option>
                  <option value="8">8</option>
                  <option value="9">9</option>
                  <option value="10">10</option>
                </select>
                </label></td>
            </tr>
          </table>
          </div>
          </td>
        </tr>
-->
        <tr>
          <td align="center"><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="100%" align="center">
                  <input type="submit" name="submit" id="submit" value="Submit" style="width:100px; height:48px" />
                  &nbsp;&nbsp;&nbsp;&nbsp;
                    <input type="reset" name="reset" id="reset" value="Reset" style="width:64px; height:24px" /></td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="5">
              <tr>
                <td align="left"><strong><em>For using WDRR, Please cite:</em></strong><br />
            Wang C, Dong X, Han L, Su XD, Zhang Z, Li J and Song J. (2015) <strong>WDRR: Identification of WD40 repeats by secondary structure aided profile-profile alignment</strong>, <em>submitted for publication. http://protein.cau.edu.cn/wdrr/</em>.
                </td>
             </tr>
            </table>
          </td>
        </tr>
      </table>
      </form>
<?php
$lmtime = filemtime($_SERVER['SCRIPT_FILENAME']);

include('footer.php');
?>
