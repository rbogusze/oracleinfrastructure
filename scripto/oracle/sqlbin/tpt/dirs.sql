col dirs_directory_path head DIRECTORY_PATH for a90
col dirs_directory_name head DIRECTORY_NAME for a40 WRAP
col dirs_owner HEAD DIRECTORY_OWNER FOR A30
select owner dirs_owner, directory_name dirs_directory_name, directory_path dirs_directory_path from dba_directories;
