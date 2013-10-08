-module(chi2).

-include_lib("eunit/include/eunit.hrl").
-export([get_total/1]).

-compile(export_all).

-type(chi2_row()    ::{integer(), integer()}).
-type(chi2_vector() ::[chi2_row()]).
-export_type([chi2_row/0, chi2_vector/0]).

-spec(chi95(chi2_vector()) -> boolean()).
chi95(V) -> 
  corilation(V, 0.95).


-spec(chi99(chi2_vector()) -> boolean()).
chi99(V) -> 
  corilation(V, 0.99).

-spec(corilation(chi2_vector(), number()) -> boolean()).
corilation(V, Threadhold) ->
  case chi2(V) of
    corrilation_lt_threashhold  -> false;
    Corr when Corr < Threadhold -> false;
    _ -> true
  end.


-spec(chi2(chi2_vector()) -> number()|corrilation_lt_threashhold).
chi2(V) ->
  case get_total(V) of 
    0 -> 0;
    _ ->
        DOF    = get_degrees_of_freedom(V),
        ExVals = get_ex_cell_values(V),
        Sum    = get_chi2_sum(V, ExVals),
        table(DOF, Sum)
    end.

-spec(get_total(chi2_vector()) -> number()).
get_total(Vector) ->
  lists:sum([F+S|| {F,S} <- Vector]).


-spec(get_row_total(chi2_row()) -> integer()).
get_row_total({F,S}) ->
  F + S.

-spec(get_degrees_of_freedom(chi2_vector()) -> integer()).
get_degrees_of_freedom(V)->
  length(V) -1.


get_column_total(1,V) ->
  lists:sum([F || {F,_S} <-V]);
  
get_column_total(2,V) ->
  lists:sum([S || {_F,S} <-V]).


get_ex_cell_values(V) ->
  Total = get_total(V),
  TF = get_column_total(1, V),
  TS = get_column_total(2, V),
  CellTotal = fun(RowTotal, ColTotal) ->
    (RowTotal * ColTotal)/ Total
  end,
  lists:map(fun(Row) ->
          RowTotal = get_row_total(Row),
          {CellTotal(RowTotal, TF),
           CellTotal(RowTotal, TS)}
      end, V).


-spec(square(number()) -> number()).
square(E) -> E*E.


compute_cell(O,E) ->
  square(O - E) / E.


compute_row({Fo, Fs},{Eo, Es}) ->
  compute_cell(Fo, Eo) + 
    compute_cell(Fs, Es).

get_chi2_sum(0, _) -> 0;
get_chi2_sum(V, E) ->
  Combined = lists:zipwith(fun compute_row/2, E,V),
  lists:sum(Combined).


-spec(table(1|2, number) -> number() | corrilation_lt_threashhold).
table(1, Sum) when Sum > 7.879  -> 0.995;
table(1, Sum) when Sum > 6.635  -> 0.990;
table(1, Sum) when Sum > 5.024  -> 0.990;
table(1, Sum) when Sum > 3.841  -> 0.950;
table(1, Sum) when Sum > 2.706  -> 0.900;
table(2, Sum) when Sum > 10.597 -> 0.995;
table(2, Sum) when Sum > 9.210  -> 0.990;
table(2, Sum) when Sum > 7.378  -> 0.975;
table(2, Sum) when Sum > 5.991  -> 0.950;
table(2, Sum) when Sum > 4.605  -> 0.900;
table(_,_) -> corrilation_lt_threashhold.

