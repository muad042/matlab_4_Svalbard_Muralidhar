function [CORDEX_time_check_flag]=CORDEX_time_check(CORDEX_ser_time,CORDEX_time_calendar,start_year,end_year,frequency)

% PURPOSE
% Check if times are covering the whole chosen period and not
% just part of it 
%
% Author: Asgeir Sorteberg, 
%         Geophysical Institute, University of Bergen.
%         email: asgeir.sorteberg@gfi.uib.no
% 
%         Jul 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
CORDEX_time_check_flag=0;

% Start and end dates
    start_yr=str2num(datestr(CORDEX_ser_time(1),10));
    start_mm=str2num(datestr(CORDEX_ser_time(1),5));
    start_dd=str2num(datestr(CORDEX_ser_time(1),7));
    end_yr=str2num(datestr(CORDEX_ser_time(end),10));
    end_mm=str2num(datestr(CORDEX_ser_time(end),5));
    end_dd=str2num(datestr(CORDEX_ser_time(end),7));   


if strcmp(frequency,'mon') 
    if start_yr~=start_year | start_mm~=1
        disp(['CORDEX_time_check: WARNING: Start date is not ' num2str(start_year) '-01'])
        CORDEX_time_check_flag=1;
    end
    if end_yr~=end_year | end_mm~=12
        disp(['CORDEX_time_check: WARNING: End date is not ' num2str(end_year) '-12'])
        CORDEX_time_check_flag=1;
    end
elseif  strcmp(frequency,'day') | strcmp(frequency,'6hr') | strcmp(frequency,'3hr')
    if start_yr~=start_year | start_mm~=1 | start_dd~=1
        disp(['CORDEX_time_check: WARNING: Start date is not ' num2str(start_year) '-01-01'])
        CORDEX_time_check_flag=1;
    end
   if ~strcmp(CORDEX_time_calendar,'365_day')
       if end_yr~=end_year | end_mm~=12 | end_dd~=31
           disp(['CORDEX_time_check: WARNING: End date is not ' num2str(end_year) '-12-31'])
           CORDEX_time_check_flag=1;
       end
   end
   
%    % special case for 360 days models
%       if strcmp(CORDEX_time_calendar,'360_day')
%           if end_yr~=end_year | end_mm~=12 | end_dd~=30 
%               disp(['CORDEX_time_check: ERROR: End date is not ' num2str(end_yr) '-12-30'])
%               CORDEX_time_check_flag=1;
%           end
           
%    end

end

if CORDEX_time_check_flag==0
    disp(['CORDEX_time_check: Data for whole selected period found'])
end
disp(['CORDEX_time_check: Finished'])
