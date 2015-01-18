function count = count_thickline_h(canvas, width, x0, y0, x1, y1)
    count = 0;
    for dt=0:(width-1)
        ct = count_line(canvas, x0+dt, y0, x1+dt, y1);
        count = count + ct;
    end
end