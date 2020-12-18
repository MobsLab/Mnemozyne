function [n1, n2, n3, rem, wake] = get_subscoring(substg, tdat)
    n1 = and(substg{1,1},tdat);
    n2 = and(substg{1,2},tdat);
    n3 = and(substg{1,3},tdat);
    rem = and(substg{1,4},tdat);
    wake = and(substg{1,5},tdat);
end