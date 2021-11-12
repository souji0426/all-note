use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use Config::Tiny;
#iniファイルを処理するのに使っている
use Time::Local;
#日付処理に利用

use lib "./";
use basic_subroutines;
#共通関数の呼び出し

main();

sub main {
  my $setting_ini_path = "./setting.ini";
  my $setting = Config::Tiny->read( $setting_ini_path );

  my $all_diary_month = get_all_diary_month( $setting );
  make_all_diary_section_tex_file( $setting, $all_diary_month );
}

sub get_all_diary_month {
  my ( $setting ) = @_;
  my @result;
  my $diary_chapter_dir_path = decode( "utf8", $setting->{"tool_for_diary"}->{"diary_chapter_dir_path"} );
  opendir( my $dh, encode( "cp932", $diary_chapter_dir_path ) );
  while ( my $name = readdir $dh ) {
    if ( $name eq "." or $name eq ".."  or $name =~ /.tex$/) {
      next;
    } else  {
      push( @result, $name );
    }
  }
  closedir $dh;
  return \@result;
}

sub make_all_diary_section_tex_file {
  my ( $setting, $all_diary_month ) = @_;
  my $diary_chapter_dir_path = decode( "utf8", $setting->{"tool_for_diary"}->{"diary_chapter_dir_path"} );
  foreach my $one_month_dir_name ( sort @$all_diary_month ) {
    my $target_dir = encode( "cp932", $diary_chapter_dir_path ) . "/" . $one_month_dir_name;
    my $diary_section_tex_file_name = get_section_tex_file_name( $one_month_dir_name );
    open( my $fh, ">", encode( "cp932", $diary_chapter_dir_path . "/" . $diary_section_tex_file_name ) );
    print $fh encode( "cp932", "\\documentclass\[C:/souji/all-note/note\]\{subfiles\}\n\n" );
    print $fh encode( "cp932", "\\begin\{document\}\n\n" );

    print_all_subsection_file_data( $fh, $diary_chapter_dir_path, $one_month_dir_name );

    print $fh encode( "cp932", "\\end\{document\}" );
    close $fh;
  }
}

sub get_section_tex_file_name {
  my ( $dir_name ) = @_;
  my ( $yyyy, $mm ) = ( substr( $dir_name, 8, 4), substr( $dir_name, 14, 2) );
  return "section_${yyyy}${mm}.tex";
}

sub print_all_subsection_file_data {
  my ( $fh, $diary_chapter_dir_path, $one_month_dir_name ) = @_;
  my $target_dir = encode( "cp932", $diary_chapter_dir_path ) . "/" . $one_month_dir_name;
  my $all_sub_diary_file_name = get_all_diary_file_name( $target_dir );
  foreach my $file_name ( sort @$all_sub_diary_file_name ) {
    my ( $title_of_diary, $label_of_diary ) = make_title_and_label( $file_name );
    print $fh encode( "cp932", "\\subsection\*\{${title_of_diary}\}\n" );
    my $file_path = $target_dir . "/" . $file_name;
    print $fh "\\subfile\{${file_path}\}\n";
    print $fh encode( "cp932", "\\label\{${label_of_diary}\}\n\n" );
  }
  print $fh encode( "cp932", "\n" );
}

sub get_all_diary_file_name {
  my ( $target_dir ) = @_;
  my @result;
  opendir( my $dh, $target_dir );
  while ( my $file_name = readdir $dh ) {
    if ( $file_name eq "." or $file_name eq ".." or $file_name =~ /backup$/ ) {
      next;
    }
    push( @result, $file_name );
  }
  closedir $dh;
  return \@result;
}

sub make_title_and_label {
  my ( $file_name ) = @_;
  my $yyyymmdd = substr( $file_name, length( "subsection_" ), 8 );
  my ( $yyyy, $mm, $dd ) = ( substr( $yyyymmdd, 0, 4 ), substr( $yyyymmdd, 3, 2 ), substr( $yyyymmdd, 6 , 2 ) );

  my $time = timelocal(0, 0, 0, $dd, $mm -1 , $yyyy + 1900 );
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$dmy) = localtime($time);
  my @wdays = ("日","月","火","水","木","金","土");
  my $youbi =  $wdays[$wday-1];

  my $title_of_diary = "${yyyy}年${mm}月${dd}日（${youbi}）";
  my $label_of_diary = "diary:${yyyymmdd}";
  return ( $title_of_diary, $label_of_diary );
}

1;
