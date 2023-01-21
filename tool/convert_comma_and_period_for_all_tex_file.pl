use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;

require "C:/souji/all-note/tool/common.pl";

my $setting = &common::get_setting();
my $target_path = $setting->{"path"}->{"all_note_dir"};

my $all_path_list = &common::get_all_file_path( $target_path );

foreach my $file_path ( @$all_path_list ) {
  if ( $file_path =~ /\.tex$/ ) {
    print $file_path . "\n";
    system( "perl -w convert_comma_and_period.pl ${file_path}" );
  }
}


1;
