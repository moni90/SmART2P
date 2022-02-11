function stars = convert_p_to_stars(p_val)

if p_val>=0.05
    stars = 'n.s';
elseif p_val >=0.01
    stars = '*';
elseif p_val >=0.001
    stars = '**';
else
    stars = '***';
end
    