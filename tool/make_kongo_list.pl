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

  my $all_kongo_data = get_all_kongo( $all_sub_tex_file_tree );

  my $summarized_data = summarize_data( $all_kongo_data );

  output_tex( $setting, $summarized_data );
}

sub get_all_kongo {
  my ( $data_hash ) = @_;
  foreach my $part_counter ( sort keys %$data_hash ) {
    my $part_key = $data_hash->{$part_counter};
    my $part_name = decode( "cp932", $part_key->{"name"} );
    if (  $part_name eq "その他" or $part_name eq "情報一覧" ) {
      next;
    }

    foreach my $chapter_counter ( sort keys %{$part_key->{"chapter"}} ) {
      my $chapter_key = $part_key->{"chapter"}->{$chapter_counter};
      get_all_kongo_in_one_file( $chapter_key );

      foreach my $section_counter ( sort keys %{$chapter_key->{"section"}} ) {
        my $section_key = $chapter_key->{"section"}->{$section_counter};
        get_all_kongo_in_one_file( $section_key );

        foreach my $subsection_counter ( sort keys %{$section_key->{"subsection"}} ) {
          my $subsection_key = $section_key->{"subsection"}->{$subsection_counter};
          get_all_kongo_in_one_file( $subsection_key );
        }
      }
    }
  }

  return $data_hash;
}

sub get_all_kongo_in_one_file {
  my ( $data_hash ) = @_;

  if ( !exists( $data_hash->{"file_path"} ) ) {
    return;
  }

  open( my $fh, "<", $data_hash->{"file_path"} );

  my $line_counter = 0;
  my $is_target_line = 0;
  my $is_footnote = 0;
  my $item_counter = 0;
  my @item_labels_array = ();
  my $lines_str = "";
  my $target_key;

  while( my $line = <$fh> ) {

    $line_counter++;

    if ( $is_target_line ) {

      if ( $line =~ /^\s{1,}\\footnote\{/ ) {
        $is_footnote = 1;
        next;
      }
      if ( $is_footnote and $line =~ /^\s{1,}\}/ ) {
        $is_footnote = 0;
        next;
      }
      if ( $line =~ /^\s{1,}\\label\{(.+)\}/ ) {
        push( @item_labels_array, $1 );
        next;
      }
      if ( !$is_footnote and $line !~ /^\\end/ ) {
        $lines_str .= $line;
      }

      if ( $line =~ /^\\end\{kongo\}/ ) {

        $target_key->{"str"} = $lines_str;
        $target_key->{"label"} = join( " , ", @item_labels_array );

        $is_target_line = 0;
        $lines_str = "";
        @item_labels_array = ();
        $target_key = "";

      }
    } else {
      if ( $line =~ /^\\begin\{kongo\}/ ) {

        $is_target_line = 1;
        $item_counter++;

        $data_hash->{"kongo"}->{sprintf( "%04d", $item_counter )} = {};
        $target_key = $data_hash->{"kongo"}->{sprintf( "%04d", $item_counter )};
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
      get_kongo_data_in_one_hash( $data_hash, $chapter_key );

      foreach my $section_counter ( sort keys %{$chapter_key->{"section"}} ) {
        my $section_key = $chapter_key->{"section"}->{$section_counter};
        get_kongo_data_in_one_hash( $data_hash, $section_key );

        foreach my $subsection_counter ( sort keys %{$section_key->{"subsection"}} ) {
          my $subsection_key = $section_key->{"subsection"}->{$subsection_counter};
          get_kongo_data_in_one_hash( $data_hash, $subsection_key );
        }
      }
    }
  }
  return $data_hash;
}

sub get_kongo_data_in_one_hash {
  my ( $kongo_data, $target_hash ) = @_;
  my $kongo_counter = keys %{$kongo_data};

  foreach my $counter ( sort keys %{$target_hash->{"kongo"}} ) {
    my $target_key = $target_hash->{"kongo"}->{$counter};
    $kongo_counter++;
    $kongo_data->{sprintf( "%04d", $kongo_counter )}->{"file_path"} = $target_hash->{"file_path"};
    $kongo_data->{sprintf( "%04d", $kongo_counter )}->{"str"} = $target_key->{"str"};
    $kongo_data->{sprintf( "%04d", $kongo_counter )}->{"line"} = $target_key->{"line"};
    $kongo_data->{sprintf( "%04d", $kongo_counter )}->{"label"} = $target_key->{"label"};
  }
}

sub output_tex {
  my ( $setting, $data ) = @_;

  my $file_path = $setting->{"make_kongo_list"}->{"output_tex_file_path"};
  open( my $fh, ">", encode( "cp932", decode( "utf8", $file_path ) ) );

  print $fh "\\documentclass[C:/souji/all-note/note]{subfiles}\n\n";
  print $fh "\\begin{document}\n\n";

  my $num_of_kongo  = keys %$data;
  print $fh encode( "cp932", "今後の課題は全部で${num_of_kongo}個です.\n\n\n" );

  foreach my $kongo_counter ( sort keys %$data ) {
    output_items( $fh, $data, $kongo_counter );
  }

  print $fh "\n\\end{document}";
  close $fh;
}

sub output_items {
  my ( $fh, $data, $kongo_counter ) = @_;
  my $file_path = $data->{$kongo_counter}->{"file_path"};
  my $line = $data->{$kongo_counter}->{"line"};
  my $label = $data->{$kongo_counter}->{"label"};
  my $str = $data->{$kongo_counter}->{"str"};
  $kongo_counter = sprintf( "%d", $kongo_counter );

  if ( $label eq "" ) {
    print $fh encode( "cp932", "\\begin{itembox}[l]{その${kongo_counter}}\n" );
  } else {
    my $title = encode( "cp932", "\\begin{itembox}[l]{その${kongo_counter}" ) . "\\ \\ " .
                    "\\pageref\{" .  $label . "\}" .encode( "cp932", "ページ}\n" );
    print $fh $title;
  }
  print $fh $str;
  print $fh "\t\\begin\{itemize\}\n";
  print $fh encode( "cp932", "\t\t\\item\[\]（ファイルパス）\\path\{" ) . $file_path . "\}\n";
  print $fh encode( "cp932", "\t\t\\item\[\]（行数）" ) . $line;
  print $fh encode( "cp932", "\t\t（ラベル）" ) . $label . "\n";
  print $fh "\t\\end\{itemize\}\n";
  print $fh "\\end{itembox}\n\\ \\\\\n";
}

1;
