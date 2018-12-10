% PURPOSE
% plot smoothed timeseries with median, 10 and 90 precentiles for models + observation data  
% on the right side, boxplots are made for two scenarios
clear
%% load observations
OBS=xlsread('/Home/siv5/sma087/Steffi/UNI_Klima/KSS/KiN2100/DATA/OBS/Norge_obs_precip_anom.xlsx','Sheet1');
%% 10 years smoothing
% obs_data=OBS(:,7);

%% 30 years smoothing
% obs_data=OBS(:,8); % 8 År; %%10 vinter; 12 vår; 14 sommer; 16 høst;%%
% precip
obs_data=OBS(:,2);
cd /Home/siv5/sma087/Steffi/UNI_Klima/KSS/KiN2100/scripts/
h=9;n=115;obs_years=1900:2014;
obs_data=ksr(obs_years,obs_data,h,n);
obs_years=OBS(:,1);

%% loading EUR-11 data
%% 1.) load hist data
inputDir1 ='/Home/siv5/sma087/Steffi/UNI_Klima/KSS/DATA/EUR-11/NORWAY/';
cd(inputDir1)
RCP45=load('PR_HISTORICAL_RCP45_1971_2100_ANN_KERNEL_SMOOTHED_h9.mat');
RCP85=load('PR_HISTORICAL_RCP85_1971_2100_ANN_KERNEL_SMOOTHED_h9.mat');

cd /Home/siv5/sma087/Steffi/UNI_Klima/KSS/KiN2100/scripts/

%% end of century 2071-2100
xaxes_limits=[1900 2100];xaxes_stp=20;
yaxes_limits=[-15 30];yaxes_stp=5;
% colors
rcp_cols=[0.6 0.6 1;1 0.4 0.4];

% x and y axis ticks
x_axis_ticks=xaxes_limits(1):xaxes_stp:xaxes_limits(2);
y_axis_ticks=yaxes_limits(1):yaxes_stp:yaxes_limits(2);

% add data to x-limits to make space for box plots
xaxes_limits(2)=xaxes_limits(2)+20;
end_cent_yr=xaxes_limits(2)-10;

fnt=14;
fntname='Arial';

figure(1)
clf
set(gca,'XAxisLocation','bottom','YAxisLocation','left','FontName',fntname,'Fontsize',fnt,'FontWeight','normal');
hold on

% zero line
hz=plot([xaxes_limits(1) xaxes_limits(end)] ,[0 0],'k--');
set(hz,'Linewidth',1,'Color','k'); 
mod_years=1971:2100;

%%%%%%%%%%%%%%
% rcp45
%%%%%%%%%%%%%%
% 10 and 90 precentile
rcp45L=RCP45.ts_anom_norwayL;
rcp45H=RCP45.ts_anom_norwayH;
% median
rcp45M=RCP45.ts_anom_norwayM;
h1_2=patch([mod_years, fliplr(mod_years)],[rcp45L, fliplr(rcp45H)],'g');
set(h1_2,'EdgeColor','k','FaceColor',rcp_cols(1,:),'EdgeColor',rcp_cols(1,:),'EdgeAlpha',0.4,'FaceAlpha',0.4);
h1=plot(mod_years,rcp45M');
set(h1,'Linewidth',3,'Color',rcp_cols(1,:))
% 
% values in Table 5.2.1, KiN2100
% RCP45MM=2.7;
% RCP45LL=1.6;
% RCP45HH=3.7;

% values in Table 5.2.3, KiN2100
RCP45MM=8;
RCP45LL=3;
RCP45HH=14;

h1_3=patch([end_cent_yr-2 end_cent_yr+2 end_cent_yr+2 end_cent_yr-2 end_cent_yr-2],[RCP45LL RCP45LL RCP45HH RCP45HH RCP45LL],'g');
set(h1_3,'EdgeColor','k','FaceColor',rcp_cols(1,:),'EdgeColor',rcp_cols(1,:),'EdgeAlpha',1,'FaceAlpha',1);
h1_4=plot([end_cent_yr-2.5 end_cent_yr+2.5],[RCP45MM RCP45MM],'k');
set(h1_4,'Color','k','Linewidth',3);

%%%%%%%%%%%%%%
% rcp85
%%%%%%%%%%%%%%
% 10 and 90 precentile
rcp85L=RCP85.ts_anom_norwayL;
rcp85H=RCP85.ts_anom_norwayH;
% median
rcp85M=RCP85.ts_anom_norwayM;
h2_2=patch([mod_years, fliplr(mod_years)],[rcp85L, fliplr(rcp85H)],'g');
set(h2_2,'EdgeColor','k','FaceColor',rcp_cols(2,:),'EdgeColor',rcp_cols(2,:),'EdgeAlpha',0.4,'FaceAlpha',0.4);
h2=plot(mod_years,rcp85M);
set(h2,'Linewidth',3,'Color',rcp_cols(2,:))

% values in Table 5.2.1, KiN2100
% RCP85MM=4.5;
% RCP85LL=3.4;
% RCP85HH=6.0;

% values in Table 5.2.3, KiN2100
RCP85MM=18;
RCP85LL=7;
RCP85HH=23;

end_cent_yr=end_cent_yr+5;
h2_3=patch([end_cent_yr-2 end_cent_yr+2 end_cent_yr+2 end_cent_yr-2 end_cent_yr-2],[RCP85LL RCP85LL RCP85HH RCP85HH RCP85LL],'g');
set(h2_3,'EdgeColor','k','FaceColor',rcp_cols(2,:),'EdgeColor',rcp_cols(2,:),'EdgeAlpha',1,'FaceAlpha',1);
 
h2_4=plot([end_cent_yr-2.5 end_cent_yr+2.5],[RCP85MM RCP85MM],'k');
set(h2_4,'Color','k','Linewidth',3);

%%%%%%%%%%
% OBS
%%%%%%%%%%          
% smooth version of OBS
% h3=plot(obs_years,obs_data);
% precip
h3=plot(obs_years,obs_data.f);
set(h3,'Linewidth',3,'Color','k');

axis([xaxes_limits(1) xaxes_limits(end) yaxes_limits(1) yaxes_limits(end)]);
% yaxes_label='^oC';
% precip
yaxes_label='%';
xaxes_label=' '; 
legend_text=['observations'; ...
             'RCP4.5      '; ...
             'RCP8.5      '];

output_name='OBS_FUTURE_PRECIP_NORWAY_TIMESERIES_H9';
% y-label
h=ylabel(yaxes_label);
set(h,'Fontsize',fnt,'Fontname',fntname,'FontWeight','bold');

% x-label
h=xlabel(xaxes_label);
set(h,'Fontsize',fnt,'Fontname',fntname,'FontWeight','bold');

set(gca,'YTick',y_axis_ticks,'XTick',x_axis_ticks);
set(gca,'YColor',[0 0 0],'XColor',[0 0 0],'Linewidth',2)

h_leg=legend([h3,h1_3,h2_3],legend_text(1,:),legend_text(2,:),legend_text(3,:),'Location','NorthWest');
set(h_leg,'Box','off','EdgeColor',[0.999 0.999 0.999],'Fontsize',fnt,'Fontname',fntname,'FontWeight','normal');

eval(['print -dpng ' output_name '.png -r600'])
eval(['print -djpeg ' output_name '.jpg -r600'])



