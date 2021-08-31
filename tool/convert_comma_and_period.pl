use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use Config::Tiny;
#iniファイルを処理するのに使っている

use File::Copy;
use File::Copy::Recursive qw(rcopy);
#ファイルをコピーするために使っている

main();

sub main {
  my $setting_ini_path = "./setting.ini";
  my $setting = Config::Tiny->read( $setting_ini_path );
  my $all_note_dir = $setting->{"common"}->{"all_note_dir"};

  my $all_sub_tex_file_paths = catch_all_subfile_tex_file( $all_note_dir );
  print Dumper $all_sub_tex_file_paths;

  my $target_file_paths = get_target_file( $all_sub_tex_file_paths );
  print Dumper $target_file_paths;

  backup_file( $target_file_paths );

  convert_comma_and_period( $target_file_paths );
}

#subfileで呼び出されている全てのtexファイルを探す
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

sub get_target_file {
  my ( $all_sub_tex_file_paths ) = @_;
  my @target_file_paths;
  foreach my $file_path ( @$all_sub_tex_file_paths ) {
    open( my $fh, "<", $file_path );
    while( my $line = <$fh> ) {
      $line = decode( "cp932", $line );
      if ( $line =~ /、\n/ or $line =~ /。\n/  ) {
        push( @target_file_paths, $file_path );
        last;
      }
    }
  }
  return \@target_file_paths
}

sub backup_file {
  my ( $target_file_paths ) = @_;
  foreach my $file_path ( @$target_file_paths ) {
    copy( $file_path, $file_path . ".backup" );
  }
}

sub convert_comma_and_period {
  my ( $target_file_paths ) = @_;
  foreach my $file_path ( @$target_file_paths ) {
    my $new_file_path = $file_path . ".new";
    open( my $output_fh, ">", $new_file_path );
    open( my $read_fh, "<", $file_path );
    while( my $line = <$read_fh> ) {
      $line = decode( "cp932", $line );
      if ( $line =~ /、\n/  ) {
        $line =~ s/、\n/,\n/g;
      } elsif ( $line =~ /。\n/ ) {
        $line =~ s/。\n/.\n/g
      }
      print $output_fh encode( "cp932", $line );
    }
    close( $read_fh );
    close( $output_fh);
    unlink $file_path;
    move( $new_file_path, $file_path );
  }
}

1;
