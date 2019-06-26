{smcl}
{* *! version 1.2.1  07mar2013}{...}
{title:Title}
{bf:winsorize} {hline 2} winsorize based on 5 times interquartiles



{marker syntax}{...}
{title:Syntax}
{cmd:winsorize} {varlist} {ifin} {cmd:,[} {opt  replace|generate(string) missing Percentiles(string)
by(varlist)}{cmd:]}



{marker description}{...}
{title:Description}
{pstd}
{cmd:winsorize} winsorizes  each variable in {it:varlist} based on 5 times the interquartile range. With the option gen, creates a new variable and leaves the original untouched (otherwise use the option replace). With the option {opt missing}, these observations are replaced by missing values. 

