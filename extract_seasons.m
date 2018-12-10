function [ser_time_mean_first,ser_time_mean_last,ser_time_mean_middle,data_season,indices]= calc_seasonal_means(ser_time,data,season,data_treshold,missing_option)
% [ser_time_mean_first,ser_time_mean_last,ser_time_mean_middle,data_mean]= calc_seasonal_means(ser_time,data,season,data_treshold,missing_option)
%
% PURPOSE
% Extract seasonal values (not means) for analysing STD, COR and RMSEs 
%
% NOTE: This is done by first calculating monthly means then make the seasonal mean of the 
%        monthly means (thus each month is weighted equally regardless of how many days 
%        there is in the month)
%
%
%  INPUT
% ser_time  - serial time  
%                           a 1-D vector
%                           ser_time(times) 
%
% data      - data to make mean over 
%                           Data may be a 1-D vector
%                           (data(times) or a
%                           2-D array
%                           data(gridpoints,times)
%             NOTE: data can be anything from hourly to monthly data
%
% season - list of months to make seasonal mean over
%          EX: season=[12 1 2] gives DJF seasonal mean (NB [12 1 2] is not the same as [1 2 12]) 
%              season=[6 7 8]  gives JJA seasonal mean 
%              season=[1:1:12] or season=[1:2:3.4.5.6.7.8.9.10:11:12]  gives annual mean
%          NOTE: seasonal mean  will not jump over any months! So season=[6 8] will give you the same as season=[6 7 8]
%
% data_treshold - says how many % of the data that can be missing and still make the
%                 seasonal mean (between 0 and 100 were 0 means that no data can be missing)
%
% missing_option  - flag on how to treat missing values if there is less missing values than data_treshold 
%                   missing_option=1 Just ignore the missing data 
%                   missing_option=2  Fill in the missing values with the mean of all the existing data 
%                                     for that season 
%                                    For example if a January value is missing it is filled 
%                                    with the mean of all the  January data for all the years 
%
% OUTPUT
%  
% ser_time_mean_middle - serial time indicating the midle day for
%                       the mean (always taken as the 15th)
%                       
% ser_time_mean_first - serial time indicating the first day in the mean
%                       
% ser_time_mean_last - serial time indicating the last day in the mean
%                        
% 
% data_seasmean          - mean over the season
%
%
% USES: calc_monthly_means.m
%
% EXAMPLE: 
% Make seasonal means for month which have less than 10% of the data missing
% [ser_time_mean_first,ser_time_mean_last,ser_time_mean_middle,data_mean]= calc_monthly_means(ser_time,data,10,1)
%
%
% Author: Asgeir Sorteberg, 
%         Bjerknes Centre for Climate Research, University of Bergen.
%         email: asgeir.sorteberg@bjerknes.uib.no
% 
%         Dec 2011
% Modified: Muralidhar Adakudlu
% March 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make sure data is in the correct way
dim1_data=size(data,1);
dim2_data=size(data,2);
dim_ser_time=length(ser_time);

if dim1_data~=dim_ser_time
  data=data';
end

if size(data,1)~=dim_ser_time
  disp(['calc_seasonal_means: ERROR: data and ser_time does not have same dimensions'])
  return
end

% date vector
[yyyy,mm,dd,hh,minute,secs]=datevec(ser_time);
no_yyyymm=length(unique(yyyy))*length(unique(mm));

% make the monthly means
			     
% if data is not already monthly make monthly means
if length(ser_time)~=no_yyyymm
  [ser_time_mean_first,ser_time_mean_last,ser_time_mean_middle,data_monthly_mean]= calc_monthly_means(ser_time,data,data_treshold,missing_option);
   ser_time_monthly=ser_time_mean_middle;
else
  %disp('We have monthly means')  
  data_monthly_mean=data;
  ser_time_monthly=ser_time;
end

yrs=unique(yyyy);

disp(['calc_seasonal_means: calculate seasonal means for months: ' num2str(season)])
% initialize
ser_time_seasonal_mean_first=ones(length(yrs),1)*NaN;
ser_time_seasonal_mean_last=ones(length(yrs),1)*NaN;
ser_time_seasonal_mean_middle=ones(length(yrs),1)*NaN;
data_season=ones(size(season,2)*length(yrs),size(data_monthly_mean,2))*NaN;
indices = zeros(size(season,2)*length(yrs),0); % create an empty matrix for storing the seasonal indices for each year

% make seasonal mean for each year
no_zero_flag_indx_previous=[];
for i=1:length(yrs)
   if season(1)<season(end)
       indx=find(yyyy==yrs(i));
       [dummy,member_flag]=ismember(mm(indx),season);  
       no_zero_flag_indx=find(member_flag>0);
       no_zero_flags=member_flag(no_zero_flag_indx);
       start_indx=find(no_zero_flags==min(no_zero_flags));
       start_indx=start_indx(1);
       end_indx=find(no_zero_flags==max(no_zero_flags));
       end_indx=end_indx(end);
   elseif season(1)>season(end)
       indx=find(yyyy>=yrs(i)-1 & yyyy<=yrs(i));
       start_indx=find(mm(indx)==season(1));
       start_indx=start_indx(1);
       end_indx=start_indx(1)+length(season)-1;
       if end_indx>length(indx)
           end_indx=length(indx);
       end
       [dummy,member_flag]=ismember(mm(indx),season);  
       no_zero_flag_indx=find(member_flag>0);
       no_zero_flag_indx=no_zero_flag_indx(find(no_zero_flag_indx>=start_indx & no_zero_flag_indx<=end_indx));
       no_zero_flags=member_flag(no_zero_flag_indx);
       start_indx=find(no_zero_flags==min(no_zero_flags));
       start_indx=start_indx(1);
       end_indx=find(no_zero_flags==max(no_zero_flags));
       end_indx=end_indx(end);
   end
  if start_indx<end_indx
    start_indx2=indx(no_zero_flag_indx(start_indx));
    end_indx2=indx(no_zero_flag_indx(end_indx));
    ser_time_seasonal_mean_first(i)=ser_time_monthly(start_indx2);
    ser_time_seasonal_mean_last(i)=ser_time_monthly(end_indx2);
    ser_time_seasonal_mean_middle(i)=mean([ser_time_seasonal_mean_first(i) ser_time_seasonal_mean_last(i)]);
    
    indices = [indices start_indx2:end_indx2];
    
  else
    ser_time_seasonal_mean_first(i)=datenum(yyyy(i)-1,season(1),dd(season(1)),hh(season(1)),0,0);
    ser_time_seasonal_mean_last(i)=ser_time_monthly(indx(no_zero_flag_indx(end_indx)));
    ser_time_seasonal_mean_middle(i)=mean([ser_time_seasonal_mean_first(i) ser_time_seasonal_mean_last(i)]);
    %data_season(i,:)=NaN;
  end
% check dates
  if ser_time_seasonal_mean_first(i)>ser_time_seasonal_mean_last(i)
    disp(['calc_seasonal_means: ERROR: First date in seasonal mean is larger than last'])
    return
  end
end

% rename
ser_time_mean_first=ser_time_seasonal_mean_first;
ser_time_mean_last=ser_time_seasonal_mean_last;
ser_time_mean_middle=ser_time_seasonal_mean_middle;
data_season=data_monthly_mean(indices,:);

disp(['extract_seasons: Finished'])

 
