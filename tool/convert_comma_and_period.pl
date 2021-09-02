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

  my $target_file_paths = get_target_file( $all_sub_tex_file_paths );

  backup_file( $target_file_paths );

  convert_comma_and_period( $target_file_paths );

  my $data = check_remaining( $all_sub_tex_file_paths );

  output_ramaining_data( $data );
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

sub check_remaining {
  my ( $file_paths ) = @_;
  my $data = {};
  foreach my $file_path ( @$file_paths ) {
    open( my $fh, "<", $file_path );
    my $line_counter = 0;
    while( my $line = <$fh> ) {
      $line_counter++;
      $line = decode( "cp932", $line );
      if ( $line =~ /、/ or  $line =~ /。/ ) {
        $data->{$file_path}->{$line_counter} = encode( "cp932", $line );
      }
    }
    close( $fh );
  }
  return $data;
}

sub output_ramaining_data {
  my ( $data ) = @_;
  foreach my $file_path ( keys %$data ) {
    print "\n";
    print $file_path . encode( "cp932", "にて発見ーーーーーーー\n" );
    foreach my $line_counter ( keys %{$data->{$file_path}} ) {
      my $line = $data->{$file_path}->{$line_counter};
      print "\n";
      print encode( "cp932", "\t${line_counter}行目：：" );
      print $line;
    }
    print "\n";
  }
}

1;
