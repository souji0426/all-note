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
  make_resarch_reference_chapter_tex_file( $setting, $target_reference_data );
}

sub make_resarch_reference_chapter_tex_file {
    my ( $setting, $target_reference_data ) = @_;
    my $target_dir_path = decode( "utf8", $setting->{"tool_for_resarch_reference"}->{"resarch_reference_chapter_dir_path"} );
    my $target_tex_file_path = decode( "utf8", $setting->{"tool_for_resarch_reference"}->{"resarch_reference_chapter_tex_file_path"} );
    my $explanatory_tex_file_path = decode( "utf8", $setting->{"tool_for_resarch_reference"}->{"explanatory_tex_file_path"} );
    open( my $fh, ">", encode( "cp932", $target_tex_file_path ) );
    print $fh encode( "cp932", "\\documentclass\[C:/souji/all-note/note\]\{subfiles\}\n\n" );
    print $fh encode( "cp932", "\\begin\{document\}\n" );

    print $fh encode( "cp932", "\\subfile\{${explanatory_tex_file_path}\}\n" );

    foreach my $counter ( sort keys %$target_reference_data ) {
      my $tag = $target_reference_data->{$counter}->{"tag"};
      my $title = $target_reference_data->{$counter}->{"title"};
      print $fh encode( "cp932", "\n" );
      print $fh encode( "cp932", "\\section\{${title}\}\n" );
      print $fh encode( "cp932", "\\subfile\{${target_dir_path}section_${tag}.tex\}\n" );
      print $fh encode( "cp932", "\\label\{resarch_reference:${tag}\}\n" );
    }

    print $fh encode( "cp932", "\n" );
    print $fh encode( "cp932", "\\end\{document\}\n" );
    close $fh;
}

1;
