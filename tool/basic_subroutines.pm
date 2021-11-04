use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use Config::Tiny;
use Time::Piece;
#日付操作に必要

#デバッグや無名配列の中身を確認するための開発サポート関数ーーーーーーーーーーーーーーーーーーーーーーーーーーーー
sub output_file {
  my ( $ref ) = @_;
  open( my $fh, ">", "./test.txt" );
  print $fh Dumper $ref;
  close $fh;
}


#ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

#ファイル・ディレクトリ操作関連ーーーーーーーーーーーーーーーーーーーーーーーーーーーー

#指定したディレクトリとその直下にあるディレクトリ全てに含まれるファイルのパスを返すサブルーチン。
sub get_file_path_in_dir_and_all_sub_dir {
  my ( $target_path ) = @_;
  my @file_paths;
  my @dir_paths = glob( $target_path . "/*" );
  foreach my $path ( @dir_paths ) {
    if ( -d $path ) {
      push ( @dir_paths, glob( $path . "/*" ) );
    } elsif ( -f $path ) {
      push ( @file_paths, $path );
    }
  }
  return \@file_paths;
}

#ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

#日付操作関連ーーーーーーーーーーーーーーーーーーーーーーーーーーーー

#今日の日付をyyyymmdd形式で取得して返す。
sub get_today_yyyymmdd {
  my $today = localtime;

  my $year = $today->year;
  my $month_str = sprintf( "%02d", $today->mon );
  my $day_str = sprintf( "%02d", $today->mday );

  return join( "", ( $year, $month_str, $day_str ) );
}

#ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー


1;
