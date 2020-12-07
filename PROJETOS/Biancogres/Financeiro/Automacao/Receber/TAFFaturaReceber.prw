#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFFaturaReceber
@author Tiago Rossini Coradini
@since 02/10/2018
@project Automação Financeira
@version 1.0
@description Classe para criacao de faturas/liquidacao a receber
@type class
/*/

#DEFINE _pPrefixo 2
#DEFINE _pValidate 10


Class TAFFaturaReceber From LongClassName

	Data dEmissao // Data de emissao
	Data aFatura // Array de faturas
	Data cNumero // Numero da Fatura

	Method New() Constructor
	Method Create()
	Method Validate(nLine)
	Method GetNext()

EndClass


Method New() Class TAFFaturaReceber 

	::dEmissao := dDataBase
	::aFatura := {}
	::cNumero := ""

Return()


Method Create() Class TAFFaturaReceber
Local nX := 1
Local nY := 0
Local lExist := .T.

	::aFatura	:= U_fGeraFatura(::dEmissao, ::dEmissao)

	While Len(::aFatura[nX]) <> 0
	
		For nY := 1 To Len(::aFatura[nX])
		
			If ::Validate(::aFatura[nX][nY][_pValidate])
			
				::cNumero := ::GetNext()
				
			EndIf
		
		Next
		
		nLine++
		
	EndDo()
		
Return()


Method Validate(cPar) Class TAFFaturaReceber
Local lRet := .F.
	
	lRet := Upper(AllTrim(cPar)) == "SIM" 

Return(lRet)


Method GetNext() Class TAFFaturaReceber
Local cRet := ""
Local lExist := .T.

	While lExist
	
		cRet := Soma1(GetMV("MV_NUMFAT"), 9)
				 
		cSql := "SELECT COUNT(*) QUANT FROM "+RetSqlName("SE1")+" WHERE E1_PREFIXO = '"+aFatura[n][1][2]+"' AND E1_NUM = '"+wNumFat+"' AND E1_TIPO = 'FT' AND D_E_L_E_T_ = '' 
		IF CHKFILE("_RAC")
			DBSELECTAREA("_RAC")
			DBCLOSEAREA()
		ENDIF
		
		TCQUERY cSql ALIAS "_RAC" NEW
		
		If _RAC->QUANT > 0
		
			lVer := .T. 
			PutMV("MV_NUMFAT",wNumFat)
						
			Else
				lVer := .F.
			EndIf
			
	EndDo()

Return(cRet)