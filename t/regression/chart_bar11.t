###############################################################################
#
# Tests the output of Excel::Writer::XLSX against Excel generated files.
#
# Copyright 2000-2023, John McNamara, jmcnamara@cpan.org
#
# SPDX-License-Identifier: Artistic-1.0-Perl OR GPL-1.0-or-later
#

use lib 't/lib';
use TestFunctions qw(_compare_xlsx_files _is_deep_diff);
use strict;
use warnings;

use Test::More tests => 1;

###############################################################################
#
# Tests setup.
#
my $filename     = 'chart_bar11.xlsx';
my $dir          = 't/regression/';
my $got_filename = $dir . "ewx_$filename";
my $exp_filename = $dir . 'xlsx_files/' . $filename;

my $ignore_members  = [];

my $ignore_elements = {

    # Ignore the page margins.
    'xl/charts/chart1.xml' => [

        '<c:axId',
        '<c:crossAx',

        '<c:pageMargins',
    ],

    'xl/charts/chart2.xml' => [

        '<c:axId',
        '<c:crossAx',

        '<c:pageMargins',
    ],

    'xl/charts/chart3.xml' => [

        '<c:axId',
        '<c:crossAx',

        '<c:pageMargins',
    ],

};


###############################################################################
#
# Test the creation of a simple Excel::Writer::XLSX file.
#
use Excel::Writer::XLSX;

my $workbook  = Excel::Writer::XLSX->new( $got_filename );
my $worksheet = $workbook->add_worksheet();
my $chart1    = $workbook->add_chart( type => 'bar', embedded => 1 );
my $chart2    = $workbook->add_chart( type => 'bar', embedded => 1 );
my $chart3    = $workbook->add_chart( type => 'bar', embedded => 1 );


my $data = [
    [ 1, 2, 3, 4,  5 ],
    [ 2, 4, 6, 8,  10 ],
    [ 3, 6, 9, 12, 15 ],

];

# Turn off default URL format for testing.
$worksheet->{_default_url_format} = undef;

$worksheet->write( 'A1', $data );
$worksheet->write( 'A7', 'http://www.perl.com/' );
$worksheet->write( 'A8', 'http://www.perl.org/' );
$worksheet->write( 'A9', 'http://www.perl.net/' );

$chart1->add_series( values => '=Sheet1!$A$1:$A$5' );
$chart1->add_series( values => '=Sheet1!$B$1:$B$5' );
$chart1->add_series( values => '=Sheet1!$C$1:$C$5' );

$chart2->add_series( values => '=Sheet1!$A$1:$A$5' );
$chart2->add_series( values => '=Sheet1!$B$1:$B$5' );

$chart3->add_series( values => '=Sheet1!$A$1:$A$5' );

$worksheet->insert_chart( 'E9',  $chart1 );
$worksheet->insert_chart( 'D25', $chart2 );
$worksheet->insert_chart( 'L32', $chart3 );

$workbook->close();


###############################################################################
#
# Compare the generated and existing Excel files.
#

my ( $got, $expected, $caption ) = _compare_xlsx_files(

    $got_filename,
    $exp_filename,
    $ignore_members,
    $ignore_elements,
);

_is_deep_diff( $got, $expected, $caption );


###############################################################################
#
# Cleanup.
#
unlink $got_filename;

__END__



