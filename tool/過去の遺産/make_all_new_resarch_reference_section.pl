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
  my $target_reference_data = get_target_reference_data( $setting );
  make_all_new_resarch_reference_section_tex_file( $setting, $target_reference_data );
}

sub make_all_new_resarch_reference_section_tex_file {
  my ( $setting, $target_reference_data ) = @_;
  my $target_dir_path = decode( "utf8", $setting->{"tool_for_resarch_reference"}->{"resarch_reference_chapter_dir_path"} );
  foreach my $counter ( keys %$target_reference_data ) {
    my $tag = $target_reference_data->{$counter}->{"tag"};
    my $file_path = "${target_dir_path}/section_${tag}.tex";
    if ( !-f encode( "cp932", $file_path ) ) {
      open( my $fh, ">", encode( "cp932", $file_path ) );
      print $fh encode( "cp932", "\\documentclass\[C:/souji/all-note/note\]\{subfiles\}\n\n" );
      print $fh encode( "cp932", "\\begin\{document\}\n\n" );

      print $fh encode( "cp932", "\\subsection*\{基本情報\}\n" );
      print $fh encode( "cp932", "\\subfile\{${target_dir_path}/subsection_${tag}_reference_data.tex\}\n\n" );

      print $fh encode( "cp932", "\\subsection*\{非数学的情報まとめ\}\n\n" );

      print $fh encode( "cp932", "\\subsection*\{数学的事実まとめ\}\n\n" );

      print $fh encode( "cp932", "\\subsection*\{得られた知見・考察\}\n\n" );

      print $fh encode( "cp932", "\\end\{document\}\n" );
      close $fh;
    }
  }
}

1;
