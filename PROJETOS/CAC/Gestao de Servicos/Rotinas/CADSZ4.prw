#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH" 

User Function CADSZ4()
  
IF FUNNAME() == "TECA040"
	_cProd := AA3->AA3_CODPRO
	SZ4->(DBSetFilter({|| SZ4->Z4_PRODUTO == _cProd}, 'SZ4->Z4_PRODUTO == _cProd'))
ENDIF

AxCadastro("SZ4", "Manutenções Preventivas") 

SZ4->(DBClearFilter())


RETURN