use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use Config::Tiny;
#iniファイルを処理するのに使っている

use lib "./";
use common_subroutines;
#共通関数の呼び出し

main();

sub main {
  my $setting_ini_path = "./setting.ini";
  my $setting = Config::Tiny->read( $setting_ini_path );
  my $all_note_dir = $setting->{"common"}->{"all_note_dir"};

  #common_subroutines::catch_all_subfile_tex_tree
  my $all_sub_tex_file_tree = catch_all_subfile_tex_tree( $all_note_dir );

  my $all_atode_data = get_all_atode( $all_sub_tex_file_tree );
  output_file( $all_atode_data );

  my $summarized_data = summarize_data( $all_atode_data );

  output_tex( $setting, $summarized_data );
}

sub get_all_atode {
  my ( $data_hash ) = @_;
  foreach my $part_counter ( sort keys %$data_hash ) {
    my $part_key = $data_hash->{$part_counter};
    my $part_name = decode( "cp932", $part_key->{"name"} );
    if (  $part_name eq "情報一覧" ) {
      next;
    }

    foreach my $chapter_counter ( sort keys %{$part_key->{"chapter"}} ) {
      my $chapter_key = $part_key->{"chapter"}->{$chapter_counter};
      get_all_atode_in_one_file( $chapter_key );

      foreach my $section_counter ( sort keys %{$chapter_key->{"section"}} ) {
        my $section_key = $chapter_key->{"section"}->{$section_counter};
        get_all_atode_in_one_file( $section_key );

        foreach my $subsection_counter ( sort keys %{$section_key->{"subsection"}} ) {
          my $subsection_key = $section_key->{"subsection"}->{$subsection_counter};
          get_all_atode_in_one_file( $subsection_key );
        }
      }
    }
  }

  return $data_hash;
}

sub get_all_atode_in_one_file {
  my ( $data_hash ) = @_;

  if ( !exists( $data_hash->{"file_path"} ) ) {
    return;
  }

  open( my $fh, "<", $data_hash->{"file_path"} );

  my $line_counter = 0;
  my $is_target_line = 0;
  my $item_counter = 0;
  my $lines_str = "";
  my $target_key;

  while( my $line = <$fh> ) {

    $line_counter++;

    if ( $is_target_line ) {
      if ( $line =~ /\\begin\{comment\}\n$/ ) {
        next;

      } elsif ( $line =~ /\\end\{comment\}\n$/ ) {
        $target_key->{"str"} = $lines_str;

        $is_target_line = 0;
        $lines_str = "";
        $target_key = "";

      } else {
        $lines_str .= $line;
      }

    } else {
      if ( decode( "cp932", $line ) =~  /\%あとで書く\n$/ or
            decode( "cp932", $line ) =~  /\%後で書く\n$/ or
            decode( "cp932", $line ) =~  /\%あとでかく\n$/ )
     {
        $is_target_line = 1;
        $item_counter++;

        $data_hash->{"atode"}->{sprintf( "%04d", $item_counter )} = {};
        $target_key = $data_hash->{"atode"}->{sprintf( "%04d", $item_counter )};
        $target_key->{"line"} = $line_counter;

        next;
      }
    }
  }
  close $fh;
}

sub summarize_data {
  my ( $all_kongo_data ) = @_;
  my $data_hash = {};

  foreach my $part_counter ( sort keys %$all_kongo_data ) {
    my $part_key = $all_kongo_data->{$part_counter};

    foreach my $chapter_counter ( sort keys %{$part_key->{"chapter"}}) {
      my $chapter_key = $part_key->{"chapter"}->{$chapter_counter};
      get_atode_data_in_one_hash( $data_hash, $chapter_key );

      foreach my $section_counter ( sort keys %{$chapter_key->{"section"}} ) {
        my $section_key = $chapter_key->{"section"}->{$section_counter};
        get_atode_data_in_one_hash( $data_hash, $section_key );

        foreach my $subsection_counter ( sort keys %{$section_key->{"subsection"}} ) {
          my $subsection_key = $section_key->{"subsection"}->{$subsection_counter};
          get_atode_data_in_one_hash( $data_hash, $subsection_key );
        }
      }
    }
  }
  return $data_hash;
}

sub get_atode_data_in_one_hash {
  my ( $kongo_data, $target_hash ) = @_;
  my $atode_counter = keys %{$kongo_data};

  foreach my $counter ( sort keys %{$target_hash->{"atode"}} ) {
    my $target_key = $target_hash->{"atode"}->{$counter};
    $atode_counter++;
    $kongo_data->{sprintf( "%04d", $atode_counter )}->{"file_path"} = $target_hash->{"file_path"};
    $kongo_data->{sprintf( "%04d", $atode_counter )}->{"str"} = $target_key->{"str"};
    $kongo_data->{sprintf( "%04d", $atode_counter )}->{"line"} = $target_key->{"line"};
  }
}

sub output_tex {
  my ( $setting, $data ) = @_;

  my $file_path = $setting->{"make_atode_list"}->{"output_tex_file_path"};
  open( my $fh, ">", encode( "cp932", decode( "utf8", $file_path ) ) );

  print $fh "\\documentclass[C:/souji/all-note/note]{subfiles}\n\n";
  print $fh "\\begin{document}\n\n";

  my $num_of_kongo  = keys %$data;
  print $fh encode( "cp932", "後で書くメモは全部で${num_of_kongo}個です.\n\\  \\\\" );

  foreach my $atode_counter ( sort keys %$data ) {
    output_items( $fh, $data, $atode_counter );
  }

  print $fh "\n\\end{document}";
  close $fh;
}

sub output_items {
  my ( $fh, $data, $atode_counter ) = @_;
  my $file_path = $data->{$atode_counter}->{"file_path"};
  my $line = $data->{$atode_counter}->{"line"};
  my $str = $data->{$atode_counter}->{"str"};
  $atode_counter = sprintf( "%d", $atode_counter );

  $file_path = substr( $file_path, 18 );
  my $item_title = encode( "cp932",
  "\\begin{itembox}[l]\{
    その${atode_counter}\,（パス）\\path\{" ) . $file_path . "\}
    \}\n";

  print $fh $item_title;
  print $fh encode( "cp932", "（行数⇒${line}）" );
  print $fh $str;
  print $fh "\\end{itembox}\n\\ \\\\\\vspace\{-0.5cm\}\n";
}

1;
