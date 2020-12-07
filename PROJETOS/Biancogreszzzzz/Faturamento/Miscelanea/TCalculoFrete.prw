#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TCalculoFrete
@author Tiago Rossini Coradini
@since 18/09/2019
@version 1.0
@description Classe Calculo de frete
@obs Ticket: 17739
@type class
/*/

Class TCalculoFrete From LongClassName
		
	Data cTpCalc
	Data nFrtCom
	Data cUFOri
	Data cMunOri
	Data cUFDes
	Data cMunDes
	Data cMarca
	Data cCategoria
	Data cProduto
	Data nPisEnt
	Data nCofEnt
	Data nIcmEnt
	Data nPisSai
	Data nCofSai
	Data nIcmSai
	Data nSeguro
	Data nComissao
	Data nDesAdm
	Data dDtIni
	Data dDtFin
	Data nFrtVen
	Data nFreBas
	
	Method New() Constructor
	Method SetProperty()
	Method Calc()

EndClass


Method New() Class TCalculoFrete

	::cTpCalc := "1"
	::nFrtCom := 0
	::cUFOri := ""
	::cMunOri := ""
	::cUFDes := ""
	::cMunDes := ""
	::cMarca := ""
	::cCategoria := ""
	::cProduto := ""
	::nPisEnt := 0
	::nCofEnt := 0
	::nIcmEnt := 0
	::nPisSai := 0
	::nCofSai := 0
	::nIcmSai := 0
	::nSeguro := 0
	::nComissao := 0
	::nDesAdm := 0
	::dDtIni := cToD("")
	::dDtFin := cToD("")
	::nFrtVen := 0
	::nFreBas := 0
				
Return()


Method SetProperty() Class TCalculoFrete

	::cTpCalc := M->ZKN_TPCALC
	::nFrtCom := M->ZKN_FRTCOM
	::cUFOri := M->ZKN_UFORI
	::cMunOri := M->ZKN_MUNORI
	::cUFDes := M->ZKN_UFDES
	::cMunDes := M->ZKN_MUNDES
	::cMarca := M->ZKN_MARCA
	::cCategoria := M->ZKN_CAT
	::cProduto := M->ZKN_PRODUT
	::nPisEnt := M->ZKN_PISENT
	::nCofEnt := M->ZKN_COFENT
	::nIcmEnt := M->ZKN_ICMENT
	::nPisSai := M->ZKN_PISSAI
	::nCofSai := M->ZKN_COFSAI
	::nIcmSai := M->ZKN_ICMSAI
	::nSeguro := M->ZKN_SEGURO
	::nComissao := M->ZKN_COMISS
	::nDesAdm := M->ZKN_DESADM
	::dDtIni := M->ZKN_DTINI
	::dDtFin := M->ZKN_DTFIN
	::nFreBas := ::nFrtCom
	::nFrtVen := 0

Return()


Method Calc() Class TCalculoFrete
	
	::SetProperty()
	
	::nFreBas -= (::nFreBas * ::nPisEnt) / 100
	
	::nFreBas -= (::nFreBas * ::nCofEnt) / 100
	
	::nFreBas -= (::nFreBas * ::nIcmEnt) / 100
	
	::nFreBas := ::nFreBas / (1 - (::nPisSai / 100))
	
	::nFreBas := ::nFreBas / (1 - (::nCofSai / 100))
	
	::nFreBas := ::nFreBas / (1 - (::nIcmSai / 100))
	
	::nFreBas := ::nFreBas / (1 - (::nComissao / 100))
	
	::nFreBas := ::nFreBas / (1 - (::nDesAdm / 100))	
	
	::nFrtVen := Round(::nFreBas, 2)
	
Return(::nFrtVen)