taskkill /f /im AcroRd32.exe

del "./note.pdf"

del "./note.dvi"

del "./note.log"

rem cd ./tool

rem perl -w delete_all_unnecessary_file.pl

rem perl -w make_atode_list.pl

rem perl -w make_kongo_list.pl

rem perl -w summarize_def_and_thm.pl

rem perl -w make_symbol_list.pl

rem perl -w convert_comma_and_period.pl

rem pause

rem cd ../

platex note.tex

pbibtex note -kanji=sjis

platex note.tex

pbibtex note -kanji=sjis

platex note.tex

mendex -S note.idx

mendex -S note.idx

platex note.tex

dvipdfmx note.dvi

copy /Y "./note.pdf" "./souji�m�[�g.pdf"

copy /Y "./souji�m�[�g.pdf" "C:/Google�h���C�u���L�p�t�H���_/PDF�t�H���_/souji�m�[�g.pdf"

rem copy /Y "./note.pdf" "C:\souji\souji�m�[�g���J�p���|�W�g��\souji�m�[�g���J�p.pdf"

del "./note.dvi"

del "./note.log"

del "./note.ilg"

del "./note.out"

del "./note.toc"

del "./note.pdf"

del "./note.aux"

del "./note.bbl"

del "./note.idx"

del "./note.ind"

del "./note.blg"

cd C:\souji\mini-notes

call �ꊇ���s.bat
