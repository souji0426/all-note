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

#上のサブルーチンのようにsubfileで呼び出されているファイルを集まるが、
#こちらは呼び出された順番で、かつそれ以外の情報も集めてハッシュ型で返してくれる。
#ここからそれに関係するサブルーチン群ーーーーーーーーーーーーーーーーーーーーーーーーーーーー
sub catch_all_subfile_tex_tree {
  my ( $all_note_dir )  = @_;
  my %tree_hash;

  #すべてのpartファイルの情報を登場順に取得
  get_all_part_data( $all_note_dir, \%tree_hash );

  get_all_chapter_data( \%tree_hash );

  get_all_section_data( \%tree_hash );

  return \%tree_hash;
}

sub get_all_part_data {
  my ( $all_note_dir, $tree_hash ) = @_;
  my $part_counter = 0;
  open( my $fh, "<", "${all_note_dir}note.tex" );
  while( my $line = <$fh> ) {
    chomp $line;
    if ( $line =~ /\\part\{(.+)\}/ ) {
      $tree_hash->{sprintf( "%02d", $part_counter )}->{"name"} = $1;
    }
    if ( $line =~ /\\label\{(.+)\}/ ) {
      $tree_hash->{sprintf( "%02d", $part_counter )}->{"label"} = $1;
    }
    if ( $line =~ /.subfile\{(.+)\}/ ) {
      $tree_hash->{sprintf( "%02d", $part_counter )}->{"file_path"} = $1;
      $part_counter++;
    }
  }
  close( $fh );
}

sub get_all_chapter_data {
  my ( $tree_hash ) = @_;
  foreach my $part_counter ( sort keys %$tree_hash ) {
    my %chapter_data_hash;
    my $chapter_counter = 0;
    open( my $fh, "<", $tree_hash->{$part_counter}->{"file_path"} );
    while( my $line = <$fh> ) {
      chomp $line;
      if ( $line =~ /\\chapter\{(.+)\}/ ) {
        $chapter_data_hash{sprintf( "%02d", $chapter_counter )}{"name"} = $1;
      }
      if ( $line =~ /\\label\{(.+)\}/ ) {
        $chapter_data_hash{sprintf( "%02d", $chapter_counter )}{"label"} = $1;
      }
      if ( $line =~ /.subfile\{(.+)\}/ ) {
        $chapter_data_hash{sprintf( "%02d", $chapter_counter )}{"file_path"} = $1;
        $tree_hash->{$part_counter}->{"chapter"} = \%chapter_data_hash;
        $chapter_counter++;
      }
    }
    close( $fh );
  }
}

sub get_all_section_data {
  my ( $tree_hash ) = @_;
  foreach my $part_counter ( sort keys %$tree_hash ) {
    foreach my $chapter_counter ( sort keys %{$tree_hash->{$part_counter}->{"chapter"}}) {
      my %section_data_hash;
      my $section_counter = 0;
      open( my $fh, "<", $tree_hash->{$part_counter}->{"chapter"}->{$chapter_counter}->{"file_path"} );
      while( my $line = <$fh> ) {
        chomp $line;
        if ( $line =~ /\\section\{(.+)\}/ ) {
          $section_data_hash{sprintf( "%02d", $section_counter )}{"name"} = $1;
        }
        if ( $line =~ /\\label\{(.+)\}/ ) {
          $section_data_hash{sprintf( "%02d", $section_counter )}{"label"} = $1;
        }
        if ( $line =~ /.subfile\{(.+)\}/ ) {
          $section_data_hash{sprintf( "%02d", $section_counter )}{"file_path"} = $1;
          $tree_hash->{$part_counter}->{"chapter"}->{$chapter_counter}->{"section"} = \%section_data_hash;
          $section_counter++;
        }
      }
      close( $fh );
    }
  }
}

#ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー


1;
