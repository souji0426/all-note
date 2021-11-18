# -*- encoding: utf-8 -*-
require "inifile"
require "rubyXL"
require "rubyXL/convenience_methods"
#xlsxに書き込むために使用

def main
  ini = IniFile.load( "./setting.ini" )

  data_in_katari_xlsx = read_katari_xlsx( ini )

  #data_hash_for_output = make_output_data( ini, data_in_input_xlsx )

  #add_note_data( ini, data_hash_for_output, data_in_input_xlsx )

  output_csv( ini, data_in_katari_xlsx )

end

def read_katari_xlsx( ini )
  data = {}
  input_xlsx_path = ini["tool_for_katari"]["katari_xlsx_path"]
  sheet_name_array = ini["tool_for_katari"]["sheet_names"].split( "," )

  xlsx = RubyXL::Parser.parse( input_xlsx_path )

  for sheet_name in sheet_name_array do
    sheet = xlsx[sheet_name]
    num_of_row = get_last_row( sheet )
    for num in 1..num_of_row do
      one_line_in_xlsx_to_hash( ini, data, sheet_name, sheet, num )
    end
  end

  return data
end

def get_last_row( sheet )
  not_last = true
  counter = 0
  while not_last do
    if sheet.nil? or sheet[counter].nil? or sheet[counter][0].nil? or sheet[counter][0].value.nil? then
      not_last = false
      counter-=1
    else
      counter+=1
    end
  end

  return counter
end

def one_line_in_xlsx_to_hash(  ini, data, sheet_name, sheet, row )
  header_list_array = ini["tool_for_katari"]["header_list"].split( "," )

   if !data.has_key?( sheet_name ) then
     data[sheet_name] = Hash.new()
   end

   num = sheet[row][0].value
   data[sheet_name][num] = Hash.new()

   for i in 1..header_list_array.length-1 do
     item_name = header_list_array[i]
     data[sheet_name][num][item_name]  = sheet[row][i].value
   end

end

def output_csv( ini, data_hash )
  csv_path = ini["tool_for_katari"]["katari_csv_path"]
  File.open( csv_path, mode = "w" ) { |f|
    data_hash.each_key { |sheet_name|
      data_hash[sheet_name].each_key { |num|
        f.write( "#{sheet_name}\t#{num}" )
        data_hash[sheet_name][num].each_key { |key|
            f.write( "\t#{data_hash[sheet_name][num][key]}" )
        }
        f.write( "\n" )
      }
    }
  }
end

main()
