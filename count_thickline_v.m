function count = count_thickline_v(canvas, width, x0, y0, x1, y1)
    count = 0;
    for dt=0:(width-1)
        ct = count_line(canvas, x0, y0+dt, x1, y1+dt);
        count = count + ct;
    end
end