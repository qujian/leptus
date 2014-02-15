%% This file is part of leptus, and released under the MIT license.
%% See LICENSE for more information.

-module(leptus_router_SUITE).

-export([all/0]).
-export([paths/1]).
-export([sort_dispatch/1]).

-record(ctx, {handler, route, handler_state}).


all() ->
    [paths, sort_dispatch].

paths(_) ->
    Ctx1 = #ctx{handler=leptus_routes1, route="/", handler_state=[]},
    Ctx2 = #ctx{handler=leptus_routes1, route="/blah", handler_state=[]},
    Ctx3 = #ctx{handler=leptus_routes1, route="/hello/:name", handler_state=[]},
    Ctx4 = #ctx{handler=leptus_routes1, route="/some-url/to/some-path",
                handler_state=[]},
    Ctx5 = #ctx{handler=leptus_routes2, route="/something/:key",
                handler_state=aha},
    Ctx6 = #ctx{handler=leptus_routes2, route="/something/else",
                handler_state=aha},
    Ctx7 = #ctx{handler=leptus_routes3, route="/users/:id",
                handler_state=i_see},
    Ctx8 = #ctx{handler=leptus_routes3, route="/users/:id/info",
                handler_state=i_see},
    [{'_', [
            {"/", leptus_handler, Ctx1},
            {"/blah", leptus_handler, Ctx2},
            {"/hello/:name", leptus_handler, Ctx3},
            {"/some-url/to/some-path", leptus_handler, Ctx4},
            {"/something/:key", leptus_handler, Ctx5},
            {"/something/else", leptus_handler, Ctx6},
            {"/users/:id", leptus_handler, Ctx7},
            {"/users/:id/info", leptus_handler, Ctx8}
           ]
     }]= leptus_router:paths([{'_', [{leptus_routes1, []},
                                     {leptus_routes2, aha},
                                     {leptus_routes3, i_see}]}]).

sort_dispatch(_) ->
    Routes = [
              {"/:bucket", handler, undefined},
              {"/_version", handler, undefined},
              {"/:bucket/:key", handler, undefined},
              {"/:bucket/_keys", handler, undefined},
              {"/_buckets", handler, undefined},
              {"/", handler, undefined}
             ],
    Dispatch = cowboy_router:compile([{'_', Routes}]),
    [
     {'_',[],
      [{[],[],handler,undefined},
       {[<<"_version">>],[],handler,undefined},
       {[<<"_buckets">>],[],handler,undefined},
       {[bucket],[],handler,undefined},
       {[bucket,<<"_keys">>],[],handler,undefined},
       {[bucket,key],[],handler,undefined}]}
    ] = leptus_router:sort_dispatch(Dispatch),

    Routes1 = [{"/:a/:b", handler, undefined},
               {"/:a/:b/x/:d", handler, undefined},
               {"/:a", handler, undefined},
               {"/:a/:b/:c", handler, undefined},
               {"/", handler, undefined},
               {"/:a/:b/x", handler, undefined},
               {"/:a/x/:c/:d", handler, undefined},
               {"/:a/x", handler, undefined}],
    Dispatch1 = cowboy_router:compile([{'_', Routes1}]),
    [{'_', [],
      [
       {[], [], handler, undefined},
       {[a], [], handler, undefined},
       {[a, <<"x">>], [], handler, undefined},
       {[a, b],[], handler, undefined},
       {[a, b, <<"x">>], [], handler, undefined},
       {[a, b, c], [], handler, undefined},
       {[a, b, <<"x">>, d], [], handler, undefined},
       {[a, <<"x">>, c, d], [], handler, undefined}
      ]}] = leptus_router:sort_dispatch(Dispatch1).
