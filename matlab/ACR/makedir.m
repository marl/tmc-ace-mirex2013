function makedir(d)

if exist(d, 'dir') ~= 7 % if there is no dir
    mkdir(d);
end