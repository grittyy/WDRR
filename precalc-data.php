<?php
// WDRR
// Author: Chuan Wang
// Copyright (C) 2011, Ziding Zhang's Lab
// 2011-09

$slide =1;

$title = 'WDRR: WD40 Repeat Recognition';

$spname = array('at'=>'Arabidopsis thaliana', 'ce'=>'Caenorhabditis elegans', 'dm'=>'Drosophila melanogaster', 'dr'=>'Danio rerio', 'hs'=>'Homo sapiens', 'mm'=>'Mus musculus', 'np'=>'Nostoc punctiforme PCC 73102', 'pf'=>'Plasmodium falciparum', 'sc'=>'Saccharomyces cerevisiae');

$species = explode("\n", chop(`ls precalc/`) );


include_once 'php-ofc-library/open-flash-chart.php';

$animation_1 = 'pop';
$delay_1 = 0.5;
$cascade_1 = 1;

$title = new title( 'Distribution of WD40 proteins with different repeat numbers in 9 model organisms' );
$title->set_style( "{font-size: 16px; color: #000000; text-align: center;}" );

$bar_stack = new bar_stack();

$bar_stack->set_colours( array( '#00ff00', '#0000ff', '#ffff00', '#00ffff', '#99ff00',
                                '#999000', '#9900cc', '#00cc99', '#abcdef', '#0033cc', '#ddcc00',
								'#99ff99', '#660000', '#cc0099', '#aaaaaa', '#33cc66' ) );

$bar_stack->set_keys(
    array(
//        new bar_stack_key( '#ff0000', 'Less than 4', 13 ),
        new bar_stack_key( '#00ff00', '4', 13 ),
        new bar_stack_key( '#0000ff', '5', 13 ),
        new bar_stack_key( '#ffff00', '6', 13 ),
        new bar_stack_key( '#00ffff', '7', 13 ),
        new bar_stack_key( '#99ff00', '8', 13 ),
        new bar_stack_key( '#999000', '9', 13 ),
        new bar_stack_key( '#9900cc', '10', 13 ),
        new bar_stack_key( '#00cc99', '11', 13 ),
        new bar_stack_key( '#abcdef', '12', 13 ),
        new bar_stack_key( '#0033cc', '13', 13 ),
        new bar_stack_key( '#ddcc00', '14', 13 ),
        new bar_stack_key( '#99ff99', '15', 13 ),
        new bar_stack_key( '#660000', '16', 13 ),
        new bar_stack_key( '#cc0099', '17', 13 ),
        new bar_stack_key( '#aaaaaa', '18', 13 ),
        new bar_stack_key( '#33cc66', '18+', 13 ),
        )
    );

foreach ($species as $sp) {
	$num = array();
	$sum = 0;
//    for ($isp = 1; $isp<4; $isp++) {
//        $numwd = `grep '^$isp WD40-repeats found' precalc/$sp/*.wdr | wc -l`;
//        $num[0] += intval($numwd);
//    }
    for ($isp = 4; $isp<19; $isp++) {
        $numwd = `grep '^$isp WD40-repeats found' precalc/$sp/*.wdr | wc -l`;
        $num[] = intval($numwd);
		$sum += $numwd;
    }
    for ($isp = 19; $isp<50; $isp++) {
        $numwd = `grep '^$isp WD40-repeats found' precalc/$sp/*.wdr | wc -l`;
        $num[15] += intval($numwd);
    }
	$sum += $num[15];

	for ($jj=0; $jj<count($num); $jj++) {
		$num[$jj] = $num[$jj]/$sum*100;
	}

	$bar_stack->append_stack( $num );
}

$bar_stack->set_tooltip( '#x_label#<br>#key# repeats: #val#%' );
$bar_stack->set_on_click('barClicked');
$bar_stack->set_on_click_text('#key#');

$bar_stack->set_on_show(new bar_on_show($animation_1, $cascade_1, $delay_1));

$y = new y_axis();
$y->set_range( 0, 100, 10 );

$x_labels = new x_axis_labels();
$x_labels->rotate(-45);
$x_labels->set_size(13);
$x_labels->set_labels( array( $spname['at'], $spname['ce'], $spname['dm'], $spname['dr'], $spname['hs'], $spname['mm'], $spname['np'], $spname['pf'], $spname['sc'] ) );

$x = new x_axis();
$x->set_labels( $x_labels );

$tooltip = new tooltip();
$tooltip->set_hover();

$chart = new open_flash_chart();
$chart->set_title( $title );
$chart->add_element( $bar_stack );
$chart->set_x_axis( $x );
$chart->add_y_axis( $y );
$chart->set_tooltip( $tooltip );

echo $chart->toPrettyString();

?>
