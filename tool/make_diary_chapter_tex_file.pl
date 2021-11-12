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

  my $all_diary_section_file_name = get_all_diary_section_file_name( $setting );
  make_diary_chapter_tex_file( $setting, $all_diary_section_file_name );
}

sub get_all_diary_section_file_name {
  my ( $setting ) = @_;
  my @result;
  my $diary_chapter_dir_path = decode( "utf8", $setting->{"tool_for_diary"}->{"diary_chapter_dir_path"} );
  opendir( my $dh, encode( "cp932", $diary_chapter_dir_path ) );
  while ( my $name = readdir $dh ) {
    if ( $name eq "." or $name eq ".."  ) {
      next;
    } elsif ( $name =~ /.tex$/ )  {
      push( @result, $name );
    }
  }
  closedir $dh;
  return \@result;
}

sub make_diary_chapter_tex_file {
  my ( $setting, $all_diary_section_file_name ) = @_;
  my $diary_chapter_tex_file_path = decode( "utf8", $setting->{"tool_for_diary"}->{"diary_chapter_tex_file_path"} );
  open( my $fh, ">", encode( "cp932", $diary_chapter_tex_file_path ) );
  print $fh encode( "cp932", "\\documentclass\[C:/souji/all-note/note\]\{subfiles\}\n\n" );
  print $fh encode( "cp932", "\\begin\{document\}\n\n" );

  print_all_section_file_data( $fh, $setting, $all_diary_section_file_name );

  print $fh encode( "cp932", "\\end\{document\}" );
  close $fh;
}

sub print_all_section_file_data {
  my ( $fh, $setting, $all_diary_section_file_name ) = @_;
  my $diary_chapter_dir_path = decode( "utf8", $setting->{"tool_for_diary"}->{"diary_chapter_dir_path"} );
  foreach my $file_name ( sort @$all_diary_section_file_name ) {

    my ( $title_of_diary, $label_of_diary ) = make_title_and_label( $file_name );
    print $fh encode( "cp932", "\\section\*\{${title_of_diary}\}\n" );
    my $file_path = $diary_chapter_dir_path . "/" . $file_name;
    print $fh encode( "cp932", "\\subfile\{${file_path}\}\n" );
    print $fh encode( "cp932", "\\label\{${label_of_diary}\}\n\n" );
  }
  print $fh encode( "cp932", "\n" );
}

sub make_title_and_label {
  my ( $file_name ) = @_;
  my $yyyymm = substr( $file_name, length( "section_" ), 6 );
  my ( $yyyy, $mm ) = ( substr( $yyyymm, 0, 4 ), substr( $yyyymm, 3, 2 ) );

  my $title_of_diary = "${yyyy}年${mm}月分";
  my $label_of_diary = "diary:${yyyymm}";
  return ( $title_of_diary, $label_of_diary );
}

1;
