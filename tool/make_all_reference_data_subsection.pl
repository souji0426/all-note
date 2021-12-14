use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use Config::Tiny;
#iniファイルを処理するのに使っている

use lib "./";
use common_subroutines_for_resarch_reference;
#共通関数の呼び出し

main();

sub main {
  my $setting_ini_path = "./setting.ini";
  my $setting = Config::Tiny->read( $setting_ini_path );
  #common_subroutines_for_resarch_reference
  my $target_reference_data = get_target_reference_data( $setting );
  make_all_reference_data_subsection_tex_file( $setting, $target_reference_data );
}

sub make_all_reference_data_subsection_tex_file {
  my ( $setting, $target_reference_data ) = @_;
  my $target_dir_path = decode( "utf8", $setting->{"tool_for_resarch_reference"}->{"resarch_reference_chapter_dir_path"} );
  foreach my $counter ( keys %$target_reference_data ) {
    my $tag = $target_reference_data->{$counter}->{"tag"};
    my $file_path = "${target_dir_path}/subsection_${tag}_reference_data.tex";
    open( my $fh, ">", encode( "cp932", $file_path ) );
    print $fh encode( "cp932", "\\documentclass\[C:/souji/all-note/note\]\{subfiles\}\n\n" );
    print $fh encode( "cp932", "\\begin\{document\}\n\n" );
    print_data( $fh, $target_reference_data->{$counter}->{"data"} );
    print $fh encode( "cp932", "\\end\{document\}\n" );
    close $fh;
  }
}

sub print_data {
  my ( $fh, $target_data_ref ) = @_;
  print $fh encode( "cp932", "\\begin\{itemize\}\n" );
  my @one_data = @$target_data_ref;
  my $num_of_data = @one_data;
  for ( my $i = 0; $i < $num_of_data; $i++ ) {
    my $data = $one_data[$i];
    print $fh encode( "cp932", "\t\\item\[\] ${data}\n" );
  }
  print $fh encode( "cp932", "\\end\{itemize\}\n" );
}

1;
