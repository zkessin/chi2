-module(chi2_tests).
-include_lib("eunit/include/eunit.hrl").

get_sv(1)->
  [{60, 300},
   {10, 390}].

get_total_test()->
  ?assertEqual(chi2:get_total(get_sv(1)), 760).

get_degrees_of_freedom_test() ->
  ?assertEqual(chi2:get_degrees_of_freedom(get_sv(1)), 1).

get_row_total_test() ->
  ?assertEqual(chi2:get_row_total({70, 360}), 70+360).

get_colum_total_test() ->
  ?assertEqual(chi2:get_column_total(1, get_sv(1)), 70),
  ?assertEqual(chi2:get_column_total(2, get_sv(1)), 690).

get_ex_cell_value_test() ->
  V  = get_sv(1),
  E  = [{33.1578947368421,326.8421052631579},
        {36.8421052631579,363.1578947368421}],
  E2 = chi2:get_ex_cell_values(V),
  ?assertEqual(E, E2).


compute_cell_test() ->
    ?assertEqual( 21.724535585042226 , chi2:compute_cell(60,33.16)).

get_chi2_sum_test() ->
  V    = get_sv(1),
  E    = chi2:get_ex_cell_values(V),
  Chi2 = chi2:get_chi2_sum(V, E),
  ?assertEqual(88.30726614106119 , Chi2).
