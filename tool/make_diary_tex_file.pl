use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use Config::Tiny;
#iniファイルを処理するのに使っている
#use DateTime;
use Time::Local;


use lib "./";
use basic_subroutines;
#共通関数の呼び出し

main();

sub main {
  my $setting_ini_path = "./setting.ini";
  my $setting = Config::Tiny->read( $setting_ini_path );

  make_diary_tex_file( $setting );
}

sub make_diary_tex_file {
  my ( $setting ) = @_;
  my $dairy_tex_file_path = decode( "utf8", $setting->{"make_diary_tex_file"}->{"dairy_tex_file_path"} );
  open( my $fh, ">", encode( "cp932", $dairy_tex_file_path ) );
  print $fh encode( "cp932", "\\documentclass\[C:/souji/all-note/note\]\{subfiles\}\n\n" );
  print $fh encode( "cp932", "\\begin\{document\}\n\n" );

  print_all_sub_file_path( $setting, $fh );

  print $fh encode( "cp932", "\\end\{document\}" );
  close $fh;
}

sub print_all_sub_file_path {
  my ( $setting, $fh ) = @_;
  my $all_sub_diary_file_path = get_all_diary_file_path( $setting );
  foreach my $file_path ( sort @$all_sub_diary_file_path ) {
    my ( $title_of_diary, $label_of_diary ) = make_title_and_label( $setting, $file_path );
    print $fh encode( "cp932", "\\subsection\*\{${title_of_diary}\}\n" );
    print $fh encode( "cp932", "\\subfile\{${file_path}\}\n" );
    print $fh encode( "cp932", "\\label\{${label_of_diary}\}\n\n" );
  }
  print $fh encode( "cp932", "\n" );
}

sub make_title_and_label {
  my ( $setting, $file_path ) = @_;
  my $dairy_tex_file_dir_path = decode( "utf8", $setting->{"make_diary_tex_file"}->{"dairy_tex_file_dir_path"} );
  my $yyyymmdd = substr( $file_path, length( $dairy_tex_file_dir_path . "/subsection_" ), 8 );
  my ( $yyyy, $mm, $dd ) = ( substr( $yyyymmdd, 0, 4 ), substr( $yyyymmdd, 3, 2 ), substr( $yyyymmdd, 7 , 2 ) );

  my $time = timelocal(0, 0, 0, $dd, $mm -1 , $yyyy + 1900 );
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$dmy) = localtime($time);
  my @wdays = ("日","月","火","水","木","金","土");
  my $youbi =  $wdays[$wday-1];

  my $title_of_diary = "${yyyy}年${mm}月${dd}日（${youbi}）";
  my $label_of_diary = "diary:${yyyymmdd}";
  return ( $title_of_diary, $label_of_diary );
}

sub get_all_diary_file_path {
  my ( $setting ) = @_;
  my @result;
  my $dairy_tex_file_dir_path = decode( "utf8", $setting->{"make_diary_tex_file"}->{"dairy_tex_file_dir_path"} );
  opendir( my $dh, encode( "cp932", $dairy_tex_file_dir_path ) );
  while ( my $file_name = readdir $dh ) {
    if ( $file_name eq "." or $file_name eq ".." or $file_name =~ /backup$/ ) {
      next;
    }
    push( @result, "${dairy_tex_file_dir_path}/${file_name}" );
  }
  closedir $dh;
  return \@result;
}

1;
