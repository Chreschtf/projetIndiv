set CLIENTS;
set FEEDERS;
set LINKS within (CLIENTS union FEEDERS) cross (CLIENTS union FEEDERS);
param max_distance>0;
set L {FEEDERS,1..max_distance};
set P {FEEDERS,CLIENTS};
set NEIGHBOURS {CLIENTS union FEEDERS};
set N {FEEDERS};		#set of clients which may be allocated to feeder j
param demand {CLIENTS}>0;
param power {FEEDERS}>0;
param pow := sum{j in FEEDERS} power[j];
param hopcost {LINKS}>=0;
check:
	sum {i in CLIENTS} demand[i]<= pow;

var Min>=0;
var allocated {FEEDERS,CLIENTS} binary ;

set CC {FEEDERS} default {};	#set of clients in N[j] forming a connected component with j
set O {FEEDERS} default {};		#set of clients in N[j] not forming a connected component with j
set CS {FEEDERS} default {};	#set of clients surrounding the connected component CC[j] not allocated to j
set C {FEEDERS,CLIENTS} default {};		#set of connected components in O
set C_FIRST_CLIENTS {FEEDERS} default {};	#clients needed to identify the different sets of connected components in C
param C_MIN_DISTANCE_CLIENT {FEEDERS,CLIENTS} symbolic;		#clients closest to their feeder of the connected components in C
set CS_RELEVANT_FOR_CC{FEEDERS,CLIENTS} default {};
set F {FEEDERS} default {};
set CS_RELEVANT_FOR_CLIENT_IN_F{FEEDERS,CLIENTS} default {};
set CONNECTIVITY_CUTS_FEEDERS default {};
set DISTANCE_CUTS_FEEDERS default {};
maximize Obj:
	#pow-allocated[j,i]*demand[i];
	#pow-sum{i in CLIENTS}allocated[j,i]*demand[i];
	Min;
    
subject to Margin_over_feeders{j in FEEDERS}:
    pow-sum{i in CLIENTS}allocated[j,i]*demand[i]>=Min;

subject to layer_eq{j in FEEDERS,lam in 1..(max_distance-1),i in L[j,lam+1]}:#, s in P[j,i]}:
    allocated[j,i]<=sum{k in P[j,i]}allocated[j,k];

subject to one_feeder_per_client {i in CLIENTS}:
    sum{j in FEEDERS}allocated[j,i]=1;

subject to zero_if_not_in_N {j in FEEDERS, i in (CLIENTS diff N[j])}:
	allocated[j,i]=0;
#subject to demand_for_power_sufficiency {j in FEEDERS}:
#	power[j]-sum{i in CLIENTS}allocated[j,i]*demand[i]>=0;
	
subject to eq24{j in CONNECTIVITY_CUTS_FEEDERS}:
	sum{i in O[j]}allocated[j,i]<=card(O[j])*sum{k in CS[j]}allocated[j,k];
	
subject to eq25{j in CONNECTIVITY_CUTS_FEEDERS,v in C_FIRST_CLIENTS[j]}:#, i_cc in }:
	allocated[j,C_MIN_DISTANCE_CLIENT[j,v]]<=sum{k in CS_RELEVANT_FOR_CC[j,v]}allocated[j,k];

subject to eq26{j in DISTANCE_CUTS_FEEDERS,i in F[j]}:
	allocated[j,i]<=sum{k in CS_RELEVANT_FOR_CLIENT_IN_F[j,i]}allocated[j,k];

end;