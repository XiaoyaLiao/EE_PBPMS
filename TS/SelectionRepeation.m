function isRepeated = SelectionRepeation(SelectedJobs,Jobs)

isRepeated = 0;
for ii=1:numel(SelectedJobs)
    if isempty(setdiff(SelectedJobs{ii},Jobs)) 
        isRepeated = 1;
        break
    end
end

