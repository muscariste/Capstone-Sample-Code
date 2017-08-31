sys = 'delay_blocks';
load_system(sys);
if ~bdIsLoaded(sys)
    new_system(sys);
end
open_system(sys);
Simulink.BlockDiagram.deleteContents(sys)

% if false, the default case is the first constant in the delay vector
SetDefaultToZero = false;

%% Add input, multiport switch
pos = repmat([0 0], 1, 2) + [0 0 30 20];
add_block('built-in/Inport',[sys '/select'],'Position',pos);

pos = repmat([190 9*45-10], 1, 2) + [0 0 30 10];
add_block('built-in/Outport',[sys '/out'],'Position',pos);
pos = repmat([60 0], 1, 2) + [0 0 100 18*45];
add_block('built-in/MultiPortSwitch',[sys '/mps'],'Position',pos,...
                                                  'DataPortOrder','Zero-based contiguous',...
                                                  'inputs','16',...
                                                  'DataPortForDefault','Additional Data Port',...
                                                  'SampleTime', '-1',...
                                                  'SaturateOnIntegerOverflow','off',...
                                                  'OutDataTypeStr','Inherit: Inherit via back propagation',...
                                                  'DiagnosticForDefault','None');
add_line(sys,'select/1','mps/1','autorouting','on');
add_line(sys,'mps/1','out/1','autorouting','on');

%% Add delay options
ds = linspace(0,90,16);

for l = 1:length(ds)
pos = repmat([0 l*45], 1, 2) + [0 0 30 30];                                              
add_block('built-in/Constant',[sys ['/d' int2str(l)]],'Position',pos,'SampleTime', '-1',...
                                                  'Value',int2str(ds(l)),...
                                                  'OutDataTypeStr','uint16');
add_line(sys,['d' int2str(l) '/1'],['mps/' int2str(l+1)],'autorouting','on');

if l==1 && ~SetDefaultToZero;
    add_line(sys,['d' int2str(l) '/1'],['mps/' int2str(18)],'autorouting','on');
end %if

end %for

if SetDefaultToZero
    pos = repmat([0 (l+1)*45], 1, 2) + [0 0 30 30];
    add_block('built-in/Constant',[sys ['/d' int2str(0)]],'Position',pos,'SampleTime', '-1',...
                                                  'Value',int2str(ds(l)),...
                                                  'OutDataTypeStr','uint16');
    add_line(sys,'d0/1','mps/18','autorouting','on');   
end