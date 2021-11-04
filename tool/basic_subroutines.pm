use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use Config::Tiny;
use Time::Piece;
#���t����ɕK�v

#�f�o�b�O�△���z��̒��g���m�F���邽�߂̊J���T�|�[�g�֐��[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[
sub output_file {
  my ( $ref ) = @_;
  open( my $fh, ">", "./test.txt" );
  print $fh Dumper $ref;
  close $fh;
}


#�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[

#�t�@�C���E�f�B���N�g������֘A�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[

#�w�肵���f�B���N�g���Ƃ��̒����ɂ���f�B���N�g���S�ĂɊ܂܂��t�@�C���̃p�X��Ԃ��T�u���[�`���B
sub get_file_path_in_dir_and_all_sub_dir {
  my ( $target_path ) = @_;
  my @file_paths;
  my @dir_paths = glob( $target_path . "/*" );
  foreach my $path ( @dir_paths ) {
    if ( -d $path ) {
      push ( @dir_paths, glob( $path . "/*" ) );
    } elsif ( -f $path ) {
      push ( @file_paths, $path );
    }
  }
  return \@file_paths;
}

#�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[

#���t����֘A�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[

#�����̓��t��yyyymmdd�`���Ŏ擾���ĕԂ��B
sub get_today_yyyymmdd {
  my $today = localtime;

  my $year = $today->year;
  my $month_str = sprintf( "%02d", $today->mon );
  my $day_str = sprintf( "%02d", $today->mday );

  return join( "", ( $year, $month_str, $day_str ) );
}

#�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[


1;
