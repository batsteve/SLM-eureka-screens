function [ outcode ] = saveFarField( options, data )
%SAVEPADDEDSCREENS Summary of this function goes here
%   Detailed explanation goes here

    fprintf('Saving far field.\n');

    filename = sprintf('%s%s_far_field_real_%d.ring', options.paddedScreenPath, options.filePrefix, data.n);
    file = fopen(filename, 'w', 'n');
    fwrite(file, real(data.farFieldFromPadded), 'double');
    fclose(file);
    
    filename = sprintf('%s%s_far_field_imag_%d.ring', options.paddedScreenPath, options.filePrefix, data.n);
    file = fopen(filename, 'w', 'n');
    fwrite(file, imag(data.farFieldFromPadded), 'double');
    fclose(file);
    
    outcode = 1;


end

