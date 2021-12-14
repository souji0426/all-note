taskkill /f /im AcroRd32.exe

del "./note.dvi"

del "./note.ilg"

del "./note.aux"

del "./note.bbl"

del "./note.blg"

del "./note.idx"

del "./note.ind"

del "./note.log"

del "./note.out"

del "./note.toc"

del "./note.pdf"

cd ./tool

perl -w make_atode_list.pl

perl -w make_kongo_list.pl

perl -w summarize_def_and_thm.pl

perl -w make_symbol_list.pl

perl -w convert_comma_and_period.pl

pause

cd ../

platex note.tex

pbibtex note -kanji=sjis

platex note.tex

pbibtex note -kanji=sjis

platex note.tex

mendex -S note.idx

mendex -S note.idx

platex note.tex

dvipdfmx note.dvi

copy /Y "./note.pdf" "./soujiノート.pdf"

del "./note.dvi"

rem del "./note.log"

del "./note.ilg"

del "./note.out"

del "./note.toc"

del "./note.pdf"

"./soujiノート.pdf"
