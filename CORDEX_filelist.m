function [CORDEX_no_files,CORDEX_files]=CORDEX_filelist(CORDEX_directory) 

% PURPOSE
%
% List files in a chosen directory
% 
%
% Author: Asgeir Sorteberg, 
%         Geophysical Institute, University of Bergen.
%         email: asgeir.sorteberg@gfi.uib.no
% 
%         Jul 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 




% check that directory exist
if ~exist(CORDEX_directory,'dir')
  disp([ 'CORDEX_filelist:  WARNING: Directory ' CORDEX_directory ' do not exist'])
  CORDEX_no_files=0;
  CORDEX_files=' ';
  return
end

%% list files in directory

% clean up first
eval(['!rm -fr CORDEX_filelist'])
eval(['!rm -fr CORDEX_filelist2'])

% Check if the directory name has any whitespace ( % Muralidhar) -- now works only for a single white space.

i  = find(isspace(CORDEX_directory));

if (length(i) == 1)
	a1      = CORDEX_directory(1,1:i-1);
	a2      = CORDEX_directory(1,i+1:end);
	new_dir = [a1 '\ ' a2];
elseif (length(i) > 1)
	disp('There are more than one blank space in the name. Cant continue');
    return
else
    new_dir = CORDEX_directory;
end    
    
eval(['!ls ' new_dir '>>CORDEX_filelist'])
% number of files and length of the names
eval(['!wc -lL CORDEX_filelist>>CORDEX_filelist2'])
[CORDEX_no_files,filelength]=textread('CORDEX_filelist2','%n%n%*[^\n]');

% read in the list of files
eval(['[CORDEX_files]=textread(' '''CORDEX_filelist''' ',' '''%' num2str(filelength) 'c%*[^\n]''' ');'])

% clean up
eval(['!rm -fr CORDEX_filelist'])
eval(['!rm -fr CORDEX_filelist2'])

disp([ 'CORDEX_filelist:  Directory: ' new_dir])
disp([ 'CORDEX_filelist:  Found ' num2str(CORDEX_no_files) ' files'])
disp([ 'CORDEX_filelist:  Finished'])
