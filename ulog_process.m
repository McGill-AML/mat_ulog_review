clear all; close all;

% -------------------------------------------------------------------------
% 1. Specify the log file without extension (.ulg)
% 2. Name a savefile (.mat)
% 3. Specify the uORB topics to be imported, separate each topic with a comma
% 4. Specify the messages to be imported, separate each group of messages
%    under one topic with a colon, separate each individual message within 
%    one topic with a space. Specify 'all' to include all messages within
%    the topic
% 
% WARNING: Do not add whitespaces unnecessarily
% WARNING2: For each topic imported, include at least one message
% -------------------------------------------------------------------------

log_name = '17_33_08';     
mat_file= '1.mat';
log_folder = 'log5_csv';
log_topics = 'aerobatics_variables,aerobatics_variables2,aerobatics_variables3,vehicle_attitude,vehicle_attitude_setpoint,vehicle_local_position,vehicle_gps_position';
log_msgs = {
'all',...
'all',...
'all',...
'all',...
'all',...
'all',...
'all',
};

% -------------------------------------------------------------------------
if exist(log_folder, 'dir') == 0
    mkdir(log_folder);
end 
addpath(log_folder);

system(['ulog2csv -m ', log_topics ,' -o ',log_folder,' ',log_name,'.ulg']);

log_topics = strsplit(log_topics,',');
topic = cell(1,length(log_topics));
if length(log_topics) ~= length(log_msgs)
    error('Assign one message to be imported for every topic!');
end

%% Import data from csv into matlab
for li = 1:length(log_topics)
    topic(li) = cellstr([log_name,'_', char(log_topics(li)),'_0.csv']);
    msg = strsplit(char(log_msgs(li)), ',');
    
    if msg == "all"
        log_all = csvimport(char(topic(li)));
        headers = log_all(1,:);
        log_all(1,:) = [];
        
        log.([char(log_topics(li)),'_timestamp']) = csvimport(char(topic(li)), 'columns', 'timestamp');
        for lk = 2:length(headers)
            field = setfield(char(headers(lk)), log_topics(li));
            log.(field) = cell2mat(log_all(:,lk));
        end
        
    else
                
        log.([char(log_topics(li)),'_timestamp']) = csvimport(char(topic(li)), 'columns', 'timestamp');
        for lj = 1:length(msg)
            field = setfield(char(msg(lj)), log_topics(li));
            log.(field) = csvimport(char(topic(li)) , 'columns', msg(lj));
        end
    end
end

%% Clear temporary variables and plot
save(mat_file);
data_process
%standard_graphs
AML_graphs
clear li lj msg field verbose lk log_all headers

function field = setfield(field, topic)
    field = erase(field, ["[","]"]);
    if field == "x" || field == "y" || field == "z" || field == "r" || field == "thrust"
        field = erase([char(topic),'_',field],["sensor_","vehicle_"]);
    end
end