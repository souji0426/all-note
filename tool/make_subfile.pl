use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;

my $target_tex_file_path = $ARGV[0];
my $target_dir_path = get_dir( $target_tex_file_path );

my @subfile_path_list;
open( my $fh, "<:encoding( cp932 )", $target_tex_file_path );
while ( my $line = <$fh> ) {
  chomp $line;
  if ( $line =~ /.subfile\{(.+)\}$/ ) {
    push( @subfile_path_list, $1 );
  }
}
close $fh;

foreach my $path ( @subfile_path_list ) {
  my @data = split( "/", $path );
  my $dir_name = $data[0];
  my $file_name = $data[1];
  my $dir_path = $target_dir_path . "/".  encode( "cp932", $dir_name );
  if ( !-d $dir_path ) {
    mkdir $dir_path;
  }
  my $target_tex_file_path =  $target_dir_path . "/".  encode( "cp932", $path );
  if ( -f $target_tex_file_path ) {
    print encode( "cp932", "\n\t skip:${file_name}\n\n" );
  } else {
    print encode( "cp932", "\n\t output:${file_name}\n\n" );
    open( my $fh, ">:encoding( cp932 )", $target_tex_file_path );
    print $fh  "\\documentclass\[C:/souji/all-note/note\]\{subfiles\}\n\n";
    print $fh "\\begin\{document\}\n\n";
    print_def_templete( $fh );
    print $fh "\\end\{document\}\n\n";
    close $fh;
  }
}

sub get_dir {
  my ( $file_path ) = @_;
  my @data = split( "/", $file_path );
  pop @data;
  return join( "/", @data );
}

sub print_def_templete {
  my ( $fh ) = @_;
  my $text = <<"EOS";
\\begin\{definition\}\[定義\]
  \\labe\l{definition\:定義\}
\\end\{definition\}
%\\index\{function\}
%\\index\{function!domain\}
%\\index\{かんすう\@写像・関数\}
%\\index\{かんすう\@写像・関数!ちいき\@値域\}


EOS
  print $fh $text;
}

1;
