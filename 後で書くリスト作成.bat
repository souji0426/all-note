cd tool

perl -w make_ToDoLater_list.pl

cd ../

platex ToDo_later_list.tex

dvipdfmx ToDo_later_list.dvi

copy /Y "./ToDo_later_list.pdf" "./後で書くリスト.pdf"

del "./ToDo_later_list.aux"

del "./ToDo_later_list.dvi"

del "./ToDo_later_list.log"

del "./ToDo_later_list.out"

del "./ToDo_later_list.pdf"
