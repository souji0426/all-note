use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use Config::Tiny;

#souji_noteでsubfileで呼び出されているtexファイル、そのtexファイルから呼び出されているtex、
#という風に再帰的に呼びだしているtexファイル全てを絶対パスで入手。
#どのtexファイルでも絶対パスで書くよう習慣づけておくこと。
sub catch_all_subfile_tex_file {
  my ( $all_note_dir )  = @_;
  my @all_sub_tex_file_path;

  open( my $all_fh, "<", "${all_note_dir}note.tex" );
  while( my $line = <$all_fh> ) {
    chomp $line;
    if ( $line =~ /.subfile\{(.+)\}/ ) {
      push( @all_sub_tex_file_path, $1 );
    }
  }
  close( $all_fh );

  foreach my $file_path ( @all_sub_tex_file_path ) {
    open( my $sub_fh, "<", $file_path );
    while( my $line = <$sub_fh> ) {
      chomp $line;
      if ( $line =~ /.subfile\{(.+)\}/ ) {
        if ( !grep { $_ eq $1 } @all_sub_tex_file_path ) {
          push( @all_sub_tex_file_path, $1 );
        }
      }
    }
    close( $sub_fh );
  }

  return \@all_sub_tex_file_path
}


1;
