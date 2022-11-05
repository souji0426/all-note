package common;

use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use Config::Tiny;
use Time::Piece;
#日付操作に必要
use File::Find;

#ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
#開発サポート関数
sub print_debug_to_txt {
  my ( $ref ) = @_;
  open( my $fh, ">", "./test.txt" );
  print $fh Dumper $ref;
  close $fh;
}
#ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
#設定ファイル関連
sub get_setting {
  my $setting_ini_path = "C:/souji/all-note/tool/setting.ini";
  return Config::Tiny->read( $setting_ini_path );
}
#ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
#ファイル・ディレクトリデータ取得
sub get_dir_and_file_data {
  my ( $target_dir_path ) = @_;
  my $path_data = {};

  my $path_list;
  find sub {
      my $file = $_;
      my $path = $File::Find::name;
      if ( $file ne "." and $file ne ".." ) {
        push( @$path_list, $path );
      }
  }, $target_dir_path;

  foreach my $path ( @$path_list ) {
    if ( -d $path ) {
      if ( !exists $path_data->{"dir"} ) {
        $path_data->{"dir"} = {};
      }
      $path_data->{"dir"}->{get_dir_in_name( $path )} = {};
      $path_data->{"dir"}->{get_dir_in_name( $path )}->{"dir"} = get_dir_in_path( $path );
      $path_data->{"dir"}->{get_dir_in_name( $path )}->{"full_path"} = $path;
    } elsif ( -f $path ) {
      if ( !exists $path_data->{"file"} ) {
        $path_data->{"file"} = {};
      }
      $path_data->{"file"}->{get_dir_in_name( $path )} = {};
      $path_data->{"file"}->{get_dir_in_name( $path )}->{"dir"} = get_dir_in_path( $path );
      $path_data->{"file"}->{get_dir_in_name( $path )}->{"full_path"} = $path;
    }
  }
  return $path_data;
}
#ーーーーーーーーーーーーーーーーーーー
sub get_dir_in_path {
  my ( $path ) = @_;
  my @data = split( "/", $path );
  pop @data;
  return join( "/", @data );
}

sub get_dir_in_name {
  my ( $path ) = @_;
  my @data = split( "/", $path );
  return pop @data;
}
#ーーーーーーーーーーーーーーーーーーー
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
