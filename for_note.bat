taskkill /f /im AcroRd32.exe

del "./note.pdf"

del "./note.dvi"

del "./note.log"

del "./note.out"

del "./note.toc"

cd ./tool

perl -w convert_comma_and_period.pl

pause

cd ../

platex note.tex

pbibtex note -kanji=utf8

platex note.tex

pbibtex note -kanji=utf8

platex note.tex

mendex -S note.idx

mendex -S note.idx

platex note.tex

dvipdfmx note.dvi

copy /Y "./note.pdf" "./soujiノート.pdf"

copy /Y "./note.pdf" "C:\souji\soujiノート公開用リポジトリ\soujiノート公開用.pdf"

del "./note.dvi"

del "./note.log"

del "./note.ilg"

del "./note.out"

del "./note.toc"

del "./note.pdf"

cd ./tool

perl -w check_atode_list.pl

cd ../

"./soujiノート.pdf"
