use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
#iniファイルを処理するのに使っている
use File::Copy;

my $file_path = $ARGV[0];

my @invalid_line_array;

my @path_data = split( /\\/, $file_path );
pop @path_data;
my $copy_file_path = join( "\\", @path_data ) . "\\copy.tex";
open( my $copy_fh, ">:encoding( cp932 )", $copy_file_path );
open( my $input_fh, "<:encoding( cp932 )", $file_path );
my $line_counter = 1;
while( my $line = <$input_fh> ) {
  if ( $line =~ /、/ or  $line =~ /。/ ) {

    if ( $line =~ /、\n/ or $line =~ /。\n/ or $line =~ /。 \\\\\n/  ) {
      if ( $line =~ /、\n/  ) {
        $line =~ s/、\n/,\n/g;
      } elsif ( $line =~ /。 \\\\\n/ ) {
        $line =~ s/。 \\\\\n/. \\\\\n/g;
      } elsif ( $line =~ /。\n/ ) {
        $line =~ s/。\n/.\n/g
      }
      print $copy_fh $line;
    } else {
      push( @invalid_line_array, $line_counter );
      print $copy_fh $line;
    }

  } else {
    print $copy_fh $line;
  }

  $line_counter++;
}

close $input_fh;

close $copy_fh;

my $num_of_invalid_line = @invalid_line_array;
if ( $num_of_invalid_line > 0 ) {
  print encode( "cp932", "\n\t不当な句読点を${num_of_invalid_line}件発見\n\n" );
  for ( my $i = 0; $i < $num_of_invalid_line; $i++ ) {
    my $line = $invalid_line_array[$i];
    print encode( "cp932", "\t\t${i}件目：${line}\n" );
  }
} elsif ( $num_of_invalid_line == 0 ) {
  print encode( "cp932", "\n\t不当な句読点はナシ！\n\n" );
  unlink $file_path;
  move( $copy_file_path, $file_path );
}

unlink $copy_file_path;


1;
