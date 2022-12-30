use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
#iniファイルを処理するのに使っている

require "C:/souji/all-note/tool/common.pl";

main();

sub main {
  my $setting = &common::get_setting();
  my $all_note_tex_file_path = $setting->{"path"}->{"all_note_tex_file"};
  my $part_dir_path = $setting->{"path"}->{"part_dir"};

  my $symbol_list_tex_file_dir_path = encode( "cp932", $setting->{"path"}->{"symbol_list_tex_file_dir"} );
  if ( !-d $symbol_list_tex_file_dir_path ) {
    mkdir $symbol_list_tex_file_dir_path;
  }

  my $part_data = &common::get_part_data( $all_note_tex_file_path );

  foreach my $part_counter ( sort keys %$part_data ) {
    my $part_dir_path = $part_data->{$part_counter}->{"path"};
    my $part_name = $part_data->{$part_counter}->{"name"};

    my @ordered_subfile_list;
    &common::get_ordered_subfile_list( \@ordered_subfile_list, $part_dir_path );

    my $symbol_data = get_symbol_data( \@ordered_subfile_list );

    output_tex( $symbol_list_tex_file_dir_path, $part_name, $symbol_data );
  }
}

sub get_symbol_data {
  my ( $file_path_list ) = @_;
  my $data = {};
  my $registered_symbol_data = {};
  my $symbol_counter = 0;
  foreach my $file_path ( @$file_path_list ) {
    open( my $fh, "<:encoding( cp932 )", encode( "cp932", $file_path ) );
    while( my $line = <$fh> ) {
      chomp $line;
      if ( $line =~ /^\\RegisterInSymbolList\{\$(.+)\$\}\{(.+)\}$/ ) {
        my $symbol = $1;
        my $label = $2;
        if ( grep { $_ eq $symbol } keys %$registered_symbol_data ) {

          my $target_counter = $registered_symbol_data->{$symbol};
          my $labels = $data->{sprintf( "%04d", $target_counter )}->{"labels"};
          push( @$labels, $label );
          $data->{sprintf( "%04d", $target_counter )}->{"labels"} = $labels;

        } else {

          $data->{sprintf( "%04d", $symbol_counter )}->{"symbol"} = "\$${symbol}\$";
          my @labels = ( $label );
          $data->{sprintf( "%04d", $symbol_counter )}->{"labels"} = \@labels;
          $registered_symbol_data->{$symbol} = sprintf( "%04d", $symbol_counter );
          $symbol_counter++;

        }
      }
    }
    close $fh;
  }
  return $data;
}

sub output_tex {
  my ( $symbol_list_tex_file_dir_path, $part_name, $symbol_data ) = @_;
  my $target_tex_path = "${symbol_list_tex_file_dir_path}/${part_name}\.tex";
  open( my $fh, ">:encoding( cp932 )", encode( "cp932", $target_tex_path ) );
  print_table( $fh, $symbol_data );
  close $fh;
}

sub print_table {
  my ( $fh, $symbol_data ) = @_;
  my $num_of_data = keys %$symbol_data;
  my $num_of_column = 3;
  my $num_of_row;
  if ( $num_of_data % $num_of_column == 0 ) {
    $num_of_row = $num_of_data / $num_of_column;
  } else {
    $num_of_row = int( $num_of_data / $num_of_column ) + 1;
  }
  print $fh "\\begin\{table\}\[H\]\n";
  print $fh "\t" x 1 . "\\begin\{center\}\n";
  print $fh "\t" x 2 . "\{ \\renewcommand\\arraystretch{1.5}\n";

  my $column_setting = "|c|c|" x $num_of_column;
  print $fh "\t" x 3 . "\\begin\{tabular\}\{${column_setting}\}\n";
  print $fh "\t" x 4 . "\\hline\n";

  my $part_of_header = "記号 & 初登場ページ";
  my @array;
  for ( my $i = 0; $i < $num_of_column; $i++ ){
    push( @array, $part_of_header );
  }
  my $header = "\t" x 4 . join( " & ", @array ) . "  \\\\ \\hline \\hline\n";
  print $fh $header;

  for ( my $row = 0; $row < $num_of_row; $row++ ){
    my $one_line = make_one_line( $symbol_data, $row, $num_of_column );
    print $fh $one_line;
  }

  print $fh "\t" x 3 . "\\end\{tabular\}\n";
  print $fh "\t" x 2 . "}\n";
  print $fh "\t" x 1 . "\\end\{center\}\n";
  print $fh "\\end\{table\}\n\n";
}

sub make_one_line {
  my ( $data, $row, $num_of_column ) = @_;
  my @array;
  for ( my $i = 1; $i < $num_of_column+1; $i++ ){
    my $target_num = $num_of_column * $row + $i;
    my $symbol = "";
    my $label_str = "";
    if ( exists( $data->{sprintf( "%04d", $target_num )} ) ) {
      $symbol = $data->{sprintf( "%04d", $target_num )}->{"symbol"};
      my $labels = $data->{sprintf( "%04d", $target_num )}->{"labels"};
      map { $_ = "\\pageref\{$_\}" } @$labels;
      $label_str = join( ", ", @$labels );
    }
    my $part_of_one_line = "${symbol} & ${label_str}";
    push( @array, $part_of_one_line );
  }
  return "\t\t\t" . join( " & ", @array ) . "  \\\\ \\hline\n";
}



1;
