use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
#iniファイルを処理するのに使っている
use File::Find;

require "C:/souji/all-note/tool/common.pl";

my $setting = &common::get_setting();
my $part_dir_path = $setting->{"path"}->{"part_dir"};
my $file_path_list = &common::get_all_file_path( $part_dir_path );

foreach my $file_path ( @$file_path_list ) {
  if ( $file_path !~ /\.tex$/ ) {
    unlink $file_path;
  }
}

1;
