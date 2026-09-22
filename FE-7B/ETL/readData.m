function [strikes, calls, puts] = readData(callPath, putPath, snapRow)
% This function reads the options data from all of the provided files.
% Here we do not remove any data, even if the option was not traded and
% therefore its price is nan. Such considerations will be done in the
% following functions if necessary. Option's data is indexed by value date,
% we select it using the snapRow parameter.
% snapRow = 84 -> 2020-04-29
% snapRow = 108 -> 2020-06-02
% INPUTS:
% callPath -> string, path to the directory of the call files
% putPuth  -> string, path to the directory of the put files
% snapRow  -> integer, row index to look at


callFiles = dir(fullfile(callPath,"*.csv"));
putFiles = dir(fullfile(putPath,"*.csv"));

% We were provided a total of 9 files. However, the first one refers to
% options with expiry on May 14th, hence are not to be included in our
% work. The quick & dirty solution is to drop the corresponding file.

callFiles = callFiles(2:end); putFiles = putFiles(2:end);

% In total, we need to manage 8x314 calls/puts. Remember most of these were
% not actually traded
strikes = zeros(1,314);
calls = zeros(8, 314);
puts = zeros(8, 314);

for k=1:length(callFiles)
    filePathCall = fullfile(callFiles(k).folder, callFiles(k).name);
    T = readtable(filePathCall);

    %Coping the files data
    strikes(:) = T{1,2:end};
    calls(k,:) = T{snapRow,2:end};

    filePathPut = fullfile(putFiles(k).folder, putFiles(k).name);
    T = readtable(filePathPut);
    puts(k,:) = T{snapRow,2:end};
end

end