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
  return Config::Tiny->read( encode( "cp932", $setting_ini_path ), "utf8" );
}
#ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
#ファイル・ディレクトリ一覧を取得
sub get_all_path {
  my ( $path ) = @_;
  $path = encode( "cp932", $path );
  my @path_list;
  find sub {
      my $file = $_;
      my $path = $File::Find::name;
      if ( $file ne "." and $file ne ".." ) {
        push( @path_list, $path );
      }
  }, $path;
  return \@path_list;
}

sub get_all_file_path {
  my ( $path ) = @_;
  my @all_file_path_list;
  my $all_path_list = get_all_path( $path );
  foreach my $target_path ( @$all_path_list ) {
    if ( -f $target_path ) {
      push( @all_file_path_list, $target_path );
    }
  }
  return \@all_file_path_list;
}

sub get_all_tex_file_path {
  my ( $path ) = @_;
  my @all_tex_file_path_list;
  my $all_path_list = get_all_path( $path );
  foreach my $target_path ( @$all_path_list ) {
    if ( -f $target_path and $target_path =~ /.tex$/ ) {
      push( @all_tex_file_path_list, $target_path );
    }
  }
  return \@all_tex_file_path_list;
}

sub get_ordered_subfile_list {
  my ( $file_list, $tex_file_path ) = @_;

  my $fh;
  if (  open( $fh, "<:encoding( cp932 )", $tex_file_path ) ) {

  } elsif ( open( $fh, "<:encoding( cp932 )", encode( "cp932", $tex_file_path ) ) ) {

  }

  while( my $line = <$fh> ) {
    #open( my $test_fh, ">>", "./text.txt" );
    #print $test_fh encode( "cp932", $line );
    #close $test_fh;
    chomp $line;
    if ( $line =~ /.subfile\{(.+)\}$/ ) {
      my $target_path = $1;
      my $setting = get_setting();
      my $all_note_tex_file_path = $setting->{"path"}->{"all_note_tex_file"};
      if ( $tex_file_path eq $all_note_tex_file_path ) {

        push( @$file_list,  $target_path );
        get_ordered_subfile_list( $file_list, $target_path );

      } else {
        my $setting = get_setting();
        my $part_dir_path = $setting->{"path"}->{"part_dir"};
        my $all_tex_file_path_list = &common::get_all_tex_file_path( $part_dir_path );
        foreach my $tex_file_path_in_list ( @$all_tex_file_path_list ) {
          $tex_file_path_in_list = decode( "cp932", $tex_file_path_in_list );
          if ($tex_file_path_in_list =~ /${target_path}$/ ) {
            push( @$file_list, $tex_file_path_in_list );
            get_ordered_subfile_list( $file_list, $tex_file_path_in_list );
          }
        }

      }
    }
  }
  close $fh;
}

sub get_part_data {
  my ( $file_path ) = @_;
  my $data = {};
  my $part_counter = 0;
  open( my $fh, "<:encoding( cp932 )", encode( "cp932", $file_path ) );
  while( my $line = <$fh> ) {
    chomp $line;
    if ( $line =~ /.subfile\{(.+)\}$/ ) {
      my $target_path = $1;
      $data->{sprintf( "%02d", $part_counter )}->{"path"} = $target_path;
      my @path_data = split( "/", $target_path );
      my $file_name = pop @path_data;
      if ( $file_name =~ /(.+)\.tex$/ ) {
        my @data = split( "_", $1 );
        my $part_name = pop @data;
        $data->{sprintf( "%02d", $part_counter )}->{"name"} = $part_name;
        $part_counter++;
      }
    }
  }
  close $fh;
  return $data;
}


1;
