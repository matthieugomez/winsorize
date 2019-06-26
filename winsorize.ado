program winsorize, byable(recall)
syntax varlist [if] [in] [aweight fweight] , ///
[Percentiles(string) missing replace GENerate(string) by(varname)]

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


marksample touse, novarlist
tempname qmin qmax

if "`by'"!=""{
    tempvar byvar
    tempname bylabel
    egen `byvar' = group(`by'), lname(`bylabel')
    tempname byvalmatrix
    qui tab `byvar' if `touse'== 1, nofreq matrow(`byvalmatrix')
    local bynum=r(r)
}
else local bynum 1


foreach i of numlist 1/`bynum'{
    if `bynum'>1{
        tempvar touseby
        gen `touseby' = `touse' == 1 & `byvar' ==  `=`byvalmatrix'[`i',1]'
        display in ye "`by' : `:label `bylabel' `i''"
    }
    else local touseby `touse'

    foreach v of varlist `varlist'{
        if "`pmin'`pmax'" != ""  { 
            if "`pmin'" == ""{
             _pctile `v' `wt' if `touseby', p(`pmax')
             scalar `qmax' = r(r1)
            }
            else if "`pmax'" == ""{
                _pctile `v' `wt' if `touseby', p(`pmin')
                scalar `qmin' = r(r1)
            }
            else{
                 _pctile `v' `wt' if `touseby', p(`pmin' `pmax')
                 scalar `qmin' = r(r1)
                 scalar `qmax' = r(r2)
            }
        }
        else{
            _pctile `v' `wt' if `touseby', percentiles(25 50 75)
            cap assert r(r3) > r(r1)
            if _rc{
                display as error "the interquartile of `v' is zero (p25 = p75 = `=r(r1)')"
                exit
            }
            scalar `qmin' = r(r2) - 5 * (r(r3) - r(r1)) 
            scalar `qmax' = r(r2) + 5 * (r(r3) - r(r1)) 
        }
        if "`qmin'" != "" & "`qmax'" != "" & "`qmin'" == "`qmax'" {
            display as error "qmin limit equals qmax"
            exit 4
        }
        if  "`percentiles'" == "" | "`pmin'" != ""{
            qui count if `v' < `qmin' & `v' != . & `touseby'
            display as text "Bottom cutoff :  `:display %12.0g `qmin'' (`=r(N)' observation changed)"
            if "`missing'" == ""{
                qui replace `v' = `qmin' if `v' < `qmin' & `v' != . & `touseby'
            }
            else{
                qui replace `v' = . if `v' < `qmin' & `touseby'
            }
        }
        if  "`percentiles'" == "" | "`pmax'" != ""{
            qui count if `v' > `qmax' & `v' != . & `touseby'
            display as text "Top cutoff :   `: display  %12.0g `qmax'' (`=r(N)' observation changed)"
            if "`missing'" == ""{
                qui replace `v' = `qmax' if `v' > `qmax' & `v' != . & `touseby'
            }
            else{
                qui replace `v'=. if `v' > `qmax' & `touseby'
            }
        }
    }
}
end
