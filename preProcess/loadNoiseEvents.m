function noisePeriods = loadNoiseEvents(rez)

eventFile = rez.ops.noiseEventFile;
noiseTable = readtable(eventFile,'filetype','text');

if width(noiseTable) == 3
    noiseTable.Properties.VariableNames = {'Samples', 'Channels', 'State'};
    noiseTable.Samples = noiseTable.Samples * (rez.ops.fs / 1000); % converts ms to samples
    count = 0;
    for tableRow = 1:height(noiseTable)
        switch noiseTable.State{tableRow}
            case '-'
                count = count + 1;
                startSample(count) = noiseTable.Samples(tableRow);
                channels = strsplit(noiseTable.Channels{tableRow},'-');
                startChannel(count) = str2num(channels{1});
                endChannel(count) = str2num(channels{2});

                if strcmp(noiseTable.State{tableRow+1},'-')
                    error('Consecutive channel removal events, blanking poinst must be terminated');
                end
            case '+'
                endSample(count) = noiseTable.Samples(tableRow);
                channels = strsplit(noiseTable.Channels{tableRow},'-');
                startChannel(count) = str2num(channels{1});
                endChannel(count) = str2num(channels{2});
        end
    end         
elseif width(noiseTable) == 2
    noiseTable.Properties.VariableNames = {'Samples', 'Channels'};
    noiseTable.Samples = noiseTable.Samples * (rez.ops.fs / 1000); % converts ms to samples
    count = 0;
    for tableRow = 1:height(noiseTable)
        temp = strsplit(noiseTable.Channels{tableRow},' ');
        channels = strsplit(temp{1},'-');
        state = temp{2};
        switch state
            case '-'
                count = count + 1;
                startSample(count) = noiseTable.Samples(tableRow);
                startChannel(count) = str2num(channels{1});
                endChannel(count) = str2num(channels{2});
            case '+'
                endSample(count) = noiseTable.Samples(tableRow);
                startChannel(count) = str2num(channels{1});
                endChannel(count) = str2num(channels{2});
        end
    end         
end
    
% Check for some possible errors
if startSample(1) > endSample(1)
    error('Problem with the first start time to blank')
end

% Assign to struct

noisePeriods.startSample = startSample;
noisePeriods.endSample = endSample;
noisePeriods.startChannel = startChannel;
noisePeriods.endChannel = endChannel;



