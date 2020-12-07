#INCLUDE "PROTHEUS.CH"
#INCLUDE "BIA688.CH"
#INCLUDE "report.ch"
#INCLUDE "FIVEWIN.CH"

/*/{Protheus.doc} BIA688
@author Marcos Alberto Soprani
@since 11/08/16
@version 1.0
@description Mapa de Vale Transporte - EspecÌfico GBI. Originado do Fonte GPER009 - TOTVS - disponibilizado em 03/08/16. Data do Fonte 06/11/15
@obs OS: 2536-16  - JÈssica
@type function
/*/

User Function BIA688(nTpVale)

	Local oReport   
	Local aArea 	:= GetArea()

	Private cCodVale	 := ""
	Private cTitulo		 := ""
	Private cDesVale  	 := ""
	Private nValUnitario := 0
	Private nValTot 	 := nValeDif := 0
	Private nQtdeVale  	 := nValUnAn := nValUnAt := 0
	Private nCustFun 	 := nCustEmp := nTotCust := 0
	Private nValor6		 := nValor7	 := 0
	Private cAliasQry	 := "SRA"    
	Private cPerg		 :=""   
	Private aCargFil	 := FwLoadSm0()

	If fChkUpdate() 
		Aviso( STR0040, STR0051, { STR0045 } ) //"Atencao"##"Antes de prosseguir, È necess·rio executar os procedimentos do boletim tecnico - Alteracao Grupo de Perguntas na Impressao do Mapa (Beneficios). "##"Ok"
		Return( Nil )	
	EndIf

	If nTpVale == 0
		pergunte("GPER009VT",.F.)  
		cPerg 	:= "GPER009VT"
	Else
		pergunte("GPER009VL",.F.)
		cPerg	:= "GPER009VL"
	EndIf

	oReport := ReportDef()
	oReport:PrintDialog()

	RestArea( aArea )

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ ReportDef  ≥ Autor ≥ Equipe da Folha       ≥ Data ≥24/01/2013≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Mapa de BenefÌcios                                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ GPER009                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPER009                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function ReportDef()

	Local oReport 
	Local oSection1 
	Local oSection2        
	Local cDesc1 := ""	

	Private aOrd    := {}	

	aOrd     := {OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008)}	
	//"Matricula","C.Custo","Nome","C.Custo + Nome","C.Custo + Turno + Nome"

	If nTpVale == 0 //Vale Trasporte
		cDesc1	:= OemToAnsi(STR0001) + " " + OemToAnsi(STR0002) + " " + OemToAnsi(STR0003)  
		//Mapa Vale Transporte ser· impresso de acordo com os parametros solicitados pelo usu·rio.
		cTitulo	:= OemToAnsi(STR0011) 	//"Mapa Vale Transporte    

		DEFINE REPORT oReport NAME "GPER009" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| GR009Imp(oReport,(cAliasQry)->RA_FILIAL)} DESCRIPTION OemToAnsi(STR0037) + OemToAnsi(STR0038)	
		//"Esta rotina gera um mapa que resume as informacoes de Vale transporte por "
		// "funcionarios permitindo que o desconto seja gerado para a folha de pagamento."

		DEFINE SECTION oSRA OF oReport TITLE OemToAnsi(STR0039) ORDERS aOrd TABLES "SRA" TOTAL IN COLUMN TOTAL TEXT STR0037

		DEFINE CELL NAME "RA_FILIAL"  	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_FILIAL}
		DEFINE CELL NAME "RA_TNOTRAB" 	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_TNOTRAB}
		DEFINE CELL NAME "RA_CC"	  	    OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_CC}
		DEFINE CELL NAME "RA_MAT"	  	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_MAT}
		DEFINE CELL NAME "RA_NOME"	  	OF oSRA ALIAS "SRA"	BLOCK {|| (cAliasQry)->RA_NOME}
		oSRA:SetHeaderBreak(.T.)

		DEFINE SECTION oRG2 OF oReport  TITLE OemToAnsi(STR0036) ORDERS aOrd TABLES "RG2","SRN" TOTAL IN COLUMN TOTAL TEXT STR0037 

		DEFINE CELL NAME "VALE"	        OF oRG2 TITLE STR0035 BLOCK {|| cCodVale	+ " - " + cDesVale	} ALIGN LEFT 
		DEFINE CELL NAME "NQTDEVALE"		OF oRG2 TITLE STR0026 BLOCK {|| nQtdeVale   }                                    
		DEFINE CELL NAME "BARRA"	        OF oRG2 BLOCK {||"/"} 
		DEFINE CELL NAME "NVALEDIF"		OF oRG2 TITLE STR0033 BLOCK {|| nValeDif }      PICTURE "999" 				
		DEFINE CELL NAME "NVALUNITARIO"	OF oRG2 TITLE STR0027 BLOCK {|| nValUnitario } 	PICTURE "@E 999,999.99"
		DEFINE CELL NAME "NVALTOT"		OF oRG2 TITLE STR0028 BLOCK {|| nValTot	}		PICTURE "@E 999,999.99"
		DEFINE CELL NAME "NCUSTFUN"		OF oRG2 TITLE STR0029 BLOCK {|| nValor6	} 		PICTURE "@E 999,999.99"
		DEFINE CELL NAME "NCUSTEMP"		OF oRG2 TITLE STR0030 BLOCK {|| nValor7	} 		PICTURE "@E 999,999.99"

		// Coluna de Total de Beneficiario SEM titulo. Apenas para gerar os totais.
		DEFINE CELL NAME "BENEFIC"		OF oRG2 TITLE OemToAnsi( "" )	  PICTURE "9999" 				//"TOTAL DE BENEFICIARIO"

		TRPosition():New(oRG2,"SRN",1,{|| RhFilial("SRN",SR0->R0_FILIAL)+SR0->R0_MEIO},.T.)

		DEFINE COLLECTION OF oRG2 FUNCTION COUNT FORMULA {|| oRG2:Cell("VALE"):GetValue(.T.) + " - " + oRG2:Cell("RN_DESC"):GetValue(.T.)} CONTENT oRG2:Cell("VALE") 		TITLE OemToAnsi(STR0038) PICTURE "999"		NO END SECTION						//"TOT. LINHAS"

		// Total de Beneficiario do TOTAL LINHAS com titulo alterado para manter alinhamento
		DEFINE COLLECTION OF oRG2 FUNCTION SUM   FORMULA oRG2:Cell(cCodVale) CONTENT oRG2:Cell("NQTDEVALE")	 	TITLE OemToAnsi(STR0031) PICTURE "999999"	  				NO END SECTION						//"QUANTIDADE"
		DEFINE COLLECTION OF oRG2 FUNCTION SUM   FORMULA oRG2:Cell(cCodVale) CONTENT oRG2:Cell("NVALEDIF")		TITLE OemToAnsi(STR0033) PICTURE "9999" 					NO END SECTION WHEN {||nMapDif ==2}	//"QT.DIF."
		DEFINE COLLECTION OF oRG2 FUNCTION SUM   FORMULA oRG2:Cell(cCodVale) CONTENT oRG2:Cell("NVALUNITARIO")	TITLE OemToAnsi(STR0027) PICTURE "@R 999,999.99"			NO END SECTION						//"TOTAL UNIT."
		DEFINE COLLECTION OF oRG2 FUNCTION SUM   FORMULA oRG2:Cell(cCodVale) CONTENT oRG2:Cell("NVALTOT")		TITLE OemToAnsi(STR0028) PICTURE "@R 999,999.99"			NO END SECTION						//"VALOT TOTAL"
		DEFINE COLLECTION OF oRG2 FUNCTION SUM   FORMULA oRG2:Cell(cCodVale) CONTENT oRG2:Cell("NCUSTFUN")		TITLE OemToAnsi(STR0029) PICTURE "@R 999,999.99"   			NO END SECTION						//"CUSTO FUNC."
		DEFINE COLLECTION OF oRG2 FUNCTION SUM   FORMULA oRG2:Cell(cCodVale) CONTENT oRG2:Cell("NCUSTEMP")		TITLE OemToAnsi(STR0030) PICTURE "@R 999,999.99"   			NO END SECTION						//"CUSTO EMPR."

		// O Total de Beneficiario do TOTAL GERAL eh impresso com o titulo completo
		DEFINE FUNCTION NAME "QTVALES"     FROM oRG2:Cell("NQTDEVALE")		OF oRG2 		FUNCTION SUM	TITLE OemToAnsi(STR0031) PICTURE "999999"			NO END SECTION							//"QUANTIDADE"
		DEFINE FUNCTION NAME "QTVLDIF"     FROM oRG2:Cell("NVALEDIF")		OF oRG2 		FUNCTION SUM    TITLE OemToAnsi(STR0033) PICTURE "9999"				NO END SECTION	 WHEN {||nMapDif ==2}	//"QT.DIF."
		DEFINE FUNCTION NAME "TOTUNIT"     FROM oRG2:Cell("NVALUNITARIO") 	OF oRG2 		FUNCTION SUM	TITLE OemToAnsi(STR0027) PICTURE "@R 999,999.99"	NO END SECTION 							//"TOTAL UNIT."
		DEFINE FUNCTION NAME "TOTGERAL"    FROM oRG2:Cell("NVALTOT")	     	OF oRG2 		FUNCTION SUM	TITLE OemToAnsi(STR0028) PICTURE "@R 999,999.99"	NO END SECTION							//"VALOT TOTAL"
		DEFINE FUNCTION NAME "TOTCUSTOFUN" FROM oRG2:Cell("NCUSTFUN")		OF oRG2 		FUNCTION SUM	TITLE OemToAnsi(STR0029) PICTURE "@R 999,999.99"	NO END SECTION							//"TOT. CUSTO FUNC."
		DEFINE FUNCTION NAME "TOTCUSTOEMP" FROM oRG2:Cell("NCUSTEMP")		OF oRG2 		FUNCTION SUM	TITLE OemToAnsi(STR0030) PICTURE "@R 999,999.99"	NO END SECTION							//"TOT. CUSTO EMPR."

		oRG2:Cell("BARRA"   ):Disable()
		oRG2:Cell("NVALEDIF"):Disable()

		oRG2:SetHeaderBreak(.T.)

	ElseIf nTpVale == 1 
		cDesc1	:= OemToAnsi(STR0017) + " " + OemToAnsi(STR0002) + " " + OemToAnsi(STR0003)
		//Mapa Vale RefeiÁ„o ser· impresso de acordo com os parametros solicitados pelo usu·rio.
		cTitulo	:= OemToAnsi(STR0009)//Vale Refeicao			

		//Criacao dos componentes de impressao                                     
		DEFINE REPORT oReport NAME "GPER009" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| GR009Imp(oReport,(cAliasQry)->RA_FILIAL)} DESCRIPTION OemToAnsi(STR0012) + OemToAnsi(STR0038)	
		//"Esta rotina gera um mapa que resume as informacoes de Vale refeiÁ„o por "
		// "funcionarios permitindo que o desconto seja gerado para a folha de pagamento."

		DEFINE SECTION oSRA OF oReport TITLE OemToAnsi(STR0039) ORDERS aOrd TABLES "SRA" TOTAL IN COLUMN TOTAL TEXT STR0012

		DEFINE CELL NAME "RA_FILIAL"  	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_FILIAL}
		DEFINE CELL NAME "RA_TNOTRAB" 	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_TNOTRAB}
		DEFINE CELL NAME "RA_CC"	  	    OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_CC}
		DEFINE CELL NAME "RA_MAT"	  	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_MAT}
		DEFINE CELL NAME "RA_NOME"	  	OF oSRA ALIAS "SRA"	BLOCK {|| (cAliasQry)->RA_NOME}
		oSRA:SetHeaderBreak(.T.)

		DEFINE SECTION oRG2 OF oReport  TITLE OemToAnsi(STR0036) ORDERS aOrd TABLES "RG2" TOTAL IN COLUMN TOTAL TEXT STR0012 

		DEFINE CELL NAME "VALE"	        OF oRG2 TITLE STR0035 BLOCK {|| cCodVale	+ " - " + cDesVale	} ALIGN LEFT 
		DEFINE CELL NAME "NQTDEVALE"		OF oRG2 TITLE STR0026 BLOCK {|| nQtdeVale   } 
		DEFINE CELL NAME "NVALUNITARIO"	OF oRG2 TITLE STR0027 BLOCK {|| nValUnitario } 	PICTURE "@E 999,999.99"
		DEFINE CELL NAME "NVALTOT"		OF oRG2 TITLE STR0028 BLOCK {|| nValTot	}		PICTURE "@E 999,999.99"
		DEFINE CELL NAME "NCUSTFUN"		OF oRG2 TITLE STR0029 BLOCK {|| nValor6	} 		PICTURE "@E 999,999.99"
		DEFINE CELL NAME "NCUSTEMP"		OF oRG2 TITLE STR0030 BLOCK {|| nValor7	} 		PICTURE "@E 999,999.99"
		oRG2:SetHeaderBreak(.T.)

	Else 
		cDesc1	:= OemToAnsi(STR0018) + " " + OemToAnsi(STR0002) + " " + OemToAnsi(STR0003)
		//Mapa Vale AlimentaÁ„o ser· impresso de acordo com os parametros solicitados pelo usu·rio.
		cTitulo	:= OemToAnsi(STR0010) //Vale Alimentacao			

		//Criacao dos componentes de impressao                                     
		DEFINE REPORT oReport NAME "GPER009" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| GR009Imp(oReport,(cAliasQry)->RA_FILIAL)} DESCRIPTION OemToAnsi(STR0016) + OemToAnsi(STR0038)	
		//"Esta rotina gera um mapa que resume as informacoes de Vale alimentaÁ„o por "
		// "funcionarios permitindo que o desconto seja gerado para a folha de pagamento."

		DEFINE SECTION oSRA OF oReport TITLE OemToAnsi(STR0039) ORDERS aOrd TABLES "SRA" TOTAL IN COLUMN TOTAL TEXT STR0016

		DEFINE CELL NAME "RA_FILIAL"  	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_FILIAL}
		DEFINE CELL NAME "RA_TNOTRAB" 	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_TNOTRAB}
		DEFINE CELL NAME "RA_CC"	     	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_CC}
		DEFINE CELL NAME "RA_MAT"	  	OF oSRA ALIAS "SRA" BLOCK {|| (cAliasQry)->RA_MAT}
		DEFINE CELL NAME "RA_NOME"	  	OF oSRA ALIAS "SRA"	BLOCK {|| (cAliasQry)->RA_NOME}
		oSRA:SetHeaderBreak(.T.)

		DEFINE SECTION oRG2 OF oReport  TITLE OemToAnsi(STR0036) ORDERS aOrd TABLES "RG2" TOTAL IN COLUMN TOTAL TEXT STR0016 

		DEFINE CELL NAME "VALE"          OF oRG2 TITLE STR0035 BLOCK {|| cCodVale	+ " - " + cDesVale	} ALIGN LEFT 
		DEFINE CELL NAME "NQTDEVALE"		OF oRG2 TITLE STR0026 BLOCK {|| nQtdeVale   } 
		DEFINE CELL NAME "NVALUNITARIO"	OF oRG2 TITLE STR0027 BLOCK {|| nValUnitario } 	PICTURE "@E 999,999.99"
		DEFINE CELL NAME "NVALTOT"		OF oRG2 TITLE STR0028 BLOCK {|| nValTot	}		PICTURE "@E 999,999.99"
		DEFINE CELL NAME "NCUSTFUN"		OF oRG2 TITLE STR0029 BLOCK {|| nValor6	} 		PICTURE "@E 999,999.99"
		DEFINE CELL NAME "NCUSTEMP"		OF oRG2 TITLE STR0030 BLOCK {|| nValor7	} 		PICTURE "@E 999,999.99"

	EndIf

Return(oReport)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GR009Imp  ∫Autor  ≥Microsiga           ∫ Data ≥ 24/01/2013  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Impress„o Mapa de BenefÌcios                               ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function GR009Imp(oReport,cImpFil)

	Local oSection1 	:= oReport:Section(1)
	Local oSection2 	:= oReport:Section(2)  
	Local dAux	  		:= dDataBase
	Local cFiltro 		:= "" 
	Local cArqNtx 		:= ""
	Local cSitQuery		:= ""
	Local cCatQuery		:= ""  
	Local cIndCond		:= ""
	Local cTitFil		:= ""
	Local cTitCc		:= ""
	Local cTitTurno		:= ""
	Local cTitFunc		:= ""   
	Local nAno			:= 0               
	Local lExcel		:= .F.
	Local oBreak                                                                                  

	//Variaveis de Acesso do Usuario
	Local cAcessaSRA	:= &( " { || " + ChkRH( "GPER009" , "SRA" , "2" ) + " } " )
	Local cAcessaRG2	:= &( " { || " + ChkRH( "GPER009" , "RG2" , "2" ) + " } " )
	Local nReg			:= 0
	Local lPass         := .t.

	Private nOrdem	    := oSection1:GetOrder()
	Private cPeriodo    := ""           //  Periodo
	Private lSalta      := .F.         //  Imprime C.C em outra Pagina
	Private nMapDif     := 1           //  Vale ou Diferenca ou Ambos 
	Private cSituacao   := ""          //  Situaá‰es
	Private cCategoria  := ""          //  Categorias

	Public bpmFiltM0Tr := Space(200)                     // EspecÌfico GBI - 11/08/16
	//*******************************************************************************

	nAno     := Year(mv_par05)
	cPeriodo := Alltrim(Str(nAno) + StrZero(Month(mv_par05),2))   
	lSalta   := If(mv_par06 == 1 , .T. , .F.)      
	If nTpVale == 0
		nMapDif    	:= mv_par07		
		cSituacao  	:= mv_par08		
		cCategoria 	:= mv_par09		
	Else    
		cSituacao  	:= mv_par07		
		cCategoria 	:= mv_par08		
	EndIf

	U_GPM5002()                                          // EspecÌfico GBI - 11/08/16
	//*******************************************************************************

	c__roteiro = "FOL"           

	lExcel := "XML" $ UPPER(oReport:cReport)

	oReport:SetCustomText( {|| Gp009Cabec( oReport, cImpFil ) })  

	oSection2:SetLeftMargen(60)
	//Totalizador de Funcionario
	oBreakFunc 	:= TRBreak():New(oSection1, oSection1:Cell("RA_MAT"),STR0004, .F.)

	//Altera titulo do break
	oBreakFunc:OnBreak({|x,y|,cTitFunc:=OemToAnsi(STR0019)+"  "+OemToAnsi(STR0020)+"  "+x})		//"ASSINATURA ___________________________" ### "TOTAL DO FUNCIONARIO "
	oBreakFunc:SetTotalText({||cTitFunc})

	DEFINE FUNCTION FROM oSection2:Cell("NQTDEVALE")		FUNCTION SUM BREAK oBreakFunc TITLE STR0026  	PICTURE "@E 99999" 			NO END SECTION NO END REPORT
	If nTpVale == 0
		DEFINE FUNCTION FROM oSection2:Cell("NVALEDIF")		FUNCTION SUM BREAK oBreakFunc TITLE STR0034  PICTURE "9999" 			NO END REPORT	NO END SECTION	WHEN {||nMapDif ==2}	//"QT.DIF."
	EndIf
	DEFINE FUNCTION FROM oSection2:Cell("NVALUNITARIO")		FUNCTION SUM BREAK oBreakFunc TITLE STR0027  	PICTURE "@E 999,999,999.99" 	NO END SECTION NO END REPORT
	DEFINE FUNCTION FROM oSection2:Cell("NVALTOT")  		FUNCTION SUM BREAK oBreakFunc TITLE STR0028  	PICTURE "@E 999,999,999.99" 	NO END SECTION NO END REPORT
	DEFINE FUNCTION FROM oSection2:Cell("NCUSTFUN")			FUNCTION SUM BREAK oBreakFunc TITLE STR0029  	PICTURE "@E 999,999,999.99" 	NO END SECTION NO END REPORT
	DEFINE FUNCTION FROM oSection2:Cell("NCUSTEMP")			FUNCTION SUM BREAK oBreakFunc TITLE STR0030  	PICTURE "@E 999,999,999.99" 	NO END SECTION NO END REPORT

	If nOrdem == 5
		oBreakTrn 	:= TRBreak():New(oSection1, oSection1:Cell("RA_TNOTRAB"),STR0024, .F.) //CENTRO DE CUSTO + TURNO + NOME
		oBreakTrn:OnBreak({|x,y|,cTitTurno:=AllTrim(OemToAnsi(STR0024))+"  "+x}) //
		oBreakTrn:SetTotalText({||cTitTurno})

		If nTpVale == 0
			DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NQTDEVALE")    BREAK oBreakTrn TITLE OemToAnsi(STR0031) PICTURE "999"          NO END SECTION NO END REPORT //"QUANTIDADE"
			DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NVALEDIF")	   BREAK oBreakTrn TITLE OemToAnsi(STR0034) PICTURE "999"			NO END SECTION NO END REPORT WHEN {||nMapDif ==2}	//"QT.DIF."
			//DEFINE COLLECTION OF oSection2 FUNCTION ONPRINT FORMULA oSection2:Cell("VALE") CONTENT {|p1,p2,p3,oObj| fDesc("SRN", oObj:Title(), "RN_VUNIATU") } BREAK oBreakTrn TITLE OemToAnsi(STR0027) PICTURE "@E 999,999.99" NO END SECTION NO END REPORT //"CUSTO UNITARIO"
			DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NVALTOT")      BREAK oBreakTrn TITLE OemToAnsi(STR0032) PICTURE "@E 999,999,999.99" NO END SECTION NO END REPORT //"VALOR TOTAL"
			DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NCUSTFUN")     BREAK oBreakTrn TITLE OemToAnsi(STR0029) PICTURE "@E 999,999,999.99" NO END SECTION NO END REPORT //"CUSTO FUNC."
			DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NCUSTEMP")     BREAK oBreakTrn TITLE OemToAnsi(STR0030) PICTURE "@E 999,999,999.99" NO END SECTION NO END REPORT //"CUSTO EMPR."
		EndIf

		DEFINE FUNCTION FROM oSection2:Cell("NQTDEVALE")		FUNCTION SUM BREAK oBreakTrn TITLE STR0026  	PICTURE "@E 99999" 			NO END SECTION NO END REPORT
		If nTpVale == 0
			DEFINE FUNCTION FROM oSection2:Cell("NVALEDIF") 	FUNCTION SUM BREAK oBreakTrn TITLE STR0034 PICTURE "9999" NO END SECTION NO END REPORT WHEN {||nMapDif ==2} 		     
		EndIf
		DEFINE FUNCTION FROM oSection2:Cell("NVALTOT")  		FUNCTION SUM BREAK oBreakTrn TITLE STR0028  	PICTURE "@E 999,999,999.99"		NO END SECTION NO END REPORT
		DEFINE FUNCTION FROM oSection2:Cell("NCUSTFUN")			FUNCTION SUM BREAK oBreakTrn TITLE STR0029  	PICTURE "@E 999,999,999.99"		NO END SECTION NO END REPORT
		DEFINE FUNCTION FROM oSection2:Cell("NCUSTEMP")			FUNCTION SUM BREAK oBreakTrn TITLE STR0030  	PICTURE "@E 999,999,999.99"		NO END SECTION NO END REPORT

		oBreakTrn2 	:= TRBreak():New(oSection1, oSection1:Cell("RA_TNOTRAB"),STR0024, .F.) //CENTRO DE CUSTO + TURNO + NOME
		oBreakTrn2:SetTotalText( {|| STR0023 } )  //TOTAL DE BENEFICIOS
		If !lExcel
			DEFINE FUNCTION FROM oSection1:Cell("RA_MAT") FUNCTION COUNT BREAK oBreakTrn2 PICTURE "@E 99999" NO END SECTION NO END REPORT
		EndIf

	Endif

	If nOrdem == 2 .OR. nOrdem == 4 .OR. nOrdem == 5

		oBreakCC 	:= TRBreak():New(oSection1, oSection1:Cell("RA_CC"),STR0021, .F.)
		oBreakCC:OnBreak({|x,y|,cTitCC:=OemToAnsi(STR0021)+"  "+x}) //TOTAL C. CUSTO
		oBreakCC:SetTotalText({||cTitCC})
		oBreakCc:lPageBreak := lSalta  

		If nTpVale == 0
			DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NQTDEVALE")      BREAK oBreakCC TITLE OemToAnsi(STR0031) PICTURE "9999"           NO END SECTION NO END REPORT //"QUANTIDADE"
			DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NVALEDIF")		BREAK oBreakCc TITLE OemToAnsi(STR0034) PICTURE "9999" 			NO END SECTION	NO END REPORT WHEN {||nMapDif ==2}	//"QT.DIF."
			//DEFINE COLLECTION OF oSection2 FUNCTION ONPRINT FORMULA oSection2:Cell("VALE") CONTENT {|p1,p2,p3,oObj| fDesc("SRN", oObj:Title(), "RN_VUNIATU") } BREAK oBreakCC TITLE OemToAnsi(STR0027) PICTURE "@E 999,999.99" NO END SECTION NO END REPORT //"CUSTO UNITARIO"
			DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NVALTOT")      BREAK oBreakCC TITLE OemToAnsi(STR0032) PICTURE "@E 999,999,999.99" NO END SECTION NO END REPORT //"VALOR TOTAL"
			DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NCUSTFUN")     BREAK oBreakCC TITLE OemToAnsi(STR0029) PICTURE "@E 999,999,999.99" NO END SECTION NO END REPORT //"CUSTO FUNC."
			DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NCUSTEMP")     BREAK oBreakCC TITLE OemToAnsi(STR0030) PICTURE "@E 999,999,999.99" NO END SECTION NO END REPORT //"CUSTO EMPR."
		EndIf

		DEFINE FUNCTION FROM oSection2:Cell("NQTDEVALE")		FUNCTION SUM BREAK oBreakCC TITLE STR0026  	PICTURE "@E 99999" 			NO END SECTION NO END REPORT
		If nTpVale == 0
			DEFINE FUNCTION FROM oSection2:Cell("NVALEDIF") 	FUNCTION SUM BREAK oBreakCC TITLE STR0034 PICTURE "9999" NO END SECTION NO END REPORT WHEN {||nMapDif ==2} 		     
		EndIf
		DEFINE FUNCTION FROM oSection2:Cell("NVALTOT")  		FUNCTION SUM BREAK oBreakCC TITLE STR0028  	PICTURE "@E 999,999,999.99" 		NO END SECTION NO END REPORT
		DEFINE FUNCTION FROM oSection2:Cell("NCUSTFUN")			FUNCTION SUM BREAK oBreakCC TITLE STR0029  	PICTURE "@E 999,999,999.99" 		NO END SECTION NO END REPORT
		DEFINE FUNCTION FROM oSection2:Cell("NCUSTEMP")			FUNCTION SUM BREAK oBreakCC TITLE STR0030  	PICTURE "@E 999,999,999.99" 		NO END SECTION NO END REPORT

		oBreakCC2 	:= TRBreak():New(oSection1, oSection1:Cell("RA_CC"),STR0021, .F.)
		oBreakCC2:SetTotalText( {|| STR0023 } )

		If !lExcel
			DEFINE FUNCTION FROM oSection1:Cell("RA_MAT") FUNCTION COUNT BREAK oBreakCC2 PICTURE "@E 99999" NO END SECTION NO END REPORT
		EndIf

	EndIf

	//Totalizador de Filial
	oBreakFil2	:= TRBreak():New(oSection1, oSection1:Cell("RA_FILIAL"),STR0022, .F.)
	oBreakFil2:OnBreak({|x,y|cTitFil:=OemToAnsi(STR0022)+" "+x})
	oBreakFil2:SetTotalText({||cTitFil})

	If nTpVale == 0
		DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NQTDEVALE")    BREAK oBreakFil2 TITLE OemToAnsi(STR0031) PICTURE "9999"           NO END SECTION NO END REPORT //"QUANTIDADE"
		DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NVALEDIF")	  BREAK oBreakFil2 TITLE OemToAnsi(STR0034) PICTURE "9999" 			 NO END SECTION	NO END REPORT WHEN {||nMapDif ==2}	//"QT.DIF."
		//DEFINE COLLECTION OF oSection2 FUNCTION ONPRINT FORMULA oSection2:Cell("VALE") CONTENT {|p1,p2,p3,oObj| fDesc("SRN", oObj:Title(), "RN_VUNIATU") } BREAK oBreakFil2 TITLE OemToAnsi(STR0027) PICTURE "@E 999,999.99" NO END SECTION NO END REPORT //"CUSTO UNITARIO"
		DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NVALTOT")      BREAK oBreakFil2 TITLE OemToAnsi(STR0032) PICTURE "@E 999,999,999.99" NO END SECTION NO END REPORT //"VALOR TOTAL"
		DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NCUSTFUN")     BREAK oBreakFil2 TITLE OemToAnsi(STR0029) PICTURE "@E 999,999,999.99" NO END SECTION NO END REPORT //"CUSTO FUNC."
		DEFINE COLLECTION OF oSection2 FUNCTION SUM     FORMULA oSection2:Cell("VALE") CONTENT oSection2:Cell("NCUSTEMP")     BREAK oBreakFil2 TITLE OemToAnsi(STR0030) PICTURE "@E 999,999,999.99" NO END SECTION NO END REPORT //"CUSTO EMPR."
	EndIf

	DEFINE FUNCTION FROM oSection2:Cell("NQTDEVALE")		FUNCTION SUM BREAK oBreakFil2 TITLE STR0026  	PICTURE "@E 99999" 			NO END SECTION NO END REPORT
	If nTpVale == 0
		DEFINE FUNCTION FROM oSection2:Cell("NVALEDIF") 	FUNCTION SUM BREAK oBreakFil2 TITLE STR0034   PICTURE "9999"  NO END SECTION NO END REPORT WHEN {||nMapDif ==2} 	     
	EndIf
	DEFINE FUNCTION FROM oSection2:Cell("NVALTOT")  		FUNCTION SUM BREAK oBreakFil2 TITLE STR0028  	PICTURE "@E 999,999,999.99" 		NO END SECTION NO END REPORT
	DEFINE FUNCTION FROM oSection2:Cell("NCUSTFUN")			FUNCTION SUM BREAK oBreakFil2 TITLE STR0029  	PICTURE "@E 999,999,999.99" 		NO END SECTION NO END REPORT
	DEFINE FUNCTION FROM oSection2:Cell("NCUSTEMP")			FUNCTION SUM BREAK oBreakFil2 TITLE STR0030  	PICTURE "@E 999,999,999.99" 		NO END SECTION NO END REPORT

	If !lExcel
		DEFINE FUNCTION FROM oSection1:Cell("RA_MAT") FUNCTION COUNT BREAK oBreakFil2 PICTURE "@E 99999" NO END SECTION NO END REPORT
	EndIf

	oSection2:SetHeaderBreak(.T.)

	cAliasQry := GetNextAlias()

	//Modifica variaveis para a Query 
	cSitQuery := ""
	For nReg:=1 to Len(cSituacao)
		cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cSituacao)
			cSitQuery += "," 
		Endif
	Next nReg        
	cSitQuery := "%" + cSitQuery + "%"

	cCatQuery := ""
	For nReg:=1 to Len(cCategoria)
		cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cCategoria)
			cCatQuery += "," 
		Endif
	Next nReg        
	cCatQuery := "%" + cCatQuery + "%"

	oSection1:BeginQuery()

	If nOrdem == 1
		cOrdem := "%SRA.RA_FILIAL,SRA.RA_MAT%"
	ElseIf nOrdem == 2
		cOrdem := "%SRA.RA_FILIAL,SRA.RA_CC,SRA.RA_MAT%"
	ElseIf nOrdem == 3
		cOrdem := "%SRA.RA_FILIAL,SRA.RA_NOME,SRA.RA_MAT%"
	ElseIf nOrdem == 4
		cOrdem := "%SRA.RA_FILIAL,SRA.RA_CC,SRA.RA_NOME%"
	ElseIf nOrdem == 5
		cOrdem := "%SRA.RA_FILIAL,SRA.RA_CC,SRA.RA_TNOTRAB,SRA.RA_NOME%"
	Endif

	MakeSqlExpr(cPerg)  

	BEGIN REPORT QUERY oSection1

		BeginSql alias cAliasQry
		SELECT SRA.*
		FROM %table:SRA% SRA
		WHERE SRA.RA_SITFOLH	IN	(%exp:Upper(cSitQuery)%) 	AND
		SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%)	AND
		SRA.%notDel%
		ORDER BY %exp:cOrdem%
		EndSql   

	END REPORT QUERY oSection1 PARAM mv_par01, mv_par02, mv_par03, mv_par04

	oSection1:EndQuery()

	//Utiliza a query do Pai  
	oSection1:SetParentQuery(.T.)

	//Define o total da regua da tela de processamento do relatorio
	oReport:SetMeter( 200 )  

	If nTpVale == 0
		cTitulo := STR0011+If(nMapDif==1,STR0013,If(nMapDif==2,STR0014,STR0015))	//" MAPA VALE TRANSPORTE "###"( NORMAL )"###"( DIFERENCA )"###"( NORMAL + DIFERENCA )"
	ElseIf nTpVale == 1
		cTitulo := STR0009	//" MAPA VALE REFEI«√O "
	Else
		cTitulo := STR0010	//" MAPA VALE ALIMENTA«√O "
	Endif
	oReport:SetTitle(cTitulo)

	c__roteiro = "   "     

	oSection1:Init()
	oSection2:Init()

	dbSelectArea(cAliasQry)
	While !EOF() 
		//Movimenta Regua Processamento                                
		oReport:IncMeter(1)
		lPass := .t.

		//Cancela impressao                                            
		If oReport:Cancel()
			Exit
		EndIf 

		//Verifica se func. tem  V.T.                                  
		DbSelectArea("RG2")
		RG2->(dbSetOrder(RetOrder("RG2", "RG2_FILIAL+RG2_MAT+RG2_PERIOD+RG2_NROPGT")))
		If !(RG2->(dbSeek((cAliasQry)->RA_FILIAL + (cAliasQry)->RA_MAT + cPeriodo))) 	    
			dbSelectArea(cAliasQry)
			dbSkip()
			Loop
		Endif

		//Consiste Filiais e Acessos
		IF !( (cAliasQry)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
			dbSelectArea(cAliasQry)
			dbSkip()
			Loop
		EndIF

		If !((cAliasQry)->RA_SITFOLH $ cSituacao) .Or. !((cAliasQry)->RA_CATFUNC $ cCategoria)
			dbSelectArea(cAliasQry)
			dbSkip()
			Loop
		Endif

		DbSelectArea("RG2")
		While !Eof() .And. ( (cAliasQry)->RA_FILIAL + (cAliasQry)->RA_MAT + cPeriodo = RG2->RG2_FILIAL + RG2->RG2_MAT + RG2_PERIOD)

			//                                                      EspecÌfico GBI - 11/08/16		
			//*******************************************************************************
			If !RG2->RG2_CODIGO $ bpmFiltM0Tr
				dbSelectArea("RG2")
				RG2->( dbSkip()) 
				Loop
			EndIf                                                

			If  RG2->RG2_TPVALE <> Alltrim(Str(nTpVale)) 
				dbSelectArea("RG2")
				RG2->( dbSkip()) 
				Loop
			EndIF                                                           

			If nTpVale == 0 
				If ( (nMapDif == 1 .And. RG2->RG2_VALCAL <= 0 ) .or. (nMapDif==2 .And. RG2->RG2_VALDIF <= 0) )
					dbSelectArea("RG2")
					RG2->( dbSkip()) 
					Loop
				EndIf
			EndIf	
			//Consiste Filiais e Acessos
			If !( RG2->RG2_FILIAL $ fValidFil() ) .or. !Eval( cAcessaRG2 )
				dbSelectArea("RG2")
				RG2->( dbSkip()) 
				Loop
			EndIF                                         

			If nTpVale == 0
				SRN->( dbSelectArea( "SRN" ) )
				If SRN-> ( dbSeek( xFilial("SRN",(cAliasQry)->RA_FILIAL) + RG2->RG2_CODIGO ) )
					cCodVale := SRN->RN_COD
					cDesVale := SRN->RN_DESC
					nValUnAn := SRN->RN_VUNIANT
					nValUnAt := SRN->RN_VUNIATU
				Endif                                              
				If RG2->RG2_DIAPRO > 0 
					If nMapDif == 1 
						nQtdeVale := RG2->RG2_DIAPRO * RG2->RG2_VTDUTE
					ElseIf nMapDif == 3
						nQtdeVale := (RG2->RG2_DIAPRO * RG2->RG2_VTDUTE) + RG2->RG2_DIADIF
					Endif
				Endif			
				If ( nQtdeVale <> RG2->RG2_DIACAL )
					nQtdeVale := RG2->RG2_DIACAL
				EndIf							
				nValedif  := RG2->RG2_DIADIF*RG2->RG2_VTDUTE	
				nValTot   := If(nMapDif == 1, RG2->RG2_VALCAL , If(nMapDif == 2, RG2->RG2_VALDIF ,RG2->RG2_VALCAL + RG2->RG2_VALDIF))			
				If nMapDif == 2
					nValUnitario := ( nValUnAt - ( nValUnAt - nValUnAn ) )
					If nValUnitario = 0
						nValUnitario := nValUnAt
					Endif
				Else
					nValUnitario := nValUnAt
				Endif		
			Else	
				RFO->( dbSelectArea( "RFO" ) )
				If RFO-> ( dbSeek( xFilial("RFO") + Alltrim(Str(nTpVale)) + RG2->RG2_CODIGO ) )
					cDesVale := RFO->RFO_DESCR
				Endif                                              
				cCodVale     := RG2->RG2_CODIGO
				nValTot      := RG2->RG2_VALCAL			
				nValUnitario := RG2->RG2_CUSUNI
				nQtdeVale    := RG2->RG2_DIACAL
			Endif		
			nValor6	:= RG2->RG2_CUSFUN+RG2_CFUNDF
			nValor7	:= RG2->RG2_CUSEMP+RG2_CEMPDF

			If nQtdeVale <=0
				dbSelectArea("RG2")
				RG2->( dbSkip() ) 
				Loop
			Endif

			If lPass
				//Incializa impressao   
				oSection1:PrintLine()
				lPass := .f.
			Endif

			oSection2:PrintLine()

			dbSelectArea("RG2")
			RG2->( dbSkip() ) 
		Enddo

		dbSelectArea(cAliasQry)
		dbSkip()
		lPass := .t.
	Enddo

	//Termino do relatorio                                         
	oSection1:Finish()
	oSection2:Finish()

Return nil    


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunáÑo    ≥Gp009Cabec  ∫ Autor ≥ M. Silveira      ∫ Data ≥ 20/03/15    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Altera o cabecalho do relatorio                             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GPER009                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Gp009Cabec( oReport, cImpFil )

	Local aCabec	:= {}
	Local cChar		:= chr(160)
	Local nPos

	nPos := aScan( aCargFil, {|x| x[1] + x[2]  == cEmpAnt + cImpFil } )

	If nPos > 0
		aCabec := {	"__LOGOEMP__" , cChar + "         " ;
		+ "         " + cChar + RptFolha+ TRANSFORM(oReport:Page(),'999999');
		, cChar + "         " ;
		+ "         " + cChar ;
		, "SIGA/" + 'GPER009.prt' + "/v." + cVersao ; 
		+ "         " + cChar + UPPER(AllTrim(cTitulo)) ;
		+ "         " + cChar + "Dt.Ref.: " + Dtoc(MV_PAR05) ;
		, RptHora + " " + time() ;
		+ "         " + cChar + RptEmiss + " " + Dtoc(dDataBase),;
		+ ("Empresa: " + AllTrim(aCargFil[nPos,06]) + " / " + "Filial: " + AllTrim(aCargFil[nPos,07])) ;
		, cChar + "         " }
	EndIf

Return( aCabec )


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ fChkUpdate ∫ Autor ≥ Raquel Hager     ∫ Data ≥ 30/01/2014  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Verifica aplicacao de update 239 - Alteracao no grp de     ∫±±
±±∫          ≥ perguntas na Impressao no Mapa.                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ */
Static Function fChkUpdate()

	Local aArea		:= GetArea()
	Local lRet		:= .T.  

	dbSelectArea("SX1")
	dbSetOrder(1)
	//Caso os grupos de pergunta sejam encontrados, admite-se que update foi aplicado.
	If 	SX1->( dbSeek("GPER009VT " + "01")) 	.And. ; 
	SX1->( dbSeek("GPER009VL " + "01")) 
		lRet := .F.
	EndIf

	RestArea( aArea )

Return( lRet )
