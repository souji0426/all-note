use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use Config::Tiny;

sub get_target_reference_data {
  my ( $setting ) = @_;
  my %data;
  my $target_reference_data_csv_path = decode( "utf8", $setting->{"tool_for_resarch_reference"}->{"target_reference_data_csv_path"} );
  my $counter = 0;
  open( my $fh, "<", encode( "cp932", $target_reference_data_csv_path ) );
  while( my $line = <$fh> ) {
    chomp $line;
    my @one_line_data = split( "\t", decode( "utf8", $line ) );
    my $tag = shift @one_line_data;
    $data{sprintf( "%03d", $counter )}{"tag"} = $tag;
    $data{sprintf( "%03d", $counter )}{"data"} = \@one_line_data;
    $data{sprintf( "%03d", $counter )}{"title"} = get_title( \@one_line_data );
    $counter++;
  }
  close $fh;
  return \%data;
}

sub get_title {
  my ( $one_line_data ) = @_;
  my @data = @$one_line_data;
  my $title_data_str = $data[0];
  $title_data_str=~ s/タイトル：//;
  return $title_data_str;
}

1;
