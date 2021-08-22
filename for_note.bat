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

copy /Y "./note.pdf" "./soujiÉmÅ[Ég.pdf"

del "./note.aux"

del "./note.dvi"

del "./note.log"

del "./note.ilg"

del "./note.out"

del "./note.toc"

rem del "./note.idx"

del "./note.bbl"

rem del "./note.ind"

del "./note.blg"

"./note.pdf"
