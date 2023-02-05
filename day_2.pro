outcome(scissors, rock, loss).
outcome(rock, paper, loss).
outcome(paper, scissors, loss).
outcome(X, X, draw).
outcome(X, Y, win) :- outcome(Y, X, loss).

sign_weight(scissors, 3).
sign_weight(paper, 2).
sign_weight(rock, 1).

outcome_weight(win, 6).
outcome_weight(draw, 3).
outcome_weight(loss, 0).

round(X, Y, Z, S) :-
    outcome(X, Y, Z),
    sign_weight(X, SW),
    outcome_weight(Z, OW),
    S is SW + OW.

:- use_module(library(readutil)).

read_lines_from_file(F, Ls) :-
    open(F, read, FD),
    read_lines_from_stream(FD, Ls),
    close(FD).

read_lines_from_stream(X, Y) :- read_lines_from_stream(X, Y, []).

read_lines_from_stream(_, L, [end_of_file | L]) :- !.

read_lines_from_stream(FD, Ls, R) :-
    read_line_to_string(FD, L),
    read_lines_from_stream(FD, Ls, [L | R]).

convert_pair_terms(Ls, Ps) :- convert_pair_terms(Ls, Ps, []).

convert_pair_terms([], Ps, Ps).

convert_pair_terms([L | Ls], Ps, R) :-
    string_chars(L, [X, _, Y]),
    convert_pair_terms(Ls, Ps, [[X, Y] | R]).

decode_1('A', rock).
decode_1('B', paper).
decode_1('C', scissors).
decode_1('X', rock).
decode_1('Y', paper).
decode_1('Z', scissors).

decode_2('A', rock).
decode_2('B', paper).
decode_2('C', scissors).
decode_2('X', loss).
decode_2('Y', draw).
decode_2('Z', win).

game_1(F, S) :-
    read_lines_from_file(F, Ls),
    convert_pair_terms(Ls, Ps),
    game_1(_, S, Ps).

game_1(_, 0, []).

game_1(_, NS, [[X, Y] | Ps]) :-
    decode_1(X, Xs),
    decode_1(Y, Ys),
    round(Ys, Xs, _, RS),
    game_1(_, S, Ps),
    NS is S + RS.

game_2(F, S) :-
    read_lines_from_file(F, Ls),
    convert_pair_terms(Ls, Ps),
    game_2(_, S, Ps).

game_2(_, 0, []).

game_2(_, S, [[X, Y] | Ps]) :-
    decode_2(X, Xs),
    decode_2(Y, Ys),
    round(_, Xs, Ys, RS),
    game_2(_, NS, Ps),
    S is NS + RS.
