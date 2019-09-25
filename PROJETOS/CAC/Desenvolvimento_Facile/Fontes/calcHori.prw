#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH" 

User Function calcHori(dDtProj, dDtHor, nHorasDia, nDiasSeman, nHorimetro)

Local nDias := dDtProj - dDtHor
Local nMediaHor := (nHorasDia*nDiasSeman)/7
Local nTotHoras := nHorimetro + (nDias*nMediaHor)

Return nTotHoras