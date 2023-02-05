:- set_prolog_flag(verbose, silent).
:- initialization(main).

connected_heights(A, A).
connected_heights(A, B) :-
    A =:= B + 1;
    A =:= B - 1.
connected_heights(A, B) :-
    char_code('S', A),
    char_code('a', AChCode),
    connected_heights(AChCode, B).
connected_heights(A, B) :-
    char_code('E', B),
    char_code('z', BChCode),
    connected_heights(A, BChCode).
connected_heights(B, A) :-
    char_code('S', A),
    char_code('a', AChCode),
    connected_heights(AChCode, B).
connected_heights(B, A) :-
    char_code('E', B),
    char_code('z', BChCode),
    connected_heights(A, BChCode).


move( 1, 0).
move(-1, 0).
move(0,  1).
move(0, -1).

nth0_2d(ColIdx, RowIdx, Matrix, Val) :-
    nth0(RowIdx, Matrix, Row),
    nth0(ColIdx, Row, Val).

:- dynamic visited/1.

is_char(Ch, point(X, Y), Heights) :-
    char_code(Ch, ChCode),
    nth0_2d(X, Y, Heights, ChCode).

%% step(A, _, Heights, _) :-
%%     end_point(A, Heights).

step(point(X, Y), point(Xnew, Ynew), Heights, Visited) :-
    move(XMove, YMove),
    Xnew is X - XMove,
    Ynew is Y - YMove,
    \+ member(point(Xnew, Ynew), Visited),
    Xnew >= 0,
    Ynew >= 0,
    length(Heights, MaxY),
    Ynew < MaxY,

    nth0_2d(Xnew, Ynew, Heights, Hnew),
    nth0(Ynew, Heights, Row),
    length(Row, MaxX),
    Xnew < MaxX,

    nth0_2d(X, Y, Heights, H),

    connected_heights(H, Hnew).

path_start(Heights, StartPoint, EndPoint, ResultSteps) :-
    path(Heights, [StartPoint], EndPoint, ResultSteps).

path(_, [EndPoint | Steps], EndPoint, [EndPoint | Steps]). % comparing EndPoint

path(Heights, [Point | Steps], EndPoint, ResultSteps) :-
    solution(MinSteps),
    length(Steps, StepsCount),
    MinSteps > StepsCount,
    %% writeln(StepsCount),
    step(Point, PointNew, Heights, Steps),
    %% write(Point),
    %% write("->"),
    %% writeln(PointNew),
    %% (PointNew = EndPoint; step(PointNew, _, Heights, [Point, Steps])),

    path(Heights, [PointNew, Point | Steps], EndPoint, ResultSteps).

:- use_module(library(readutil)).
:- use_module(library(apply)).

read_lines_from_file(File, Lines) :-
    open(File, read, FileDescriptor),
    read_lines_from_stream(FileDescriptor, Lines),
    close(FileDescriptor).

read_lines_from_stream(FileDescriptor, Lines) :-
    read_lines_from_stream(FileDescriptor, Lines, []).

read_lines_from_stream(_, Lines, [end_of_file | Lines]) :- !.

read_lines_from_stream(FileDescriptor, Lines, RestLines) :-
    read_line_to_string(FileDescriptor, Line),
    read_lines_from_stream(FileDescriptor, Lines, [Line | RestLines]).

:- dynamic(solution/1).

findminlength(Heights, StartPoint, EndPoint, MinStepsCount) :-
    \+ solution(_),
    path_start(Heights, StartPoint, EndPoint, Result),
    length(Result, StepsCount),
    assertz(solution(StepsCount)), !,
    findminlength(Heights, StartPoint, EndPoint, MinStepsCount).

findminlength(Heights, StartPoint, EndPoint, _) :-
    path_start(Heights, StartPoint, EndPoint, Result),
    length(Result, StepsCount),
    solution(OldStepsCount),    StepsCount < OldStepsCount,
    retract(solution(OldStepsCount)),
    asserta(solution(StepsCount)),
    writeln(StepsCount),
    fail.

findminlength(_, _, _, MinStepsCount) :-
    solution(MinStepsCount), retract(solution(MinStepsCount)).

reverse([],Z,Z).

reverse([H|T],Z,Acc) :- reverse(T,Z,[H|Acc]).

dataset(File, CharCodeLists) :-
    read_lines_from_file(File, Lines),
    maplist(string_chars, Lines, CharLists),
    maplist(maplist(char_code), CharLists, CharCodeListsRev),
    reverse(CharCodeListsRev, CharCodeLists, []),!.

start(CharCodeLists, StepsCount, StartPoint, EndPoint) :-
    assertz(solution(9999999)),
    findminlength(CharCodeLists, StartPoint, EndPoint, StepsCountP1),
    StepsCount is StepsCountP1 - 1.

test_ds(DS) :- dataset("day_12-test", DS).
real_ds(DS) :- dataset("day-12", DS).

main :-
    dataset("day-12", DS),
    is_char('S', StartPoint, DS),
    is_char('E', EndPoint, DS), !,
    %% start(DS, A, StartPoint, EndPoint),
    start(DS, A, point(46,20), point(46,21)),
    writeln(A).

%% main :- halt.

%% test_ds(DS),path_start(DS,point(5,2),point(0,4),X).
%% test_ds(DS),start(DS,X,point(5,2),point(0,4)).
%% real_ds(DS),start(DS,X,point(0,20),point(46,20)).
%% real_ds(DS),start(DS,X,point(46,20),point(36,20)).
%% test_ds(DS),step(point(5,2),X,DS,[]).
