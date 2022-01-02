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
  my $all_note_dir = $setting->{"common"}->{"all_note_dir"};

  #basic_subroutines
  my $all_file_list_in_all_note_dir = get_file_path_in_dir_and_all_sub_dir( $all_note_dir );
  my $subfile_list = get_subfile_in_file( $all_file_list_in_all_note_dir );
  my $not_exist_file_list = get_not_exist_file( $subfile_list );
  make_base_tes_file( $not_exist_file_list );
}

sub get_subfile_in_file {
  my ( $file_list ) = @_;
  my @result;
  foreach my $file_path ( @$file_list ) {
    if ( $file_path !~ /\.tex$/ ) {
      next;
    }
    get_subfile_in_one_file( \@result, $file_path );
  }
  return \@result;
}

sub get_subfile_in_one_file {
  my ( $list, $file_path ) = @_;
  open( my $fh, "<", $file_path );
  while( my $line = <$fh> ) {
    chomp $line;
    if ( $line =~ /\\subfile\{(.+)\}/ ) {
      push( @$list, $1 );
    }
  }
  close $fh;
}

sub get_not_exist_file {
  my ( $file_list ) = @_;
  my @result;
  foreach my $file_path ( @$file_list ) {
    if ( !-f $file_path ) {
      push( @result, $file_path );
    }
  }
  return \@result;
}

sub make_base_tes_file {
  my ( $file_list ) = @_;
  foreach my $file_path ( @$file_list ) {
    open( my $fh, ">", $file_path  );
    print $fh encode( "cp932", "\\documentclass\[C:/souji/all-note/note\]\{subfiles\}\n\n" );
    print $fh encode( "cp932", "\\begin\{document\}\n\n" );
    print $fh encode( "cp932", "\\end\{document\}" );
    close $fh;
    print encode( "cp932", "作成完了：" ) . "${file_path}\n";
  }
}

1;
