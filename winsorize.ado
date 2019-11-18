program winsorize, byable(recall)
syntax varlist [if] [in] [aweight fweight] , ///
[Percentiles(string) missing replace GENerate(string) by(varlist)]

if ("`weight'"!="") local wt [`weight'`exp']

if "`generate'" == ""{
    if "`replace'" == ""{
        di as error "must specify either generate or replace option"
        exit 198
    }
}
else{
    local ct1: word count `varlist'
    local ct2: word count `generate'
    if `ct1' != `ct2' {
        di as err "number of variables in varlist must equal" 
        di as err "number of variables in generate(newvarlist)"
        exit 198
    }
    else{
        forvalues i = 1/`ct1'{
            gen `:word `i' of `generate'' =  `:word `i' of `varlist''
        }
        local varlist `generate'
    }
}

if "`percentiles'" != ""{
    local ct: word count `percentiles'
    if `ct' == 2{
        local pmin `: word 1 of `percentiles''
        local pmax `: word 2 of `percentiles''
        if "`pmin'" == "."{
            local pmin  ""
        }
        if "`pmax'" == "."{
            local pmax ""
        }
    }
    else{
        di as error "The option p() must be of the form p(1 99), p(. 99), p(1 .)"
        exit 4
    }
} 


tempname qmin qmax

marksample touse
qui count if `touse'
local samplesize=r(N)
local touse_first=_N-`samplesize'+1
local touse_last=_N

tempvar bylength
local type = cond(c(N)>c(maxlong), "double", "long")
bys `touse' `by' : gen `type' `bylength' = _N 

local start = `touse_first'
while `start' <= `touse_last'{
    local end = `start' + `=`bylength'[`start']' - 1
    foreach v of varlist `varlist'{
        if "`pmin'`pmax'" != ""  { 
            if "`pmin'" == ""{
                _pctile `v' `wt' in `start'/`end', p(`pmax')
                scalar `qmax' = r(r1)
            }
            else if "`pmax'" == ""{
                _pctile `v' `wt' in `start'/`end', p(`pmin')
                scalar `qmin' = r(r1)
            }
            else{
                _pctile `v' `wt' in `start'/`end', p(`pmin' `pmax')
                scalar `qmin' = r(r1)
                scalar `qmax' = r(r2)
            }
        }
        else{
            _pctile `v' `wt' in `start'/`end', percentiles(25 50 75)
            scalar `qmin' = r(r2) - 5 * (r(r3) - r(r1)) 
            scalar `qmax' = r(r2) + 5 * (r(r3) - r(r1)) 
        }
        if "`by'" == ""{
            if "`qmin'" != "" & "`qmax'" != "" & "`qmin'" == "`qmax'" {
                display as error "qmin limit equals qmax"
                exit 4
            }
        }
        if  "`percentiles'" == "" | "`pmin'" != ""{
            if "`by'" == ""{
                qui count if `v' < `qmin' & `v' != .
                display as text "Bottom cutoff :  `:display %12.0g `qmin'' (`=r(N)' observation changed)"
            }
            if "`missing'" == ""{
                qui replace `v' = `qmin' in `start'/`end' if `v' < `qmin'
            }
            else{
                qui replace `v' = . in `start'/`end' if `v' < `qmin'
            }
        }
        if  "`percentiles'" == "" | "`pmax'" != ""{
            if "`by'" == ""{
                qui count if `v' > `qmax' & `v' != . 
                display as text "Top cutoff :   `: display  %12.0g `qmax'' (`=r(N)' observation changed)"
            }
            if "`missing'" == ""{
                qui replace `v' = `qmax' in `start'/`end' if `v' > `qmax'
            }
            else{
                qui replace `v'=. in `start'/`end' if `v' > `qmax'
            }
        }
    }
    local start = `end' + 1
}
end
