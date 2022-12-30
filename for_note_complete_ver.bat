taskkill /f /im AcroRd32.exe

del "./note.pdf"

del "./note.dvi"

del "./note.log"

rem cd ./tool

perl -w delete_all_unnecessary_file.pl

perl -w make_symbol_list.pl

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

copy /Y "./note.pdf" "./soujiノート.pdf"

copy /Y "./soujiノート.pdf" "C:/Googleドライブ共有用フォルダ/PDFフォルダ/soujiノート.pdf"

rem copy /Y "./note.pdf" "C:\souji\soujiノート公開用リポジトリ\soujiノート公開用.pdf"

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

call 一括実行.bat
