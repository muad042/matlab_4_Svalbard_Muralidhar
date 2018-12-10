% ncid = netcdf.create('test.nc','NETCDF4');
% 
% dim_lon = netcdf.defDim(ncid,'lon',73);
% dim_lat = netcdf.defDim(ncid,'lat',12);
% dim_ens = netcdf.defDim(ncid,'ens',6);
% 
% lon = netcdf.defVar(ncid,'lon','double',dim_lon);
% lat = netcdf.defVar(ncid,'lat','double',dim_lat);
% ens = netcdf.defVar(ncid,'ens','double',dim_ens);
% 
% future_timemean = netcdf.defVar(ncid,'future_cordex_data_timemean','double',
% 
% 
% 
% 
clear

load tas_RCP45_months_12to2_2071_to_2100.mat

!rm test_files.nc 
nccreate('test_files.nc','future_timemean','Dimensions',{'y' 12 'x' 73 'ens' 6 });
nccreate('test_files.nc','lat','Dimensions',{'y' 12 'x' 73 });
nccreate('test_files.nc','lon','Dimensions',{'y' 12 'x' 73});
nccreate('test_files.nc','ens','Dimensions',{'ens' 6});
ncdisp('test_files.nc');

%lat_grid = permute(lat_grid, [1 2]);
%lon_grid = permute(lon_grid, [1 2]);
future_cordex_data_timemean = permute(future_cordex_data_timemean,[3 1 2]);

ncwrite('test_files.nc','lat',lat_grid);
ncwrite('test_files.nc','lon',lon_grid);
ncwrite('test_files.nc','future_timemean',future_cordex_data_timemean);

data = ncread('test_files.nc','future_timemean');