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

copy /Y "./note.pdf" "./souji�m�[�g.pdf"

copy /Y "./note.pdf" "C:\souji\souji�m�[�g���J�p���|�W�g��\souji�m�[�g���J�p.pdf"

del "./note.dvi"

del "./note.log"

del "./note.ilg"

del "./note.out"

del "./note.toc"

del "./note.pdf"

cd ./tool

perl -w check_atode_list.pl

cd ../

"./souji�m�[�g.pdf"
