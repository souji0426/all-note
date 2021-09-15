use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use Config::Tiny;

#デバッグや無名配列の中身を確認するための開発サポート関数ーーーーーーーーーーーーーーーーーーーーーーーーーーーー
sub output_file {
  my ( $ref ) = @_;
  open( my $fh, ">", "./test.txt" );
  print $fh Dumper $ref;
  close $fh;
}


#ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー


#souji_noteでsubfileで呼び出されているtexファイル、そのtexファイルから呼び出されているtex、
#という風に再帰的に呼びだしているtexファイル全てを絶対パスで入手。
#どのtexファイルでも絶対パスで書くよう習慣づけておくこと。ーーーーーーーーーーーーーーーーーーーーーーーーーーーー
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
  my $tree_hash = {};

  #すべてのpartファイルの情報を登場順に取得
  get_all_part_data( $all_note_dir, $tree_hash );

  get_all_chapter_data( $tree_hash );

  get_under_section_data( $tree_hash );

  get_all_subsection_data( $tree_hash );

  return $tree_hash;
}

sub get_all_part_data {
  my ( $all_note_dir, $tree_hash ) = @_;
  my $part_counter = 0;
  open( my $fh, "<", "${all_note_dir}note.tex" );
  my $target_key;
  while( my $line = <$fh> ) {
    chomp $line;
    if ( $line =~ /^\\part\{(.+)\}$/ ) {
      $tree_hash->{sprintf( "%02d", $part_counter )} = {};
      $target_key = $tree_hash->{sprintf( "%02d", $part_counter )};
      $target_key->{"name"} = $1;
    }
    if ( $line =~ /\\label\{(.+)\}/ ) {
      $target_key->{"label"} = $1;
    }
    if ( $line =~ /.subfile\{(.+)\}/ ) {
      $target_key->{"file_path"} = $1;
      $part_counter++;
    }
  }
  close( $fh );
}

sub get_all_chapter_data {
  my ( $tree_hash ) = @_;
  foreach my $part_counter ( sort keys %$tree_hash ) {
    my $part_key = $tree_hash->{$part_counter};
    my $chapter_counter = 0;
    open( my $fh, "<", $part_key->{"file_path"} );
    my $target_key;
    while( my $line = <$fh> ) {
      chomp $line;
      if ( $line =~ /^\\chapter\{(.+)\}$/ ) {
        $part_key->{"chapter"}->{sprintf( "%02d", $chapter_counter )} = {};
        $target_key = $part_key->{"chapter"}->{sprintf( "%02d", $chapter_counter )};
        $target_key->{"name"} = $1;
      }
      if ( $line =~ /\\label\{(.+)\}/ ) {
        $target_key->{"label"} = $1;
      }
      if ( $line =~ /.subfile\{(.+)\}/ ) {
        $target_key->{"file_path"} = $1;
        $chapter_counter++;
      }
    }
    close( $fh );
  }
}

sub get_under_section_data {
  my ( $tree_hash ) = @_;
  foreach my $part_counter ( sort keys %$tree_hash ) {
    my $part_key = $tree_hash->{$part_counter};
    foreach my $chapter_counter ( sort keys %{$part_key->{"chapter"}} ) {
      my $chapter_key = $part_key->{"chapter"}->{$chapter_counter};
      my $section_counter = 0;
      open( my $fh, "<", $chapter_key->{"file_path"} );
      my $target_key;
      while( my $line = <$fh> ) {
        chomp $line;
        if ( $line =~ /^\\section\{(.+)\}$/ or
             $line =~ /^\\subsection\{(.+)\}$/ or
             $line =~ /^\\subsection\*\{(.+)\}$/  ) {
          $chapter_key->{"section"}->{sprintf( "%02d", $section_counter )} = {};
          $target_key = $chapter_key->{"section"}->{sprintf( "%02d", $section_counter )};
          $target_key->{"name"} = $1;
        }
        if ( $line =~ /\\label\{(.+)\}/ ) {
          $target_key->{"label"} = $1;
        }
        if ( $line =~ /.subfile\{(.+)\}/ ) {
          $target_key->{"file_path"} = $1;
          $section_counter++;
        }
      }
      close( $fh );
    }
  }
}

sub get_all_subsection_data {
  my ( $tree_hash ) = @_;
  foreach my $part_counter ( sort keys %$tree_hash ) {
    my $part_key = $tree_hash->{$part_counter};
    foreach my $chapter_counter ( sort keys %{$part_key->{"chapter"}} ) {
      my $chapter_key = $part_key->{"chapter"}->{$chapter_counter};
      foreach my $section_counter ( sort keys %{$chapter_key->{"section"}} ) {
        my $section_key = $chapter_key->{"section"}->{$section_counter};
        my $subsection_counter = 0;
        open( my $fh, "<", $section_key->{"file_path"} );
        my $target_key;
        while( my $line = <$fh> ) {
          chomp $line;
          if ( $line =~ /^\\subsection\{(.+)\}$/ ) {
            $section_key->{"subsection"}->{sprintf( "%02d", $subsection_counter )} = {};
            $target_key = $section_key->{"subsection"}->{sprintf( "%02d", $subsection_counter )};
            $target_key->{"name"} = $1;
          } elsif ( $line =~ /^\\subsection\*\{(.+)\}$/ ) {
            $section_key->{"subsection"}->{sprintf( "%02d", $subsection_counter )} = {};
            $target_key = $section_key->{"subsection"}->{sprintf( "%02d", $subsection_counter )};
            $target_key->{"name"} = $1;
          }
          if ( $line =~ /\\label\{(.+)\}/ ) {
            $target_key->{"label"} = $1;
          }
          if ( $line =~ /.subfile\{(.+)\}/ ) {
            $target_key->{"file_path"} = $1;
            $subsection_counter++;
          }
        }
        close( $fh );
      }
    }
  }
}

#ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー


1;
