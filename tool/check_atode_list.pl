use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use Config::Tiny;
#iniファイルを処理するのに使っている

use File::Copy;
use File::Copy::Recursive qw(rcopy);
#ファイルをコピーするために使っている

use lib "./";
use common_subroutines;
#共通関数の呼び出し

main();

sub main {
  my $setting_ini_path = "./setting.ini";
  my $setting = Config::Tiny->read( $setting_ini_path );
  my $all_note_dir = $setting->{"common"}->{"all_note_dir"};

  #common_subroutines::catch_all_subfile_tex_file
  #souji_noteでsubfileで呼び出されているtexファイル、そのtexファイルから呼び出されているtex、
  #という風に再帰的に呼びだしているtexファイル全てを絶対パスで入手
  #どのtexファイルでも絶対パスで書くよう習慣づけておくこと
  my $all_sub_tex_file_paths = catch_all_subfile_tex_file( $all_note_dir );

  #上記のtexファイルたちから「あとで書く」とメモしたものを集める
  my $data = get_data_of_atodekaku( $setting, $all_sub_tex_file_paths );

  output_data( $all_note_dir, $data );
}

sub get_data_of_atodekaku {
  my ( $setting, $all_sub_tex_file_paths ) = @_;
  my $data = {};
  my $ignore_file =  encode( "cp932", decode( "utf8", $setting->{"check_atode_list"}->{"ignore_file"}) );
  foreach my $file_path ( @$all_sub_tex_file_paths ) {
    if ( $file_path eq  $ignore_file  ) {
      next;
    }
    my $line_counter = 0;
    my $memo = "";
    my $start_line_counter;
    my $is_target_line = 0;
    open( my $fh, "<", $file_path );
    while( my $line = <$fh> ) {
      $line_counter++;
      $line = decode( "cp932", $line );
      if ( $line eq "%あとで書く\n"  ) {
        $start_line_counter = sprintf( "%04d", $line_counter );
      }
      if ( $is_target_line and $line ne "\\end\{comment\}\n" ) {
        $memo = $memo . $line;
      }
      if ( $line eq "\\begin\{comment\}\n" ) {
        $is_target_line = 1;
      } elsif ( $line eq "\\end\{comment\}\n" ) {
        $data->{$file_path}->{$start_line_counter} = encode( "cp932", $memo );
        $memo = "";
        $start_line_counter = 0;
        $is_target_line = 0;
      }
    }
  }
  return $data;
}

sub output_data {
  my ( $target_dir, $data ) = @_;
  open( my $fh, ">", encode( "cp932", "${target_dir}あとで書くリスト.txt" ) );
  foreach my $file_path ( keys %$data ) {
    print $fh $file_path . encode( "cp932", "で見つけたメモ". "-" x 10 . "\n\n" );
    foreach my $line_counter ( sort keys %{$data->{$file_path}} ) {
      print  $fh sprintf( "%d", $line_counter ) . encode( "cp932", "行で発見。↓その内容\n" );
      print $fh $data->{$file_path}->{$line_counter};
      print $fh "\n";
    }
  }
  close( $fh );
}


1;
