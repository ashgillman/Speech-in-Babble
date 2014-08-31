function src = apCallback(src, eventdata)
    callbackData = get(src,'UserData');
    backspaces = callbackData.backspaces;
    phones = callbackData.phones;
    startstops = callbackData.startstops;
    index = find(get(src,'CurrentSample')>startstops(:,1),1,'last');
    if isempty(index)
        index = numel(phones);
    end
    
    fprintf([backspaces phones{index} '\n']);
    callbadkData.backspaces = repmat('\b',1,numel(phones{index}));
    set(src,'UserData',callbackData);
end