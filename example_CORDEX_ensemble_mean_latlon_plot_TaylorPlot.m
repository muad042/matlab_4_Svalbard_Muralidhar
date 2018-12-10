%% PURPOSE
% Retrieve cordex data for a chosen parameter and make a
% Taylor plot for the time and area mean for each ensemble
% member w.r.t a given observational/reanalysis data

clear; close all; 

path(path,'~/MATLAB/rmse');
path(path,'~/MATLAB/PARADIGM/PeterRochford-SkillMetricsToolbox-d7ea0d3');
path(path,'~/MATLAB/PARADIGM/PeterRochford-SkillMetricsToolbox-d7ea0d3/Examples');

% selected 
language='E';% the alternative is Norwegian
hist_scenario='historical'; 
cordex_var='pr';
frequency='mon'; 

% start and end years
hist_start_year=1971; hist_end_year=2000; 

% selected region 
polygon_lon=[5; 37; 37; 5; 5 ]; polygon_lat=[76.2; 76.2; 81.4; 81.4;76.2];% Svalbard 
nw_corner=[min(polygon_lon) max(polygon_lat)]; se_corner=[max(polygon_lon) min(polygon_lat)];

% selected season
data_treshold=0;
missing_option=1;
  season=1:1:12; seas='ANN';
%  season=[12 1 2]; seas='DJF';
%  season=[3 4 5]; seas = 'MAM';
%  season=[6 7 8]; seas = 'JJA';
% season=[9 10 11]; seas = 'SON';
 
% New common grid to store the data
    dlon=.44;
    dlat=.44;
    cordex_lon=nw_corner(1):dlon:se_corner(1);
    cordex_lat=se_corner(2):dlat:nw_corner(2);
    xdim=length(cordex_lon);
    ydim=length(cordex_lat);
    [cordex_lon,cordex_lat]=meshgrid(cordex_lon,cordex_lat);
    lon_grid = cordex_lon;
    lat_grid = cordex_lat;
    cordex_lon=reshape(cordex_lon,1,ydim*xdim);
    cordex_lat=reshape(cordex_lat,1,ydim*xdim);
  
% ----------------------------
% find models that have data for both historical and future run
% ----------------------------

%% historical
[hist_CORDEX_directory,hist_GCMs,hist_model_runs,hist_RCMs,hist_data_exist_flag,hist_models_with_all_data,hist_models_with_some_data]...
    =CORDEX_check_data_existence(cordex_var,hist_scenario,frequency,hist_start_year,hist_end_year);

% get models that have data for whole or part of the requested period
indx=find(hist_data_exist_flag<2);
GCMs=hist_GCMs(indx,:);
model_runs=hist_model_runs(indx,:);

% Locations for area mean over Svalbard for each model
shape_no=2;
shape_file_land='/Data/gfi/share/ObsData/WORLD_SHAPEFILES/cntry00';
cntry_shape=shaperead(shape_file_land,'UseGeoCoords', false);
lon_cntry=cntry_shape(shape_no).X;
lat_cntry=cntry_shape(shape_no).Y;
polygon_lon_cntry = [min(lon_cntry) max(lon_cntry) max(lon_cntry) min(lon_cntry) min(lon_cntry)];
polygon_lat_cntry = [min(lat_cntry) min(lat_cntry) max(lat_cntry) max(lat_cntry) min(lat_cntry)];
inside=inpolygon(cordex_lon,cordex_lat,polygon_lon_cntry,polygon_lat_cntry);

i = find(inside);
[a,b] = ind2sub(size(lon_grid),i);
row_ind=a(end)-a(1)+1;
col_ind=b(end)-b(1)+1;
xlon = unique(cordex_lon(i));
xlat = unique(cordex_lat(i));
[mx,my] = meshgrid(xlon,xlat);

% ----------------------------
% get data for selected models and simulations
% ----------------------------
no_simulations=size(GCMs,1);
% ----------------
% loop over all simulations for all models
% ----------------
for i=1:no_simulations   
% ----------------
% historical
% ----------------
% Get the directory corresponding to an existing RCM --- added by
% Muralidhar

    hist_CORDEX_directory = ['/media/mad042/My Passport/Data/CORDEX/' deblank(hist_scenario) '/' deblank(cordex_var) '/' deblank(frequency) '/' deblank(hist_GCMs(i,:))  '/' deblank(hist_model_runs(i,:)) '/' deblank(hist_RCMs(i,:))  '/';];

    disp(hist_CORDEX_directory)
    
% read the data

    [hist_cordex_lat,hist_cordex_lon,hist_cordex_lat_grid,hist_cordex_lon_grid,hist_cordex_ser_time,hist_cordex_time_calendar,hist_cordex_time_check_flag,hist_cordex_data,hist_cordex_data_longname,hist_cordex_data_unit,hist_cordex_start_year,hist_cordex_end_year]...
        =read_CORDEX_2D_data(hist_CORDEX_directory,hist_scenario,cordex_var,frequency,GCMs,hist_start_year,hist_end_year,polygon_lon,polygon_lat);
                    
% extract seasonal data
    %[hist_ser_time_mean_first,hist_ser_time_mean_last,hist_ser_time_mean_middle,hist_data,season_indx]...
    %    =extract_seasons(hist_cordex_ser_time,hist_cordex_data,season,data_treshold,missing_option);      % hist_ser_time_mean_middle: middle of a season, ie., July for annual mean

% Caculate seasonal means
  [hist_ser_time_mean_first,hist_ser_time_mean_last,hist_ser_time_mean_middle,hist_data]...
        =calc_seasonal_means(hist_cordex_ser_time,hist_cordex_data,season,data_treshold,missing_option);      % hist_ser_time_mean_middle: middle of a season, ie., July for annual mean
 
  [hist_cordex_data_interp] = interpolate_nearest(hist_cordex_lat,hist_cordex_lon,hist_data,cordex_lat,cordex_lon);  
  
  hist_cordex_data_interp = reshape(hist_cordex_data_interp,[ydim xdim 30]);
  hist_cordex_data_interp_sub = hist_cordex_data_interp(unique(a),unique(b),:);  % The svalbard region
  
  hist_data_mean = nanmean(nanmean(hist_cordex_data_interp_sub,1),2);

  if (strcmp(cordex_var,'pr')) 
      hist_data_all(i,:)=hist_data_mean*86400;
  else
      hist_data_all(i,:)= hist_data_mean; 
  end
end

% hist_cordex_data_interp = reshape(hist_cordex_data_interp,[ydim xdim 30]);
% plot_data1 = hist_cordex_data_interp(unique(a),unique(b),:)*86400; 
% 
% plot_data2 = hist_cordex_data_interp(:,:,2)*86400;
%  
% m_proj('Lambert Conformal Conic','lon',[0 40],'lat',[75 83],'clon',20,'rec','off')
% figure(1);
% subplot(2,1,1); m_pcolor(mx,my,squeeze(plot_data1(:,:,2)));shading flat;m_grid(); m_coast; colorbar;
% subplot(2,1,2); m_pcolor(lon_grid,lat_grid,plot_data2);shading flat;m_grid(); m_coast; colorbar;
% 
%%              REFERENCE DATA PREPROCESSING

% We consider CRU as reference
if (strcmp(cordex_var,'pr')) 
    ref_path = '/media/mad042/My Passport/Data/CORDEX/USDelaware_terrestrial_temp_precip/'; 
    ref_time = '1900-01-01';

    pre = ncread([ref_path 'precip.mon.total.v401.nc'],'precip');
    tim = ncread([ref_path 'precip.mon.total.v401.nc'],'time');
    lon = ncread([ref_path 'precip.mon.total.v401.nc'],'lon');
    lat = ncread([ref_path 'precip.mon.total.v401.nc'],'lat');
    time = datenum(ref_time) + tim/24;
    
elseif (strcmp(cordex_var,'tas'))
    ref_path = '/media/mad042/My Passport/Data/CORDEX/USDelaware_terrestrial_temp_precip/'; 
    ref_time = '1900-01-01';

    pre = ncread([ref_path 'air.mon.mean.v401.nc'],'air');
    tim = ncread([ref_path 'air.mon.mean.v401.nc'],'time');
    lon = ncread([ref_path 'air.mon.mean.v401.nc'],'lon');
    lat = ncread([ref_path 'air.mon.mean.v401.nc'],'lat');
    time = datenum(ref_time) + tim/24;
end        
        
% Extracting years corresponding to the cordex models
years = [hist_start_year:hist_end_year];
id    = ismember(str2num(datestr(time,'yyyy')),years);
index = find(id);
obs_ser_time = time(index)';
obs_data = pre(:,:,index);

% Some re-arranging the data according to the function requirements
obs_data = reshape(obs_data, [size(obs_data,1)*size(obs_data,2) size(obs_data,3)]);
obs_data = permute(obs_data,[2 1]);
if (strcmp(cordex_var,'pr'))
    ndays   = eomday(str2num(datestr(obs_ser_time,'yyyy')),str2num(datestr(obs_ser_time,'mm')));
    obs_new = bsxfun(@rdivide,obs_data*10,ndays);  % converting to mmday-1
else
    obs_new = obs_data+273.15;
end    

clear a b mx my
[x,y] = meshgrid(lon,lat);

% Seasonal means (if you want to take seasonal values without averaging,
% ...use the 'season_index' vector, from the extract_seasons, on
% obs_ser_time field. You may want to do this for obtaining PDFs)
            
[ref_ser_time_mean_first,ref_ser_time_mean_last,ref_ser_time_mean_middle,ref_data]...
                =calc_seasonal_means(obs_ser_time,obs_new,season,data_treshold,missing_option);      % hist_ser_time_mean_middle: middle of a season, ie., July for annual mean
%[obs_data_interp] = interpolate_nearest(x(:),y(:),ref_data,cordex_lat,cordex_lon);

% Extract the lat/lon points covering Svalbard and average

inside=inpolygon(x(:),y(:),polygon_lon,polygon_lat);
i = find(inside); 
lon_new = unique(x(i));
lat_new = unique(y(i));
[a,b]=ind2sub(size(x),i);
row_ind=a(end)-a(1)+1;
col_ind=b(end)-b(1)+1;
i=reshape(i,[row_ind col_ind]);
mx=x(i); my=y(i);
ref_data = reshape(ref_data,[30 720 360]);
ref_data_svalbard = ref_data(:,unique(b),unique(a));
ref_data_svalbard_mean = nanmean(nanmean(ref_data_svalbard,2),3);

%% COMPUTE STD, COR and RMSE for the taylor plot
clear ref_std cordex_std cordex_rmse cordex_cor
ref_std    = nanstd(ref_data_svalbard_mean);

% Random sampling if there are any NaNs in the vectors
ref_copy = ref_data_svalbard_mean ;
tf = isnan(ref_data_svalbard_mean) ;
ref_copy(tf) = randsample(ref_data_svalbard_mean(~tf), sum(tf), true);
ref.data = ref_copy';
    
for i = 1:no_simulations
    dummy     = hist_data_all(i,:);
    hist_copy = dummy;
    tf = isnan(dummy);
    hist_copy(tf) = randsample(dummy(~tf), sum(tf), true);
    pred.data = hist_copy;
    
    taylor_stats(i) = taylor_statistics(pred,ref,'data');
%    cordex_std(i) = nanstd(hist_copy);
%    cordex_rmse(i) = rmse(hist_copy,ref_copy');
%    cordex_cor(i) = corr2(hist_copy,ref_copy');

end

sdev = [taylor_stats(1).sdev(1) taylor_stats(1).sdev(2) taylor_stats(2).sdev(2) taylor_stats(3).sdev(2) taylor_stats(4).sdev(2) taylor_stats(5).sdev(2) ...
        taylor_stats(6).sdev(2) taylor_stats(7).sdev(2) taylor_stats(8).sdev(2) taylor_stats(9).sdev(2)];
rmsd = [taylor_stats(1).crmsd(1) taylor_stats(1).crmsd(2) taylor_stats(2).crmsd(2) taylor_stats(3).crmsd(2) taylor_stats(4).crmsd(2) taylor_stats(5).crmsd(2) ...
        taylor_stats(6).crmsd(2) taylor_stats(7).crmsd(2) taylor_stats(8).crmsd(2) taylor_stats(9).crmsd(2)];
cor = [taylor_stats(1).ccoef(1) taylor_stats(1).ccoef(2) taylor_stats(2).ccoef(2) taylor_stats(3).ccoef(2) taylor_stats(4).ccoef(2) taylor_stats(5).ccoef(2) ...
        taylor_stats(6).ccoef(2) taylor_stats(7).ccoef(2) taylor_stats(8).ccoef(2) taylor_stats(9).ccoef(2)];

label = {'Reference', ...
   [deblank(hist_GCMs(1,:)) '/' deblank(hist_RCMs(1,:))], ...
   [deblank(hist_GCMs(2,:)) '/' deblank(hist_RCMs(2,:))], ...
   [deblank(hist_GCMs(3,:)) '/' deblank(hist_RCMs(3,:))], ...
   [deblank(hist_GCMs(4,:)) '/' deblank(hist_RCMs(4,:))], ...
   [deblank(hist_GCMs(5,:)) '/' deblank(hist_RCMs(5,:))], ...
   [deblank(hist_GCMs(6,:)) '/' deblank(hist_RCMs(6,:))], ...
   [deblank(hist_GCMs(7,:)) '/' deblank(hist_RCMs(7,:))], ...
   [deblank(hist_GCMs(8,:)) '/' deblank(hist_RCMs(8,:))], ...
   [deblank(hist_GCMs(9,:)) '/' deblank(hist_RCMs(9,:))], ...
  };

[hp, ht, axl] = taylor_diagram(sdev,rmsd,cor,...
     'styleOBS','-','markerObs','o','titleOBS','REF',... % Reference points
     'markerLabel',label, 'markerColor', 'r', 'markerLegend', 'on', ...
     'colRMS','g', 'styleRMS', ':', 'widthRMS', 2.0, 'titleRMS', 'off', ...
     'colSTD','b', 'styleSTD', '-.','widthSTD', 1.0 , ... ;%, 'titleSTD', 'off');
     'colCOR','k', 'styleCOR', '--', 'widthCOR', 1.0);
%     'tickRMS',0.0:0.1:.5,'tickRMSangle',140.0); %...

file = [deblank(cordex_var) '_' num2str(hist_start_year) '_' num2str(hist_end_year) '_months_' num2str(season(1)) 'to' num2str(season(end)) '.png']; 
print(gcf,'-dpng','-r900',file);

