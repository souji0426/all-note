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
my $path_list;

find sub {
    my $file = $_;
    my $path = $File::Find::name;
    if ( $file ne "." and $file ne ".." and !-d $path ) {
      push( @$path_list, $path );
    }
}, $part_dir_path;

foreach my $path ( @$path_list ) {
  if ( $path !~ /\.tex$/ ) {
    unlink $path;
  }
}

1;
