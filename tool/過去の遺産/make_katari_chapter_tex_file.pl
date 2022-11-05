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

  my $all_katari_section_file_name = get_all_katari_section_file_name( $setting );
  make_katari_chapter_tex_file( $setting, $all_katari_section_file_name );
}

sub get_all_katari_section_file_name {
  my ( $setting ) = @_;
  my @result;
  my $katari_chapter_dir_path = decode( "utf8", $setting->{"tool_for_katari"}->{"katari_chapter_dir_path"} );
  opendir( my $dh, encode( "cp932", $katari_chapter_dir_path ) );
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

sub make_katari_chapter_tex_file {
  my ( $setting, $all_katari_section_file_name ) = @_;
  my $katari_chapter_tex_file_path = decode( "utf8", $setting->{"tool_for_katari"}->{"katari_chapter_tex_file_path"} );
  open( my $fh, ">", encode( "cp932", $katari_chapter_tex_file_path ) );
  print $fh encode( "cp932", "\\documentclass\[C:/souji/all-note/note\]\{subfiles\}\n\n" );
  print $fh encode( "cp932", "\\begin\{document\}\n\n" );

  print_all_section_file_data( $fh, $setting, $all_katari_section_file_name );

  print $fh encode( "cp932", "\\end\{document\}" );
  close $fh;
}

sub print_all_section_file_data {
  my ( $fh, $setting, $all_katari_section_file_name ) = @_;
  my $katari_chapter_dir_path = decode( "utf8", $setting->{"tool_for_katari"}->{"katari_chapter_dir_path"} );

  my @order_of_section = split( ",", decode( "utf8", $setting->{"tool_for_katari"}->{"order_of_section"} ) );
  my $num_of_section = @order_of_section;
  for ( my $i = 0; $i < $num_of_section; $i++ ){
    my $category_name = $order_of_section[$i];
    if ( !grep { $_ eq encode( "cp932", "section_${category_name}.tex" )} @$all_katari_section_file_name ) {
      next;
    }
    print $fh encode( "cp932", "\\section\{${category_name}\}\n");
    my $file_path = encode( "cp932", $katari_chapter_dir_path . "/section_${category_name}.tex");
    print $fh "\\subfile\{${file_path}\}\n";
    print $fh encode( "cp932", "\\label\{katari:${category_name}\}\n\n" );
  }
  print $fh encode( "cp932", "\n" );
}

1;
