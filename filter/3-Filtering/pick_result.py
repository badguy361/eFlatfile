#2018_0101_0321_57_EDH.B000001.rsp_psv.Horizontal EW
#2018_0101_0321_57_TTN.B000002.rsp_psv.Horizontal EW
#2018_0101_0321_57_EDH.B000001.rsp_psv.Horizontal NS
#2018_0101_0321_57_EDH.B000001.rsp_psv.Vertical

import os
import re
dir_path = "D:/picking/5-Filtering - 複製/5-Filtering - 狡籹/previous result/!2020.08.05_BAK/Filtering Result/PROCESS_FILE_tmp/2018"
os.chdir(dir_path)
dir_name = os.listdir('.')
target_picture = []

for i in range(len(dir_name)):
    picture_path = f"D:/picking/5-Filtering - 複製/5-Filtering - 狡籹/previous result/!2020.08.05_BAK/Filtering Result/PROCESS_FILE_tmp/2018/{dir_name[i]}"
    os.chdir(picture_path)
    all_picture_name = os.listdir('.')

    target_picture.append(re.findall(rf"{dir_name[i]}_\w\w\w.B\d\d\d\d\d\d.rsp_psv.Horizontal EW.png",f"{all_picture_name}"))
    target_picture.append(re.findall(rf"{dir_name[i]}_\w\w\w.B\d\d\d\d\d\d.rsp_psv.Horizontal NS.png",f"{all_picture_name}"))
    target_picture.append(re.findall(rf"{dir_name[i]}_\w\w\w.B\d\d\d\d\d\d.rsp_psv.Vertical.png",f"{all_picture_name}"))

target_picture = ([i for item in target_picture for i in item])
print(len(target_picture))
print(target_picture[0])
print(target_picture[0][0:17])

import shutil
for i in range(len(target_picture)):
    print(f"{i}/{len(target_picture)}")
    shutil.copy2(f"D:/picking/5-Filtering - 複製/5-Filtering - 狡籹/previous result/!2020.08.05_BAK/Filtering Result/PROCESS_FILE_tmp/2018/{target_picture[i][0:17]}/{target_picture[i]}", "D:/picking/5-Filtering - 複製/5-Filtering - 狡籹/previous result/!2020.08.05_BAK/Filtering Result/train_result")

