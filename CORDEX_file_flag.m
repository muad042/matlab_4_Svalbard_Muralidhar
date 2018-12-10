function [CORDEX_files_flag]=CORDEX_file_flag(CORDEX_directory,CORDEX_files,start_year,end_year)

% PURPOSE
% find which files need to be read.
% 
%
% Author: Asgeir Sorteberg, 
%         Geophysical Institute, University of Bergen.
%         email: asgeir.sorteberg@gfi.uib.no
% 
%         Jul 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% number of files
no_files=size(CORDEX_files,1);

CORDEX_files_flag=zeros(1,no_files);

% read times in each file
CORDEX_files_flag(1:no_files)=0;
disp('CORDEX_file_flag: read times on file ....')

for i=1:no_files
    ncfile=[CORDEX_directory deblank(CORDEX_files(i,:))];
    %disp(ncfile);   % to check which file is not read, if any
    [gregorian_time,serial_time]=timenc(ncfile,'time');
    [yyyy,mm,dd,mi,sec]=datevec(serial_time);
        
    if yyyy(1)>=start_year
        if yyyy(end)<=end_year
            CORDEX_files_flag(i)=1;
        end
    end
    
    if (start_year>=yyyy(1) & start_year<=yyyy(end))
        CORDEX_files_flag(i)=1;
    end
    if (end_year>=yyyy(1) & end_year<=yyyy(end))
        CORDEX_files_flag(i)=1;
    end   
end
disp(['CORDEX_file_flag: Number of files that must be read: ' num2str(sum(CORDEX_files_flag))])
disp('CORDEX_file_flag: Finished')
