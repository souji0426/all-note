use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
#iniファイルを処理するのに使っている
use File::Find;

require "C:/souji/all-note/tool/common.pl";
my $tool_dir_path = "C:\\souji\\all-note\\tool";

my $setting = &common::get_setting();
my $part_dir_path = $setting->{"path"}->{"part_dir"};

main();

sub main {
  my $path_list = get_tex_file_list( $part_dir_path );
  foreach my  $file_path ( @$path_list ) {
    $file_path = decode( "cp932", $file_path );
    my $path_without_suffix = get_without_suffix_name( $file_path );
    my @data = split( "/", $file_path );
    my $file_name = pop @data;
    my $file_name_without_suffix = get_without_suffix_name( $file_name );
    my $target_dir_path = join( "/", @data );
    my $batch_file_path = $path_without_suffix . "（LaTeX実行）\.bat";
    open( my $fh, ">:encoding( cp932 )", encode( "cp932", $batch_file_path ) );
    print $fh "cd ${tool_dir_path}\n\n";
    print $fh "perl -w convert_comma_and_period.pl ${path_without_suffix}.tex\n\n";
    print $fh "pause\n\n";
    print $fh  "cd ${target_dir_path}\n\n";
    print $fh "platex ${file_name_without_suffix}\n\n";
    print $fh "dvipdfmx ${file_name_without_suffix}\n\n";
    my @delete_target_suffix = ( "aux", "log", "dvi", "out", "idx" );
    foreach my $suffix ( @delete_target_suffix ) {
      print $fh "del ${file_name_without_suffix}.${suffix}\n\n";
    }
    print $fh "${file_name_without_suffix}.pdf\n\n";
    close $fh;

    $batch_file_path = $path_without_suffix . "（subfile生成）\.bat";
    open( $fh, ">:encoding( cp932 )", encode( "cp932", $batch_file_path ) );
    print $fh "cd ${tool_dir_path}\n\n";
    print $fh "perl -w make_subfile.pl ${path_without_suffix}.tex\n\n";
    print $fh "pause\n\n";
    close $fh;
  }
}

#----------------------------------------------------------------------------------------------

sub get_tex_file_list {
  my ( $path ) = @_;
  my $path_list;
  find sub {
      my $file = $_;
      my $path = $File::Find::name;
      if ( $file ne "." and $file ne ".." and !-d $path and -f $path ) {
        if ( $path =~ /.tex$/ ) {
          push( @$path_list, $path );
        }
      }
  }, $path;
  return $path_list;
}

sub get_without_suffix_name {
  my ( $file_name ) = @_;
  my @data = split( /\./, $file_name );
  return $data[0];
}

1;
