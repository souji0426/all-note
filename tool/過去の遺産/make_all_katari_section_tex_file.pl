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

  my $data_in_katari_list_csv = get_data_in_katari_list_csv( $setting );
  make_all_katari_section_tex_file( $setting, $data_in_katari_list_csv );
}

sub get_data_in_katari_list_csv {
  my ( $setting ) = @_;
  my $katari_csv_path = decode( "utf8", $setting->{"tool_for_katari"}->{"katari_csv_path"} );
  my %data;

  open( my $fh, "<", encode( "cp932", $katari_csv_path ) );
  while( my $line = <$fh> ) {
    chomp $line;
    my ( $category, $num, $title, $open_flag ) = split( "\t", decode( "utf8", $line ) );
    $data{$category, }{$num} = { "title" => $title, "open_flag" =>$open_flag };
  }
  close $fh;

  return \%data;
}

sub make_all_katari_section_tex_file {
  my ( $setting, $data_in_katari_list_csv ) = @_;
  my $katari_chapter_dir_path = decode( "utf8", $setting->{"tool_for_katari"}->{"katari_chapter_dir_path"} );
  my @order_of_section = split( ",", decode( "utf8", $setting->{"tool_for_katari"}->{"order_of_section"} ) );
  my $num_of_section = @order_of_section;
  for ( my $i = 0; $i < $num_of_section; $i++ ){
    my $category_name = $order_of_section[$i];
    my $target_dir = encode( "cp932", $katari_chapter_dir_path . "/" . $category_name );
    if ( !exists $data_in_katari_list_csv->{$category_name} ) {
      next;
    }
    my $katari_section_tex_file_name = "section_${category_name}.tex";
    open( my $fh, ">", encode( "cp932", $katari_chapter_dir_path . "/" . $katari_section_tex_file_name ) );
    print $fh encode( "cp932", "\\documentclass\[C:/souji/all-note/note\]\{subfiles\}\n\n" );
    print $fh encode( "cp932", "\\begin\{document\}\n\n" );

    print_all_subsection_file_data( $fh, $data_in_katari_list_csv, $katari_chapter_dir_path, $category_name );

    print $fh encode( "cp932", "\\end\{document\}" );
    close $fh;
  }
}

sub print_all_subsection_file_data {
  my ( $fh, $data_in_katari_list_csv, $katari_chapter_dir_path, $category_name ) = @_;
  my $target_dir = encode( "cp932", $katari_chapter_dir_path . "/section_" . $category_name );
  foreach my $num ( sort keys %{$data_in_katari_list_csv->{$category_name}} ) {
    my $file_name = encode( "cp932", $data_in_katari_list_csv->{$category_name}->{$num}->{"title"} );
    print $fh "\\subsection\*\{${file_name}\}\n";
    my $file_path = $target_dir . "/subsection_" . $file_name . ".tex";
    print $fh "\\subfile\{${file_path}\}\n";
    print $fh "\\label\{katari:${file_name}\}\n\n";
  }
  print $fh encode( "cp932", "\n" );
}

1;
