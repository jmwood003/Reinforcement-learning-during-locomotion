function Standard_error = SEM(array ,dim)
%Jonathan Wood
%8/25/19
%--------------------------------------------------------------------------
%General:
%This is a sub function which calculates standard error of the mean
%--------------------------------------------------------------------------
%Input:
%Array: any size array with one dimension as subjects and the other as data
%points
%dim: dimension desired for SEM. 
%If dim = 1, subjects are rows
%If dim = 2, subjecs are columns
%--------------------------------------------------------------------------
%Output: 
%Scalar output of the SEM. 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

if dim == 1 %Subjects are the rows
    [N,data] = size(array);
    Standard_error = [];
    for i = 1:data
        strd_dev = nanstd(array(:,i));
        current_SEM = strd_dev/sqrt(N);
        Standard_error = [Standard_error, current_SEM];
    end
elseif dim == 2 %Subjects are the columns
    [data,N] = size(array);
    Standard_error = [];
    for i = 1:data
        strd_dev = nanstd(array(i,:));
        current_SEM = strd_dev/sqrt(N);
        Standard_error = [Standard_error, current_SEM];
    end
else
    disp('Error dim must be either columns or rows')
end

end


