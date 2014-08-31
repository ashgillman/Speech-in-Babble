for num = 1:10
    numberRecs{num} = audiorecorder();
    fprintf('recording number %i in 3',num);
    pause(0.5);
    fprintf('\b2');
    pause(0.5);
    fprintf('\b1');
    pause(0.5);
    fprintf('\b\nRecording...\n');
    recordblocking(numberRecs{num},1)
end