function [match_a1, match_a2] = unique_matches(a1, a2)

min_idx = [];
for i = 1:length(a1)
    [min_val(i,1), min_idx(i,1)] = min(abs(a1(i) - a2));

    %If repeats find which one is smaller
    if sum(min_idx(i)==min_idx)>1
        repeat_idx = find(min_idx==min_idx(i));
        [~,larger] = max(min_val(repeat_idx));
        min_idx(repeat_idx(larger)) = nan;
    end
end

match_a1 = find(isnan(min_idx)==0);
match_a2 = min_idx;
match_a2(isnan(match_a2)==1) = [];

end