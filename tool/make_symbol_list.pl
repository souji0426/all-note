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

  my $all_symbol_data = get_all_symbol_data( $setting, $all_sub_tex_file_tree );

  my $summarized_data = summarize_data( $all_symbol_data );

  output_tex( $setting, $summarized_data );
}

sub get_all_symbol_data {
  my ( $setting, $data_hash ) = @_;
  foreach my $part_counter ( sort keys %$data_hash ) {
    my $chapter_key = $data_hash->{$part_counter}->{"chapter"};
    foreach my $chapter_counter ( sort keys %{$chapter_key } ) {

      my $section_key = $data_hash->{$part_counter}->{"chapter"}->{$chapter_counter}->{"section"};
      my $num_of_section = keys %{$section_key};

      if ( $num_of_section == 0 ) {
        my $target_key = $data_hash->{$part_counter}->{"chapter"}->{$chapter_counter};
        get_all_symbol_data_in_one_file( $setting, $target_key );
      } else {

        foreach my $section_counter ( sort keys %{$section_key} ) {
          my $target_key = $data_hash->{$part_counter}->{"chapter"}->{$chapter_counter}->{"section"}->{$section_counter};
          get_all_symbol_data_in_one_file( $setting, $target_key );
        }

      }
    }
    return $data_hash;
  }

  return $data_hash;
}

sub get_all_symbol_data_in_one_file {
  my ( $setting, $data_hash ) = @_;

  my $file_path = $data_hash->{"file_path"};

  open( my $fh, "<", $file_path  );
  while( my $line = <$fh> ) {
    if ( $line =~ /\%(.+)::(.+)::(.+)::(.+)/ ) {

      my ( $first_alphabet, $second_alphabet ) = split( "-", $1 );
      if ( !exists( $data_hash->{"symbol_data"}->{$first_alphabet}->{$second_alphabet} ) ) {
        $data_hash->{"symbol_data"}->{$first_alphabet}->{$second_alphabet} = {};
      }
      my $target_key = $data_hash->{"symbol_data"}->{$first_alphabet}->{$second_alphabet};
      my $num_of_data = keys %{$target_key};
      $target_key->{sprintf( "%03d", $num_of_data )}->{"symbol"} = $2;
      $target_key->{sprintf( "%03d", $num_of_data )}->{"explanation"} = $3;
      $target_key->{sprintf( "%03d", $num_of_data )}->{"label"} = $4;
    }
  }
  close $fh;
}

sub summarize_data {
  my ( $all_symbol_data ) = @_;
  my $data = {};

  foreach my $part_counter ( sort keys %$all_symbol_data ) {
    $data->{$part_counter}->{"name"} = $all_symbol_data->{$part_counter}->{"name"};
    $data->{$part_counter}->{"label"} = $all_symbol_data->{$part_counter}->{"label"};

    my $data_hash = {};

    foreach my $chapter_counter ( sort keys %{$all_symbol_data->{$part_counter}->{"chapter"}}) {
      my $target_key = $all_symbol_data->{$part_counter}->{"chapter"}->{$chapter_counter};
      my $num_of_section = keys %{$target_key->{"section"}};
      if ( $num_of_section == 0 ) {
        get_symbol_data_in_one_file( $data_hash, $target_key );
      } else {
        foreach my $section_counter ( sort keys %{$target_key->{"section"}} ) {
          $target_key = $target_key->{"section"}->{$section_counter};
          get_symbol_data_in_one_file( $data_hash, $target_key );
        }
      }
    }

    my $num_of_data = keys %$data_hash;
    $data->{$part_counter}->{"num_of_symbol"} = $num_of_data;
    $data->{$part_counter}->{"symbol_data"} = $data_hash;
  }

  return $data;
}

sub get_symbol_data_in_one_file {
  my ( $data_hash, $data ) = @_;
  my $symbol_counter = keys %$data_hash;
  foreach my $first_alphabet ( sort keys %{$data->{"symbol_data"}} ) {
    foreach my $second_alphabet ( sort keys %{$data->{"symbol_data"}->{$first_alphabet}} ) {
      my $target_key = $data->{"symbol_data"}->{$first_alphabet}->{$second_alphabet};
      foreach my $counter ( sort keys %{$target_key} ) {
        $symbol_counter++;
        $data_hash->{sprintf( "%03d", $symbol_counter )}->{"symbol"} = $target_key->{$counter}->{"symbol"};
        $data_hash->{sprintf( "%03d", $symbol_counter )}->{"explanation"} = $target_key->{$counter}->{"explanation"};
        $data_hash->{sprintf( "%03d", $symbol_counter )}->{"label"} = $target_key->{$counter}->{"label"};
      }
    }
  }
}

sub output_tex {
  my ( $setting, $data ) = @_;

  my $file_path = $setting->{"make_symbol_list"}->{"output_tex_file_path"};
  open( my $fh, ">", encode( "cp932", decode( "utf8", $file_path ) ) );

  print $fh "\\documentclass[C:/souji/all-note/note]{subfiles}\n\n";
  print $fh "\\begin{document}\n\n";

  foreach my $part_counter ( sort keys %{$data} ) {
    my $part_name = decode( "cp932", $data->{$part_counter}->{"name"} );
    if (  $data->{$part_counter}->{"num_of_symbol"} == 0 ) {
      next;
    }

    my $chapter_number = sprintf( "%d", $part_counter );
    my $chapter_name = decode( "cp932", $data->{$part_counter}->{"name"} );
    my $section_title = "\\section\{${chapter_number}部　${chapter_name}\}\n";
    print $fh encode( "cp932", $section_title );
    my $section_label = "\\label\{section:${chapter_number}部　${chapter_name}\}\n\n";
    print $fh encode( "cp932", $section_label );

    my $target_key = $data->{$part_counter};
    make_list_and_output( $setting, $fh, $target_key );

  }

  print $fh "\n\\end{document}";
  close $fh;
}

sub make_list_and_output {
  my ( $setting, $fh, $data ) = @_;
  my $num_of_column = $setting->{"make_symbol_list"}->{"num_of_column"};
  my $num_of_row;
  if ( $data->{"num_of_symbol"} % $num_of_column == 0 ) {
    $num_of_row = $data->{"num_of_symbol"} / $num_of_column;
  } else {
    $num_of_row = int( $data->{"num_of_symbol"} / $num_of_column ) + 1;
  }
  print $fh "\\begin\{table\}\[H\]\n";
  print $fh "\t\\begin\{center\}\n";

  my $column_setting = "|c|c|c|" x $num_of_column;
  print $fh "\t\t\\begin\{tabular\}\{${column_setting}\}\n";
  print $fh "\t\t\t\\hline\n";

  my $part_of_header = "記号 & 説明 & 頁数";
  my @array;
  for ( my $i = 0; $i < $num_of_column; $i++ ){
    push( @array, $part_of_header );
  }
  my $header = "\t\t\t" . join( " & ", @array ) . "  \\\\ \\hline \\hline\n";
  print $fh encode( "cp932", $header );

  for ( my $row = 0; $row < $num_of_row; $row++ ){
    my $one_line = make_one_line( $data->{"symbol_data"}, $row, $num_of_column );
    print $fh $one_line;
  }

  print $fh "\t\t\\end\{tabular\}\n";
  print $fh "\t\\end\{center\}\n";
  print $fh "\\end\{table\}\n\n";
}

sub make_one_line {
  my ( $data, $row, $num_of_column ) = @_;
  my @array;
  for ( my $i = 1; $i < $num_of_column+1; $i++ ){
    my $target_num = $num_of_column * $row + $i;
    my $symbol = "";
    my $explanation_str = "";
    my $label_str = "";
    if ( exists( $data->{sprintf( "%03d", $target_num )} ) ) {
      $symbol = $data->{sprintf( "%03d", $target_num )}->{"symbol"};
      my $explanation = $data->{sprintf( "%03d", $target_num )}->{"explanation"};
      $explanation_str = "\\multicolumn\{1\}\{|l|\}\{${explanation}\}";
      my $label = $data->{sprintf( "%03d", $target_num )}->{"label"};
      $label_str = "\\pageref\{${label}\}";
    }
    my $part_of_one_line = "${symbol} & ${explanation_str} & ${label_str}";
    push( @array, $part_of_one_line );
  }
  return "\t\t\t" . join( " & ", @array ) . "  \\\\ \\hline\n";
}

1;
