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

  my $dir_path = make_diary_month_dir( $setting, $target_yyyymmdd );
  make_one_day_diary_tex_file( $setting, $dir_path, $target_yyyymmdd );
}

sub make_diary_month_dir {
  my ( $setting, $target_yyyymmdd ) = @_;
  my $diary_chapter_dir_path = decode( "utf8", $setting->{"tool_for_diary"}->{"diary_chapter_dir_path"} );
  my ( $yyyy, $mm ) = ( substr( $target_yyyymmdd, 0, 4 ), substr( $target_yyyymmdd, 4, 2 ) );
  my $dir_name = "section_${yyyy}年${mm}月分";
  my $dir_path = $diary_chapter_dir_path . "/" . $dir_name;
  if ( !-d $dir_path ) {
    mkdir encode( "cp932", $dir_path );
  }
  return $dir_path;
}

sub make_one_day_diary_tex_file {
  my ( $setting, $dir_path, $target_yyyymmdd ) = @_;
  my $target_tex_path = $dir_path . "/subsection_${target_yyyymmdd}.tex";
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
  my @hidden_data_name = split( ",", decode( "utf8", $setting->{"tool_for_diary"}->{"hidden_data_name"} ) );

  print $fh encode( "cp932", "\n" );
  print $fh encode( "cp932", "\%隠し情報一覧\n" );
  foreach my $data_name ( @hidden_data_name ) {
    print $fh encode( "cp932", "\%${data_name}：\n" );
  }
  print $fh encode( "cp932", "\n" );
}

1;
