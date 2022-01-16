use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use Config::Tiny;
#iniファイルを処理するのに使っている

use lib "./";
use basic_subroutines;
#共通関数の呼び出し

main();

sub main {
  my $setting_ini_path = "./setting.ini";
  my $setting = Config::Tiny->read( $setting_ini_path );
  my $all_note_dir = $setting->{"common"}->{"all_note_dir"};

  #basic_subroutines
  my $all_file_list_in_all_note_dir = get_file_path_in_dir_and_all_sub_dir( $all_note_dir );
  my $subfile_list = get_subfile_in_file( $all_file_list_in_all_note_dir );
  my $not_exist_file_list = get_not_exist_file( $subfile_list );
  make_folder_for_subfile( $not_exist_file_list );
  make_base_tex_file( $not_exist_file_list );
}

sub get_subfile_in_file {
  my ( $file_list ) = @_;
  my @result;
  foreach my $file_path ( @$file_list ) {
    if ( $file_path !~ /\.tex$/ ) {
      next;
    }
    get_subfile_in_one_file( \@result, $file_path );
  }
  return \@result;
}

sub get_subfile_in_one_file {
  my ( $list, $file_path ) = @_;
  open( my $fh, "<", $file_path );
  while( my $line = <$fh> ) {
    chomp $line;
    if ( $line =~ /\\subfile\{(.+)\}/ ) {
      push( @$list, $1 );
    }
  }
  close $fh;
}

sub get_not_exist_file {
  my ( $file_list ) = @_;
  my @result;
  foreach my $file_path ( @$file_list ) {
    if ( !-f $file_path ) {
      push( @result, $file_path );
    }
  }
  return \@result;
}

sub make_folder_for_subfile {
  my ( $file_list ) = @_;
  foreach my $file_path ( @$file_list ) {
    my @file_path_data = split( "\/", $file_path );
    my $file_name_and_tex_extension = pop @file_path_data;
    my $file_name = substr( $file_name_and_tex_extension, 0, length( $file_name_and_tex_extension ) -4 );
    my $folder_name = join( "\/", @file_path_data ) . "/" . $file_name;
    if ( !-d $folder_name and $file_name !~ /^subsection/ ) {
      mkdir $folder_name;
      print encode( "cp932", "作成完了：" ) . "${folder_name}\n";
    }
  }
}

sub make_base_tex_file {
  my ( $file_list ) = @_;
  foreach my $file_path ( @$file_list ) {
    my $folder_path = substr( $file_path, 0, length( $file_path ) -4 );
    print $folder_path . "\n";
    if ( !-f $file_path ) {
      open( my $fh, ">", $file_path  );
      print $fh encode( "cp932", "\\documentclass\[C:/souji/all-note/note\]\{subfiles\}\n\n" );
      print $fh encode( "cp932", "\\begin\{document\}\n\n" );

      if ( $folder_path =~ /^.+part.+chapter.+section.+$/ and $folder_path !~ /subsection/ ) {
        print $fh encode( "cp932", "\\subsection\{\}\n" );
        print $fh encode( "cp932", "\\label\{subsection:\}\n" );
        print $fh encode( "cp932", "\\subfile\{${folder_path}\/subsection_\.tex\}\n\n" );
      } elsif ( $folder_path =~ /^.+part.+chapter.+$/ and $folder_path !~ /section/ and $folder_path !~ /subsection/ ) {
        print $fh encode( "cp932", "\\section\{\}\n" );
        print $fh encode( "cp932", "\\label\{section:\}\n" );
        print $fh encode( "cp932", "\\subfile\{${folder_path}\/section_\.tex\}\n\n" );
      } elsif ( $folder_path =~ /^.+part.+$/ and $folder_path !~ /chapter/ and $folder_path !~ /section/ and $folder_path !~ /subsection/ ) {
        print $fh encode( "cp932", "\\chapter\{\}\n" );
        print $fh encode( "cp932", "\\label\{chapter:\}\n" );
        print $fh encode( "cp932", "\\subfile\{${folder_path}\/chapter_\.tex\}\n\n" );
      }

      print $fh encode( "cp932", "\\end\{document\}" );
      close $fh;
      print encode( "cp932", "作成完了：" ) . "${file_path}\n";
    }
  }
}

1;
