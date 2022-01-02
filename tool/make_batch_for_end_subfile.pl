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
  my $all_file_list_in_all_note_dir = get_file_path_in_dir_and_all_sub_dir( $all_note_dir . "/part" );
  my $end_file_list = get_all_end_subfile( $all_file_list_in_all_note_dir );
  my $target_file_list = delete_not_target_file_in_list( $end_file_list );
  make_batch( $target_file_list );
}

sub get_all_end_subfile {
  my ( $file_list ) = @_;
  my @result;
  foreach my $file_path ( @$file_list ) {
    if ( $file_path !~ /\.tex$/ ) {
      next;
    }
    if ( is_end_subfile( $file_path ) ) {
      push( @result, $file_path );
    }
  }
  return \@result;
}

sub is_end_subfile {
  my ( $file_path ) = @_;
  my $is_end_subfile = 1;
  my @file_data = split( "\/", $file_path );
  my $target_dir_path = make_dir_path( @file_data );
  my $file_name = pop @file_data;
  $file_name =~ s/\.tex//g;
  if ( -d "${target_dir_path}/${file_name}" ) {
    $is_end_subfile = 0;
  }
  return $is_end_subfile;
}

sub delete_not_target_file_in_list {
  my ( $file_list ) = @_;
  my @result;
  foreach my $file_path ( @$file_list ) {
    my $decoded_file_path = decode( "cp932", $file_path );
    if ( $decoded_file_path =~ /その他/ or $decoded_file_path =~ /情報一覧/  or $decoded_file_path =~ /test/ ) {
      next;
    }
    push( @result, $file_path );
  }
  return \@result;
}

sub make_batch {
  my ( $file_list ) = @_;
  foreach my $file_path ( @$file_list ) {
    $file_path =~ s/\/\//\//g;
    my @file_data = split( "\/", $file_path );
    my $target_dir_path = make_dir_path( @file_data );
    my $file_name = pop @file_data;
    $file_name =~ s/\.tex//g;
    my $batch_file_name = $file_name . "\.bat";
    open( my $fh, ">", "${target_dir_path}/${batch_file_name}" );
    print_operation( $fh, $target_dir_path, $file_name );
    close $fh;
  }
}

sub make_dir_path {
  my ( @file_data ) = @_;
  my $length = @file_data;
  my @data_for_dir_path = splice( @file_data, 0, $length-1 );
  return join( "\/", @data_for_dir_path );
}

sub print_operation {
  my ( $fh, $target_dir_path, $file_name ) = @_;
  print $fh "platex ${file_name}\n\n";
  print $fh "dvipdfmx ${file_name}\n\n";
  my @delete_target_extension = ( "aux", "dvi", "idx", "log", "out" );
  foreach my $extension ( @delete_target_extension ) {
    print $fh "del ${file_name}.${extension}\n\n";
  }
  print $fh "${file_name}.pdf";
}

1;
