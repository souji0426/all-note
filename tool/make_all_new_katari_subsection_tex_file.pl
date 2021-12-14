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

  my $all_katari_list = get_data_in_katari_list_csv( $setting );
  my $title_list = get_all_title( $all_katari_list );
  my $old_title_list = get_all_old_title( $setting );
  make_new_dir_and_subsection_tex_file( $setting, $title_list, $old_title_list );
}

sub get_data_in_katari_list_csv {
  my ( $setting ) = @_;
  my $katari_csv_path = decode( "utf8", $setting->{"tool_for_katari"}->{"katari_csv_path"} );
  my %data;

  open( my $fh, "<", encode( "cp932", $katari_csv_path ) );
  while( my $line = <$fh> ) {
    chomp $line;
    my ( $category, $num, $title, $open_flag ) = split( "\t", decode( "utf8", $line ) );
    $data{$category}{$num} = { "title" => $title, "open_flag" =>$open_flag };
  }
  close $fh;

  return \%data;
}

sub get_all_title {
  my ( $all_katari_list ) = @_;
  my %title_list;
  foreach my $category ( keys %$all_katari_list ) {
    my @titles_in_one_category;
    foreach my $num ( keys %{$all_katari_list->{$category}} ) {
      push ( @titles_in_one_category, $all_katari_list->{$category}->{$num}->{"title"} );
    }
    $title_list{$category} = \@titles_in_one_category;
  }
  return \%title_list;
}

sub get_all_old_title {
  my ( $setting ) = @_;
  my %data;
  my $katari_chapter_dir_path = decode( "utf8", $setting->{"tool_for_katari"}->{"katari_chapter_dir_path"} );
  opendir( my $dh, encode( "cp932", $katari_chapter_dir_path ) );
  while ( my $name = readdir $dh ) {
    if ( $name eq "." or $name eq ".."  or $name =~ /.tex$/) {
      next;
    } else  {
      my @title_list;
      my $section_dir_path = encode( "cp932", $katari_chapter_dir_path )  . "/" . $name;
      opendir( my $section_dir, $section_dir_path );
      while ( my $subsection_name = readdir $section_dir ) {
        if ( $subsection_name eq "." or $subsection_name eq ".."  or $subsection_name =~ /.tex.backup$/) {
          next;
        } elsif ( $subsection_name =~ /^subsection_.*\.tex$/ ) {
          $subsection_name = substr( $subsection_name, length( "subsection_" ) );
          $subsection_name = substr( $subsection_name, 0, length( $subsection_name ) - length( ".tex" ) );
          push( @title_list, $subsection_name );
        }
      }
      $data{substr( $name, length( "section_" ) )} = \@title_list;
      closedir $section_dir;
    }
  }
  closedir $dh;
  return \%data;
}

sub make_new_dir_and_subsection_tex_file {
  my ( $setting, $title_list, $old_title_list ) = @_;
  my $katari_chapter_dir_path = decode( "utf8", $setting->{"tool_for_katari"}->{"katari_chapter_dir_path"} );
  foreach my $category ( keys %$title_list ) {
    my $section_dir_path = $katari_chapter_dir_path . "/section_${category}";
    if ( !exists $old_title_list->{encode( "cp932", $category )} ) {
      mkdir encode( "cp932", $section_dir_path );
      foreach my $title ( @{$title_list->{$category}} ) {
        my $subsection_tex_file_path = encode( "cp932", $section_dir_path . "/subsection_${title}.tex" );
        make_new_tex_file( $subsection_tex_file_path );
      }
    } else {
      foreach my $title_in_csv ( map { encode( "cp932", $_ ) } @{$title_list->{$category}} ) {
        my @title_list_in_dir = @{$old_title_list->{encode( "cp932", $category )}};
        if ( grep { $_ eq $title_in_csv } @title_list_in_dir ) {
          next;
        } else  {
          my $subsection_tex_file_path = encode( "cp932", $section_dir_path ) . "/subsection_${title_in_csv}.tex";
          make_new_tex_file( $subsection_tex_file_path );
        }
      }
    }
  }
}

sub make_new_tex_file {
  my ( $path ) = @_;
  open( my $fh, ">", $path );
  print $fh encode( "cp932", "\\documentclass\[C:/souji/all-note/note\]\{subfiles\}\n\n" );
  print $fh encode( "cp932", "\\begin\{document\}\n\n" );
  print $fh encode( "cp932", "\\end\{document\}" );
  close $fh;
}

1;
