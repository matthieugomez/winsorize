program winsorize, sortpreserve
syntax varlist [if] [in] [aweight fweight], ///
[Percentiles(string) trim missing replace GENerate(string) by(varlist)]

* compatibility
if ("`missing'"!="") local `trim' trim


if ("`weight'"!="") local wt [`weight'`exp']

if "`generate'" == ""{
    if "`replace'" == ""{
        di as error "must specify either generate or replace option"
        exit 198
    }
}
else{
    if "`replace'" != ""{
        di as error "must specify either generate or replace option, not both"
    }
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
        if "`pmin'" == "." | "`pmin'" == "0" {
            local pmin  ""
        }
        if "`pmax'" == "." | "`pmax'" == "100" {
            local pmax ""
        }
    }
    else{
        di as error "The option p() must be of the form p(1 99)"
        exit 4
    }
}

foreach v of varlist `varlist'{
    confirm numeric variable `v'
}

tempname qmin qmax
marksample touse0, novarlist
foreach v of varlist `varlist'{
    tempvar touse
    gen `touse' = `touse0' & !missing(`v')

    tempvar bylength
    bys `touse' `by' : gen double `bylength' = _N 
    qui count if `touse'
    local samplesize=r(N)
    local touse_first=_N-`samplesize'+1
    local touse_last=_N
    tempvar qmin qmax
    qui gen `qmin' = .
    qui gen `qmax' = .
    local start = `touse_first'
    while `start' <= `touse_last'{
        local end = `start' + `=`bylength'[`start']' - 1
        if "`pmin'`pmax'" == ""  { 
            _pctile `v' `wt' in `start'/`end', percentiles(25 50 75)
            qui replace `qmin' = r(r2) - 5 * (r(r3) - r(r1)) in `start'/`end'
            qui replace `qmax' = r(r2) + 5 * (r(r3) - r(r1)) in `start'/`end'
        }
        else{
            if "`pmin'" == ""{
                _pctile `v' `wt' in `start'/`end', p(`pmax')
                qui replace `qmax' = r(r1) in `start'/`end'
            }
            else if "`pmax'" == ""{
                _pctile `v' `wt' in `start'/`end', p(`pmin')
                qui replace `qmin' = r(r1) in `start'/`end'
            }
            else{
                _pctile `v' `wt' in `start'/`end', p(`pmin' `pmax')
                qui replace `qmin' = r(r1) in `start'/`end'
                qui replace `qmax' = r(r2) in `start'/`end'
            }
        }
        local start = `end' + 1
    }
    if  "`percentiles'" == "" | "`pmin'" != ""{
        if "`trim'" == ""{
            replace `v' = `qmin' if `v' < `qmin' & !missing(`qmin')
        }
        else{
            replace `v' = . if `v' < `qmin' & !missing(`qmin')
        }
    }
    if  "`percentiles'" == "" | "`pmax'" != ""{
        if "`trim'" == ""{
            replace `v' = `qmax' if `v' > `qmax' & !missing(`qmax')
        }
        else{
            replace `v'= . if `v' > `qmax' & !missing(`qmax')
        }
    }
}
end
