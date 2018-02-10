folder = uigetdir();
if ~isequal(folder,0)
    figureList = findall(0,'type','figure');
    for i = 1:length(figureList)
        savefig(figureList(i),[folder settings.sep num2str(figureList(i).Number) '_' strrep(figureList(i).Name,' ','_') '.fig']);
    end
end

clear folder figureList i