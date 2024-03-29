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

  my $target_environment = get_target_environment( $all_note_dir );

  my $all_def_and_thm_data = get_all_def_and_thm_data( $setting, $all_sub_tex_file_tree, $target_environment );

  output_tex( $setting, $all_def_and_thm_data );
}

sub get_target_environment {
  my ( $all_note_dir )  = @_;
  my @target_environment;

  open( my $fh, "<", "${all_note_dir}preamble/souji_thm_style.sty" );
  while( my $line = <$fh> ) {
    if ( $line =~ /\\newenvironment\{(.+)\}\[1\]\[\]\{/ ) {
      push( @target_environment, $1 );
    }
  }

  close( $fh );
  return \@target_environment;
}

sub get_all_def_and_thm_data {
  my ( $setting, $data_hash, $target_environment ) = @_;
  foreach my $part_counter ( sort keys %$data_hash ) {
    my $part_key = $data_hash->{$part_counter};
    foreach my $chapter_counter ( sort keys %{$part_key->{"chapter"}} ) {
      my $chapter_key = $part_key->{"chapter"}->{$chapter_counter};
      get_all_def_and_thm_data_in_one_file( $setting, $chapter_key, $target_environment );

      foreach my $section_counter ( sort keys %{$chapter_key->{"section"}} ) {
        my $section_key = $chapter_key->{"section"}->{$section_counter};
        get_all_def_and_thm_data_in_one_file( $setting, $section_key, $target_environment );

        foreach my $subsection_counter ( sort keys %{$section_key->{"subsection"}} ) {
          my $subsection_key = $section_key->{"subsection"}->{$subsection_counter};
          get_all_def_and_thm_data_in_one_file( $setting, $subsection_key, $target_environment );
        }
      }
    }
  }

  return $data_hash;
}

sub get_all_def_and_thm_data_in_one_file {
  my ( $setting, $data_hash, $target_environment ) = @_;

  if ( !exists( $data_hash->{"file_path"} ) ) {
    return;
  }

  my $file_path = $data_hash->{"file_path"};
  my $target_tex_file_path = $setting->{"summarize_def_and_thm"}->{"output_tex_file_path"};
  $target_tex_file_path =  encode( "cp932", decode( "utf8", $target_tex_file_path ) );
  if ( $target_tex_file_path eq $file_path ) {
    return;
  }

  open( my $fh, "<", $file_path  );

  my $line_counter = 0;
  my $is_target_line = 0;
  my $is_footnote = 0;
  my $line_counter_for_item;
  my $item_counter = 0;
  my @item_labels_array = ();
  my $lines_str = "";
  my $item_name = "";
  my $target_key;

  while( my $line = <$fh> ) {

    $line_counter++;

    if ( $is_target_line ) {

      if ( $line =~ /^\s{1,}\\footnote\{\n$/ ) {
        $is_footnote = 1;
        next;
      }
      if ( $is_footnote and $line =~ /^\s{1,}\}\n$/ ) {
        $is_footnote = 0;
        next;
      }
      if ( $line =~ /^\s{1,}\\label\{(.*)\}\n$/ ) {
        push( @item_labels_array, $1 );
        next;
      }
      if ( !$is_footnote and $line !~ /^\\end\{/ ) {
        $lines_str .= $line;
      }

      if ( $line =~ /^\\end\{/ ) {

        $target_key->{"str"} = $lines_str;
        $target_key->{"label"} = join( " , ", @item_labels_array );

        $is_target_line = 0;
        $line_counter_for_item = 0;
        $lines_str = "";
        @item_labels_array = ();
        $target_key = "";

      }
    } else {
      foreach my $environment_name (  @{$target_environment} ) {
        if ( $line =~ /\\begin\{${environment_name}\}\[(.*)\]$/ ) {

          $is_target_line = 1;
          $line_counter_for_item = $line_counter;
          $item_counter++;

          $data_hash->{"item"}->{sprintf( "%04d", $item_counter )} = {};
          $target_key = $data_hash->{"item"}->{sprintf( "%04d", $item_counter )};

          $target_key->{"environment_name"} = $environment_name;
          $target_key->{"line"} = $line_counter_for_item;
          $target_key->{"item_name"} = $1;

          next;
        }
      }
    }

  }
  close $fh;
}

sub output_tex {
  my ( $setting, $data ) = @_;

  my $file_path = $setting->{"summarize_def_and_thm"}->{"output_tex_file_path"};
  open( my $fh, ">", encode( "cp932", decode( "utf8", $file_path ) ) );

  print $fh "\\documentclass[C:/souji/all-note/note]{subfiles}\n\n";
  print $fh "\\begin{document}\n\n";

  foreach my $part_counter ( sort keys %{$data} ) {
    my $part_key = $data->{$part_counter};
    my $part_name = decode( "cp932", $part_key->{"name"} );
    if (  $part_name eq "その他" or $part_name eq "情報一覧" ) {
      next;
    }

    my $chapter_number = sprintf( "%d", $part_counter );
    my $chapter_name = decode( "cp932", $part_key->{"name"} );
    my $section_title = "\\section\{${chapter_number}部　${chapter_name}\}\n";
    print $fh encode( "cp932", $section_title );
    my $section_label = "\\label\{section:${chapter_number}部　${chapter_name}\}\n\n";
    print $fh encode( "cp932", $section_label );


    foreach my $chapter_counter ( sort keys %{$data->{$part_counter}->{"chapter"}}) {
      my $chapter_key = $part_key->{"chapter"}->{$chapter_counter};
      output_items( $fh, $chapter_key );

      foreach my $section_counter ( sort keys %{$chapter_key->{"section"}} ) {
        my $section_key = $chapter_key->{"section"}->{$section_counter};
        output_items( $fh, $section_key );

        foreach my $subsection_counter ( sort keys %{$section_key->{"subsection"}} ) {
          my $subsection_key = $section_key->{"subsection"}->{$subsection_counter};
          output_items( $fh, $subsection_key );

        }
      }
    }
  }
  print $fh "\n\\end{document}";
  close $fh;
}

sub output_items {
  my ( $fh, $data ) = @_;
  foreach my $counter ( sort keys %{$data->{"item"}}) {

    my $target_key = $data->{"item"}->{$counter};
    my $file_path = $data->{"file_path"};
    my $line = $target_key->{"line"};
    my $environment_name = $target_key->{"environment_name"};
    my $item_name = $target_key->{"item_name"};
    my $label = $target_key->{"label"};
    my $str = $target_key->{"str"};

    $environment_name = uc( substr( $environment_name, 0, 1 ) ) . substr( $environment_name, 1 );

    if ( $label eq "" ) {
      print $fh "\\begin{itembox}[l]{${environment_name}\ ${item_name}}\n";
    } else {
      my @label_array = split( " , ", $label );
      my $num_of_label_array = @label_array;
      if ( $num_of_label_array > 1 ) {
        $label = $label_array[0];
      }
      my $title = $environment_name .
                      "\ \\ref\{" . $label . "\}\\ \\ " .
                      $item_name . "\\ \\ " .
                      "\\pageref\{" .  $label . "\}" . encode( "cp932", "ページ" );
      print $fh "\\begin{itembox}[l]{${title}}\n";
    }

    print $fh $str;
    print $fh "\t\\begin\{itemize\}\n";
    $file_path = substr( $file_path, 18 );
    print $fh encode( "cp932", "\t\t\\item\[\]（ファイルパス）\\path\{" ) . $file_path . "\}\n";
    print $fh encode( "cp932", "\t\t\\item\[\]（行数）" ) . $line;
    print $fh encode( "cp932", "\t\t（ラベル）" ) . $label . "\n";
    print $fh "\t\\end\{itemize\}\n";
    print $fh "\\end{itembox}\n\\ \\\\\\vspace\{-0.5cm\}\n";

  }
}

1;
