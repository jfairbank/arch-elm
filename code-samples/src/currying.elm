add x y z = x + y + z

add 1 2 3     -- 6
((add 1) 2) 3 -- 6

add1 = add 1
add3 = add1 2

add1 2 3  -- 6
add3 3    -- 6
