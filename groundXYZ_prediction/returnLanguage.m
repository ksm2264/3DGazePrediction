function [string_out] = returnLanguage(b_idx,markerNum)

load('bodyfullstack.mat','markerNames');


if b_idx<=markerNum*3
    
    [coord marker] = ind2sub([3 markerNum],b_idx);
    
    
    switch coord
        case 1
            out_str = 'X';
        case 2
            out_str = 'Y';
        case 3
            out_str = 'Z';
    end
    
    string_out = [markerNames{marker} '-' out_str];
    
elseif b_idx>markerNum*3&&b_idx<=markerNum*3+4
    switch b_idx
        case markerNum*3+1
            string_out = 'gait percent';
        case markerNum*3+2
            string_out = 'COM velocity X';
        case markerNum*3+3
            string_out = 'COM velocity Y';
        case markerNum*3+4
            string_out = 'COM velocity Z';
    end
else
    b_idx_mod = b_idx - markerNum*3-4;
    [coord marker] = ind2sub([3 markerNum],b_idx_mod);
    
    
    switch coord
        case 1
            out_str = 'X';
        case 2
            out_str = 'Y';
        case 3
            out_str = 'Z';
    end
    
    string_out = ['vel_' markerNames{marker} '-' out_str];
end
    disp(string_out);

end