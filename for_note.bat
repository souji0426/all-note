taskkill /f /im AcroRd32.exe

del "./note.pdf"

del "./note.aux"

del "./note.bbl"

del "./note.dvi"

del "./note.idx"

del "./note.log"

del "./note.out"

del "./note.toc"

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

copy /Y "./note.pdf" "C:/souji\souji�m�[�g���J�p���|�W�g��/souji�m�[�g���J�p.pdf"

del "./note.aux"

del "./note.dvi"

del "./note.log"

del "./note.ilg"

del "./note.out"

del "./note.toc"

del "./note.idx"

del "./note.bbl"

del "./note.ind"

del "./note.blg"

del "./note.pdf"

"./souji�m�[�g.pdf"
