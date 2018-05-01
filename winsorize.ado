program winsorize, byable(recall)
syntax varlist [if] [in] [aweight fweight] [, ///
GENerate(string) replace drop by(varname) bottom(string) top(string)]

if ("`weight'"!="") local wt [`weight'`exp']

if "`gen'" == ""{
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




marksample touse
tempname max min cutbottom cuttop cuttop2 cutbottom2
if "`by'"~=""{
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
        qui sum `v'  if `touseby'
        scalar `max' = r(max)
        scalar `min' = r(min)
        if "`bottom'`top'" ~= "" { 
            if "`bottom'" == ""{
               _pctile `v' `wt' if `touseby', p(`top')
               scalar `cuttop' = r(r1)
           }
           else if "`top'" == ""{
            _pctile `v' `wt' if `touseby', p(`bottom')
            scalar `cutbottom' = r(r1)
        }
        else{
            _pctile `v' `wt' if `touseby', p(`bottom' `top')
            scalar `cutbottom' = r(r1)
            scalar `cuttop' = r(r2)
        }
        }
        else{
            _pctile `v' `wt' if `touseby', percentiles(25 50 75)
            cap assert r(r3) > r(r1)
            if _rc{
                display as error "the interquartile of `v' is zero (p25 = p75  = `=r(r1)')"
                exit
            }
            scalar `cutbottom' = r(r2) - 5*(r(r3)-r(r1)) 
            scalar `cuttop' = r(r2) + 5*(r(r3)-r(r1)) 
        }

        if "`cutbottom'" != "" & "`cuttop'" != "" & "`cutbottom'" == "`cuttop'" {
            display as error "bottom limit equals the top limit"
            exit 4
        }


    if "`bottom'" ~= ""{
        qui count if `v' < `cutbottom' & `v' ~= . & `touseby'
        local nbottom `=r(N)'
        local cutbottom2 :  display %12.0g `=`cutbottom''
        display as text "Bottom cutoff :  `cutbottom2' (`nbottom' observation changed)"
        if "`drop'"==""{
            qui replace `v' = `cutbottom' if `v' < `cutbottom' & `v' ~= . & `touseby'
        }
        else if "`drop'" ~= ""{
            qui replace `v' = . if `v' < `cutbottom' & `touseby'
        }
    }

    if "`top'" ~= ""{
        qui count if `v' > `cuttop' & `v' ~= . & `touseby'
        local ntop `=r(N)'
        local cuttop2 : display  %12.0g `=`cuttop''
        display as text "Top cutoff :  `cuttop2' (`ntop' observation changed)"

        if "`drop'"==""{
            qui replace `v' = `cuttop' if `v' > `cuttop' & `v' ~= . & `touseby'
        }
        else if "`drop'" ~= ""{
            qui replace `v'=. if `v' > `cuttop' & `touseby'
        }
    }
}
}
end
