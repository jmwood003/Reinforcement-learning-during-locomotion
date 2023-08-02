function [ Binned_array ] = Bin( Array,BinSize,dim,fun )
%Jonathan Wood
%8/25/19
%--------------------------------------------------------------------------
%General:
%This is a sub function which bins an array
%--------------------------------------------------------------------------
%Input:
%Array: any size array. Does not have to be a single dimension because the
%dimension will be specified

%nBins: the number of steps in a Bin

%dim: dimension desired to compress the data into bins. 
%If dim = 1, the function will bin columns
%If dim = 2, the function will bin rows

%fun: function desired. Input is in the form of a string.
%Currently this function only does mean or standard deviation. 
%Example: 'mean' or 'std'
%--------------------------------------------------------------------------
%Output: 
%an array with the same dimensions as the input array but compressed by
%nbins
%--------------------------------------------------------------------------
%This function is called in several scripts
%--------------------------------------------------------------------------

Binned_array = [];
[row, col] = size(Array);

if dim == 1
    subjs = row;
    data = col;
elseif dim == 2
    subjs = col;
    data = row;
end

if strcmp(fun,'mean')==1
    
    start_idx = 1;  
    end_idx = BinSize;
    single_binned_array = [];   
    %Loop through the vector
    for i = 1:(round(data/BinSize))
        if end_idx > length(Array)
           current_idx = start_idx:length(Array);
        else
            current_idx = start_idx:end_idx;
        end
        bins = nanmean(Array(current_idx));
        single_binned_array = [single_binned_array, bins];
        start_idx = start_idx + BinSize; 
        end_idx = end_idx + BinSize;

    end
    Binned_array = [Binned_array; single_binned_array];

elseif strcmp(fun,'std')==1
  
    start_idx = 1; 
    end_idx = BinSize;
    single_binned_array = [];  
    %Loop through the vector
    for i = 1:(round(data/BinSize))
        if end_idx > length(Array)
           current_idx = start_idx:length(Array);
        else
           current_idx = start_idx:end_idx;
        end
        bins = nanstd(Array(current_idx));
        single_binned_array = [single_binned_array, bins];
        start_idx = start_idx + BinSize; 
        end_idx = end_idx + BinSize;

    end
    Binned_array = [Binned_array; single_binned_array];

elseif strcmp(fun,'sum')==1

    start_idx = 1; 
    end_idx = BinSize;
    single_binned_array = [];   
    %Loop through the vector
    for i = 1:(round(data/BinSize))
        if end_idx > length(Array)
           current_idx = start_idx:length(Array);
        else
            current_idx = start_idx:end_idx;
        end
        bins = nansum(Array(current_idx));
        single_binned_array = [single_binned_array, bins];
        start_idx = start_idx + BinSize; 
        end_idx = end_idx + BinSize;

    end
    Binned_array = [Binned_array; single_binned_array];

else
    disp('Fun must be a string and must be either mean or std. No other funtions are accpeted at this time')
end
    

end

