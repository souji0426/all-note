use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use Config::Tiny;
#iniファイルを処理するのに使っている

use lib "./";
use basic_subroutines;
#共通関数の呼び出し

main();

sub main {
  my $setting_ini_path = "./setting.ini";
  my $setting = Config::Tiny->read( $setting_ini_path );
  my $all_note_dir = $setting->{"common"}->{"all_note_dir"};

  #basic_subroutines
  my $all_file_list_in_all_note_dir = get_file_path_in_dir_and_all_sub_dir( $all_note_dir . "/part" );
  delete_unnecessary_file( $all_file_list_in_all_note_dir );
}

sub delete_unnecessary_file {
  my ( $file_list ) = @_;
  foreach my $file_path ( @$file_list ) {
    if( $file_path =~ /\.pdf$/ or $file_path =~ /\.bat$/ ) {
      unlink $file_path;
    }
  }
}

1;
