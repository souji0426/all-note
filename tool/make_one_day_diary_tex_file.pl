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

  my $target_yyyymmdd;
  if ( @ARGV == 0 ) {
    $target_yyyymmdd = get_today_yyyymmdd();
  } elsif ( @ARGV == 1 ) {
    $target_yyyymmdd = $ARGV[0];
  }

  make_one_day_diary_tex_file( $setting, $target_yyyymmdd );
}

sub make_one_day_diary_tex_file {
  my ( $setting, $target_yyyymmdd ) = @_;
  my $diary_tex_file_dir_path = decode( "utf8", $setting->{"make_one_day_dairy_tex_file"}->{"dairy_tex_file_dir_path"} );
  my $target_tex_path = $diary_tex_file_dir_path . "/subsection_${target_yyyymmdd}.tex";
  open( my $fh, ">", encode( "cp932", $target_tex_path ) );
  print $fh encode( "cp932", "\\documentclass\[C:/souji/all-note/note\]\{subfiles\}\n\n" );
  print $fh encode( "cp932", "\\begin\{document\}\n" );
  print $fh "\%${target_yyyymmdd}" . encode( "cp932", "の日記\n" );
  print_hidden_data_form( $fh, $setting );
  print $fh encode( "cp932", "\\end\{document\}" );
  close $fh;
}

sub print_hidden_data_form {
  my ( $fh, $setting ) =@_;
  my @hidden_data_name = split( ",", decode( "utf8", $setting->{"make_one_day_dairy_tex_file"}->{"hidden_data_name"} ) );

  print $fh encode( "cp932", "\n" );
  print $fh encode( "cp932", "\%隠し情報一覧\n" );
  foreach my $data_name ( @hidden_data_name ) {
    print $fh encode( "cp932", "\%${data_name}：\n" );
  }
  print $fh encode( "cp932", "\n" );
}

1;
