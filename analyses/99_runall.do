markstat using "C:\external\SCORE_Fielding-Miller_covid_R3pV\analyses\02_data-preparation-extended", strict keep(do)

markstat using "C:\external\SCORE_Fielding-Miller_covid_R3pV\analyses\03_analysys-5perc-sample-extended", strict keep(do)

markstat using "C:\external\SCORE_Fielding-Miller_covid_R3pV\analyses\04_data-preparation-original", strict keep(do)

markstat using "C:\external\SCORE_Fielding-Miller_covid_R3pV\analyses\05_analysys-5perc-sample-original", strict keep(do)

cd "C:\external\SCORE_Fielding-Miller_covid_R3pV\analyses"

markdoc "C:\external\SCORE_Fielding-Miller_covid_R3pV\analyses\06_analysys-final-report.do", mini export(pdf) replace style("simple")

! COPY "C:\external\SCORE_Fielding-Miller_covid_R3pV\analyses\06_analysys-final-report.pdf" "C:\external\SCORE_Fielding-Miller_covid_R3pV\SCORE Report - Fielding-Miller_covid_R3pV - Cheng Panczak - Data Analytic Replication - 615k.pdf" 






