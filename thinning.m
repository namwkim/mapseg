function result = thinning(bw)
    result = bwmorph(~bw, 'thin', inf);
    result = ~result;
end