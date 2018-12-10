function [CORDEX_directory,GCMs,model_runs,RCMs,data_exist_flag,models_with_all_data,models_with_some_data]=CORDEX_check_data_existence(cordex_var,scenario,frequency,start_year,end_year) 

% PURPOSE
%
% Check which models have data for a chosen parameter, scenario, frequency and time period
%
% INPUT
% CORDEX_var: Any CORDEX data variable name
%            The list is here: http://cmip-pcmdi.llnl.gov/CORDEX/data_description.html
%            Examples
%                 tas: 2m temperature
%                  pr: Precipitation
%                 psl: Sea level pressure          
% scenario
%
%           historical      Historical 1951--> all forcings 
%           rcp45  
%           rcp85 
%           rcp26  
%           rcp60  
%  frequency  - Frequency of outpout
%               mon: monthly
%               day: daily
%               6hr: 6 hourly
%               3hr: 3 hourly
%
%  start_year - Start year for data that should be read (must be between 1958 and 2002) 
%  end_year   - End year for data that should be read (must be between 1958 and 2002)   
%
%
% OUTPUT
%
% model - list of models
%
% data_exist_flag - 0: Data exist for chosen period
%                   1: Data exist, but only for part of the chosen period
%                   2: Data do not exist for chosen period
%
% models_with_all_data - list of models that have data for whole period
% models_with_some_data - list of models that have data for parts of the  period
%
% Author: Asgeir Sorteberg, 
%         Geophysical Institute, University of Bergen.
%         email: asgeir.sorteberg@gfi.uib.no
% 
%         Jul 2012
% modified by Stephanie Mayer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% institute=[%'DMI        '; ...
%          % 'IPSL-INERIS'; ...
%            'SMHI       '; ...
%          %  'CLMcom     '; ...
%          %   'KNMI       '; ...
%          %   'MPI-CSC    '; ...
%            ];

GCM=['ECMWF-ERAINT_evaluation'; ...
     'ICHEC-EC-EARTH         '; ...
     'CCCma-CanESM2          '; ...
     'MPI-M-MPI-ESM-LR       '; ...
     'NCC-NorESM1-M          ';
     ];   

RCM=['AWI-HIRHAM5   '; ...
     'DMI-HIRHAM5   '; ...
     'SMHI-RCA4     '; ...
     'SMHI-RCA4-SN  '; ...
     'UQAM-CRCM5    '; ...
     'UQAM-CRCM5-SN '; ...
     'UNI-WRF       '; ...
     'MGO-RRCM      '; ...
     'ULg-MAR       '; ...
     'CCCma-CanRCM4 '; ...
     'MOHC-HadRMP   '; ...
      ]; 

model_run=['r3i1p1 '; ...
           'r12i1p1'; ...
           'r1i1p1 '; ...
           'r2i1p1 '; ...
           'r4i1p1 '; ...
           'r5i1p1 '; ...
           'r6i1p1 '; ...
           'r7i1p1 '; ...
           'r8i1p1 '; ...
           'r9i1p1 '; ...
           'r10i1p1'; ...
           'r11i1p1'; ...
  ];
       
%no_institutes=size(institute,1);
no_GCMs=size(GCM,1);
no_runs=size(model_run,1);
no_RCMs=size(RCM,1);

count2=1;
for ll=1:no_GCMs;
   
     check_dir = exist( ['/media/mad042/My Passport/Data/CORDEX/' deblank(scenario) '/' deblank(cordex_var) '/' deblank(frequency) '/' deblank(GCM(ll,:))], 'dir' );
     if (check_dir == 7)
        
          disp([ 'read_CORDEX_2D_data:  GCM: ' GCM(ll,:)])            
          for kk=1:no_runs;
      
                check_dir = exist( ['/media/mad042/My Passport/Data/CORDEX/' deblank(scenario) '/' deblank(cordex_var) '/' deblank(frequency) '/' deblank(GCM(ll,:)) '/' deblank(model_run(kk,:))], 'dir' );
                if (check_dir == 7)
                         
                      disp([ '                      model run: ' model_run(kk,:)])      
                      for nn=1:no_RCMs;
 
                          check_dir = exist( ['/media/mad042/My Passport/Data/CORDEX/' deblank(scenario) '/' deblank(cordex_var) '/' deblank(frequency) '/' deblank(GCM(ll,:)) '/' deblank(model_run(kk,:))  '/' deblank(RCM(nn,:))], 'dir' );
                          
                          if (check_dir == 7)

                                disp([ '                      RCM: ' RCM(nn,:)])
 
% ---------------------
% CORDEX directory 
% ---------------------
                                CORDEX_directory=['/media/mad042/My Passport/Data/CORDEX/' deblank(scenario) '/' deblank(cordex_var) '/' deblank(frequency) '/' deblank(GCM(ll,:))  '/' deblank(model_run(kk,:)) '/' deblank(RCM(nn,:))  '/';];
			      
                                GCMs(count2,:)=GCM(ll,:);
                                model_runs(count2,:)=model_run(kk,:);
                                RCMs(count2,:)=RCM(nn,:);
          
% ---------------------
% get list of files for chosen model, simulation etc
% ---------------------
                                [CORDEX_no_files,CORDEX_files]=CORDEX_filelist(CORDEX_directory);
 disp(CORDEX_no_files)                               

                                if CORDEX_no_files>0
% ---------------------
% check which files are needed to have data for the chosen years
% ---------------------
                                        [CORDEX_files_flag]=CORDEX_file_flag(CORDEX_directory,CORDEX_files,start_year,end_year);

% ---------------------
% Read times from chosen files
% ---------------------
                                        if sum(CORDEX_files_flag)>0
    
                                               % number of files
                                                no_files=size(CORDEX_files,1);

                                               % files to read
                                                count=0;
                                                clear CORDEX_file
                                                for i=1:no_files
                                                        if CORDEX_files_flag(i)==1
                                                                count=count+1;
                                                                CORDEX_file(count,:)=CORDEX_files(i,:);
                                                        end
                                                end

                                                no_files=size(CORDEX_file,1);
                                                                                                
                                                for i=1:no_files
                                                        ncfile=[CORDEX_directory deblank(CORDEX_file(i,:))];
			% read time
                                                        [gregorian_time,CORDEX_ser_time1]=timenc(ncfile,'time');
			   
			%    find calendar
                                                        if i==1
                                                                [att_lname, att_names] = attnc(ncfile,'time','calendar');
                                                                if isempty(att_lname)
                                                                        CORDEX_time_calendar= ' ';
                                                                else  
                                                                        CORDEX_time_calendar= att_lname; 
                                                                end
                                                                disp(['CORDEX_read_time_area_slice: NOTE: Calendar used: ' CORDEX_time_calendar])
                                                        %end
			     
                                                        %if i==1
                                                                CORDEX_ser_time=CORDEX_ser_time1';
                                                        else
                                                                CORDEX_ser_time=[CORDEX_ser_time CORDEX_ser_time1'];
                                                        end
                                                 end


% sort times since they may not be in correct order as we have not
% nessecarily read the file in correct order
                                                                                
                                        [dummy,indx_sort]=sort(CORDEX_ser_time);
                                        CORDEX_ser_time=CORDEX_ser_time(indx_sort);
                                                                          			        
                                        % Make sure data begins and ends at right dates
                                        [yyyy,mm,dd,mi,ss]=datevec(CORDEX_ser_time);

                                        indx=find(yyyy>=start_year & yyyy<=end_year);
                                        CORDEX_ser_time=CORDEX_ser_time(indx);

                                        start_yr=str2num(datestr(CORDEX_ser_time(1),10));
                                        end_yr=str2num(datestr(CORDEX_ser_time(end),10));

% ---------------------
% Check that you have data for the whole period requested
% ---------------------
                                        [CORDEX_time_check_flag]=CORDEX_time_check(CORDEX_ser_time,CORDEX_time_calendar,start_year,end_year,frequency);
                                        else                               % No files to read   
                                                CORDEX_time_check_flag=1;
                                                CORDEX_files_flag=0;
                                        end
                                                                                                          
                                        % save info about modelrun
                                        if sum(CORDEX_files_flag)==0 || CORDEX_no_files==0
                                                data_exist_flag(count2)=2;
                                                text_string(count2,:)=[GCM(ll,:) '   '  model_run(kk,:) '   ' cordex_var  '             ' frequency '        ' scenario '   '  RCM(nn,:) '         '  num2str(data_exist_flag(count2)) '          ---  ---'];
                                        elseif CORDEX_time_check_flag==1      % => only part of the desired period exists
                                                data_exist_flag(count2)=1;
                                                text_string(count2,:)=[GCM(ll,:) '   '  model_run(kk,:) '   ' cordex_var  '             ' frequency '        ' scenario '   '  RCM(nn,:) '         '  num2str(data_exist_flag(count2)) '         '  num2str(start_yr)    '-'   num2str(end_yr)];
                                        elseif CORDEX_time_check_flag==0      % => Whole desired period exists
                                                data_exist_flag(count2)=0;
                                                text_string(count2,:)=[GCM(ll,:) '   '  model_run(kk,:) '   ' cordex_var  '             ' frequency '        ' scenario '   '  RCM(nn,:) '         '  num2str(data_exist_flag(count2)) '         '  num2str(start_yr)    '-'   num2str(end_yr)];
                                        end
                                count2 = count2+1;
                                end    % line # 138
                          end
                      end
                end
          end
     end      
end

% list info
disp('CORDEX_check_existing_data:')
disp('GCM                       RUN      VARIABLE      FREQUENCY     SCENARIO      RCM                 EXIST     START YR-END YR')
disp(text_string);

% models with all data
indx=find(data_exist_flag==0);
count3=1;
for k=1:length(indx)
    if k==1
        models_with_all_data(count3,:)=GCMs(indx(k),:);
        count3=count3+1;
    else
        if ~strcmp(GCMs(indx(k),:),GCMs(indx(k-1),:))
          models_with_all_data(count3,:)=GCMs(indx(k),:);
          count3=count3+1;
        end
    end
end
if ~exist('models_with_all_data','var')
   models_with_all_data='none';
end

% models with some data    
indx=find(data_exist_flag==1);
count3=1;
for k=1:length(indx)
    if k==1
        models_with_some_data(count3,:)=GCMs(indx(k),:);
        count3=count3+1;
    else
        if ~strcmp(GCMs(indx(k),:),GCMs(indx(k-1),:))
          models_with_some_data(count3,:)=GCMs(indx(k),:);
          count3=count3+1;
        end
    end
end
if ~exist('models_with_some_data','var')
   models_with_some_data='none';
end

% Muralidhar - We want all those directories where the data will be read
% from, not just the last directory
%clear CORDEX_directory
%CORDEX_directory = directory;

% count models with data
disp(['CORDEX_check_existing_data: Models with data for whole period:                   ' num2str(size(models_with_all_data,1))])
disp(['CORDEX_check_existing_data:       Simulations with data for whole period:        ' num2str(length(find(data_exist_flag==0)))])
disp(['CORDEX_check_existing_data: Models with data for parts of the period:            ' num2str(size(models_with_some_data,1))]) 
disp(['CORDEX_check_existing_data:       Simulations with data for parts of the period: ' num2str(length(find(data_exist_flag==1)))])

disp('CORDEX_check_existing_data: Finished')
