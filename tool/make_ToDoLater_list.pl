use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
#iniファイルを処理するのに使っている
use File::Basename;
#自身のプログラム名を取得するために必要

require "C:/souji/all-note/tool/common.pl";

main();

sub main {
  my $setting = &common::get_setting();
  my $all_note_tex_file_path = $setting->{"path"}->{"all_note_tex_file"};
  my $part_dir_path = $setting->{"path"}->{"part_dir"};
  my $ToDolater_list_tex_file_path = $setting->{"path"}->{"ToDoLater_list_tex_file"};

  open( my $fh, ">:encoding( cp932 )", encode( "cp932", $ToDolater_list_tex_file_path ) );

  print_tex_preamble( $setting, $fh );

  print $fh "\\begin{document}\n\n";

  my $part_data = &common::get_part_data( $all_note_tex_file_path );

  foreach my $part_counter ( sort keys %$part_data ) {
    my $part_dir_path = $part_data->{$part_counter}->{"path"};
    my $part_name = $part_data->{$part_counter}->{"name"};
    print $fh "\\section\{${part_name}\}\n\n";

    my @ordered_subfile_list;
    &common::get_ordered_subfile_list( \@ordered_subfile_list, $part_dir_path );

    my $ToDoLater_list_data = get_ToDoLater_list_data( \@ordered_subfile_list );

    my $num_of_ToDoLater = keys %$ToDoLater_list_data;
    print $fh "「後でやること」メモは全部で${num_of_ToDoLater}個です.\n\\  \\\\\n\n";

    output_item( $fh, $ToDoLater_list_data );
  }
  print $fh "\\end{document}";
  close $fh;


}

sub print_tex_preamble {
  my ( $setting, $fh ) = @_;

  my $preamble_text = <<'EOS';
\documentclass[a4j,dvipdfmx,10pt]{jarticle}

\usepackage{C:/souji/all-note/preamble/souji_package}
\usepackage{C:/souji/all-note/preamble/souji_macro}
\usepackage{C:/souji/all-note/preamble/souji_thm_style}

%\makeindex

\usepackage{geometry}
\geometry{top=2cm, bottom=2cm, left=1cm, right=1cm, includefoot}

\setlength{\parindent}{0pt}

EOS
  print $fh $preamble_text;

  my $program_name = basename( $0, ".pl" );
  my $title = $setting->{$program_name}->{"title"};
  print $fh "\\usepackage\{fancyhdr\}\n";
  print $fh "\\pagestyle\{fancy\}\n";
  print $fh "\\lhead\{${title}\}\n";
  print $fh "\\rhead\{\\bf\\thepage\}\n\n";

  #print $fh "\\title\{${title}\}\n";
  #print $fh "\\author\{souji\}\n";
  #print $fh "\\date\{\}\n\n";

}

sub get_ToDoLater_list_data {
  my ( $file_path_list ) = @_;
  my $data = {};
  my $coutner = 0;
  foreach my $file_path ( @$file_path_list ) {
    open( my $fh, "<:encoding( cp932 )", encode( "cp932", $file_path ) );
    my $line_counter = 1;
    my $is_target_line = 0;
    my $str = "";
    while( my $line = <$fh> ) {

      if ( $is_target_line ) {

        if ( $line =~ /^\}/ or $line =~ /^\s{1,}\}/ ) {
          $data->{sprintf( "%04d", $coutner )}->{"str"} = $str;
          $data->{sprintf( "%04d", $coutner )}->{"line_counter"} = $line_counter;
          $data->{sprintf( "%04d", $coutner )}->{"file_path"} = $file_path;
          $coutner++;
          $is_target_line = 0;
          $str = "";
        } else {
          $str .= $line;
        }

      } else {

        if ( $line =~ /^\\ToDoLater\{/ ) {
          $is_target_line = 1;
          $data->{sprintf( "%04d", $coutner )} = {};
        }

      }

      $line_counter++;
    }

    close $fh;
  }

  return $data;
}

sub output_item {
  my ( $fh, $ToDoLater_list_data ) = @_;
  foreach my $ToDOLater_counter ( sort keys %$ToDoLater_list_data ) {
    my $file_path = $ToDoLater_list_data->{$ToDOLater_counter}->{"file_path"};
    my $line_counter = $ToDoLater_list_data->{$ToDOLater_counter}->{"line_counter"};
    my $str = $ToDoLater_list_data->{$ToDOLater_counter}->{"str"};
    my $counter_for_output = sprintf( "%d", $ToDOLater_counter );

    my $item_title = "\\begin\{itembox\}\[l\]\{その${counter_for_output}\,（パス）\\path\{"  . $file_path . "\}\}\n";
    print $fh "\\begin\{itembox\}\[l\]\{その${counter_for_output}\}\n";
    print $fh $str . " \\\\\n";
    print $fh "（パス⇒\\path\{"  . $file_path . "\} \\\\\n";
    print $fh "（行数⇒${line_counter}）\n";
    print $fh "\\end\{itembox\}\n\\ \\\\\\vspace\{-0.5cm\}\n";
  }
}


1;
