#Include "rwmake.ch"
#Include "topconn.ch"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} BIA995
@author Pablo S. Nascimento
@since 31/01/2020
@version 1.0
@description Relatório XXXXX
@type function
/*/

User Function BIA995TR() 

//Declaracao de variaveis
Local oReport := Nil
Private cPerg := "BIA995"

//Criacao e apresentacao das perguntas
pergunte(cPerg,.F.)

//Definicoes/preparacao para impressao
oReport := ReportDef()
oReport:PrintDialog()	

Return

Static Function ReportDef()

	Local oReport
	Local oSection1
	Local oSection2
	Local cReport 	:= "BIA995"
	
	Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       := "de acordo com os parametros informados pelo usuario."
	Local cDesc3       := "Autorizacao para pagamento da folha de pagamento"
	
	Local cDescri 	:= cDesc1 + cDesc2   	//"Este programa tem a fun‡„o de emitir os borderos de pagamen-" ### "tos."
	
	Local cTitulo 	:= "Autorizacao para pagamento da folha de pagamento"
	Local cPerg		:= "BIA995"					// BIA932 Nome do grupo de perguntas	
	
	/*Instancia do relatorio*/
	oReport := TReport():New(cReport,cTitulo,cPerg,{|oReport| PrintReport(oReport)},cDescri)
	oReport:SetLandscape(.T.)
	oReport:SetTotalInLine(.F.)//teste
	
	/*Seção-cabeçalho do relatorio
	Configuracao wTrab. Colunas criadas conforme concatenação "C"+Codigo:
	CODCC|C01|C02|C04|C05|C06|C07|C08|C09|C10|C11|C12|C13|C14|C15
	*/
	oSection1 := TRSection():New( oReport, "Sessão dos titulos", {"wTrab"} )
	TRCell():New( oSection1, "CODCC"  	,"wTrab", "CC"				,"@!", 04,,,,,"RIGHT")
	TRCell():New( oSection1, "C01"     	,"wTrab", "Folha Pagto"		,"@E 99,999,999.99", 14,,,,,"RIGHT")
	TRCell():New( oSection1, "C02"     	,"wTrab", "Rem. Diretor"	,"@E 99,999,999.99", 14,,,,,"RIGHT")
	TRCell():New( oSection1, "C04"  	,"wTrab", "INSS"			,"@E 99,999,999.99", 14,,,,,"RIGHT")
	TRCell():New( oSection1, "C05"     	,"wTrab", "INSS (Diretor)"	,"@E 99,999,999.99", 14,,,,,"RIGHT")
	TRCell():New( oSection1, "C06"   	,"wTrab", "SENAI"			,"@E 99,999,999.99", 14,,,,,"RIGHT")
	TRCell():New( oSection1, "C07"  	,"wTrab", "IR s/ ordenad"	,"@E 99,999,999.99", 14,,,,,"RIGHT")
	TRCell():New( oSection1, "C08"  	,"wTrab", "IR pro-labore"	,"@E 99,999,999.99", 14,,,,,"RIGHT")
	TRCell():New( oSection1, "C09"    	,"wTrab", "Conv. Farmácia"	,"@E 99,999,999.99", 14,,,,,"RIGHT")
	TRCell():New( oSection1, "C10" 		,"wTrab", "Pensao Alim."	,"@E 99,999,999.99", 14,,,,,"RIGHT")
	TRCell():New( oSection1, "C11" 		,"wTrab", "FGTS"			,"@E 99,999,999.99", 14,,,,,"RIGHT") 
	TRCell():New( oSection1, "C12"    	,"wTrab", "Plano Saude"		,"@E 99,999,999.99", 14,,,,,"RIGHT")
	TRCell():New( oSection1, "C13"    	,"wTrab", "Emp. Consignado"	,"@E 99,999,999.99", 14,,,,,"RIGHT")
	TRCell():New( oSection1, "C14"    	,"wTrab", "Mensal Sind."	,"@E 99,999,999.99", 14,,,,,"RIGHT")
	TRCell():New( oSection1, "C15"    	,"wTrab", "SESI"			,"@E 99,999,999.99", 14,,,,,"RIGHT")
	TRCell():New( oSection1, "TOTAL"    ,""		, "TOTAL"			,"@E 99,999,999.99", 14,,,,,"RIGHT")
	
	//TRFunction():New(oSection1:Cell("CODCC"),NIL,"",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("C01"),"TOTC01","SUM",,,,,.T.,.F.)
	TRFunction():New(oSection1:Cell("C02"),"TOTC02","SUM",,,,,.T.,.F.)
	TRFunction():New(oSection1:Cell("C04"),"TOTC04","SUM",,,,,.T.,.F.)
	TRFunction():New(oSection1:Cell("C05"),"TOTC05","SUM",,,,,.T.,.F.)
	TRFunction():New(oSection1:Cell("C06"),"TOTC06","SUM",,,,,.T.,.F.)
	TRFunction():New(oSection1:Cell("C07"),"TOTC07","SUM",,,,,.T.,.F.)
	TRFunction():New(oSection1:Cell("C08"),"TOTC08","SUM",,,,,.T.,.F.)
	TRFunction():New(oSection1:Cell("C09"),"TOTC09","SUM",,,,,.T.,.F.)
	TRFunction():New(oSection1:Cell("C10"),"TOTC10","SUM",,,,,.T.,.F.)
	TRFunction():New(oSection1:Cell("C11"),"TOTC11","SUM",,,,,.T.,.F.)
	TRFunction():New(oSection1:Cell("C12"),"TOTC12","SUM",,,,,.T.,.F.)
	TRFunction():New(oSection1:Cell("C13"),"TOTC13","SUM",,,,,.T.,.F.)
	TRFunction():New(oSection1:Cell("C14"),"TOTC14","SUM",,,,,.T.,.F.)
	TRFunction():New(oSection1:Cell("C15"),"TOTC15","SUM",,,,,.T.,.F.)
	TRFunction():New(oSection1:Cell("TOTAL"),"TOT","SUM",,,,,.T.,.F.)
	
	oSection1:SetTotalInLine(.F.) //O totalizador da secao sera impresso em coluna
	oSection1:SetTotalText("Totais") //Define o texto que será impresso antes da impressão dos totalizadores
	oSection1:SetHeaderBreak(.T.)   //Imprime o cabecalho das celulas apos a quebra
	
	//esta secao é apenas para imprimir as observacoes
	oSection2 := TRSection():New( oReport, "Observações", {"wOBS"} )
	TRCell():New( oSection2, "OBSERV"  		,"wOBS", "Observações"		,"@!", 100)
	
	oSection3 := TRSection():New( oReport, "RESUMO DO MES DE "+mv_par01+" POR CATEGORIA", {"SZY"} )
	TRCell():New( oSection3, "ZY_COD"  		,"SZY", "Cod"		,"@!", 2)
	TRCell():New( oSection3, "ZY_DESC" 		,"SZY", "Descrição"	,"@!", 40)
	TRCell():New( oSection3, "ZY_VENCTO"  	,"SZY", "Dt Vencto"	,"@D", 8,,,,,"RIGHT")
	TRCell():New( oSection3, "VALOR"  		,"", "Valor"		,"@E 99,999,999.99", 14,,,,,"RIGHT")
	TRCell():New( oSection3, "RUBRICA" 		,"", "Rúbrica"		,"@!", 30)
	
Return oReport

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  17/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function PrintReport(oReport)

	Local oSection1 	:= oReport:Section(1)
	Local oSection2 	:= oReport:Section(2) 
	Local oSection3 	:= oReport:Section(3) 
	Local 	nOrdem	 := 0
	Local 	nIndice	 := 0
	Local 	nTam	 := 0
	Local 	aCampos	 := {}
	Local 	aObs	 := {}
	Local 	aArea	 := {}
	Local 	aCategs	 := {}
	Local	aDescRed := {}
	Local 	aDesc	 := {}
	Local	aDtVenc	 := {}
	Local 	wTrab	 := ""
	Local	cQuery	 := ""
	Local 	cCampo	 := ""
	Local	nTotalCC := 0	  // Total vertical  (Centros de Custo)
	Local	aTotalCat:= {}    // Total horizontal (Categorias)
	Local i
	
	Local fun := Nil
    Local vTot := 0
    Local vTotGe := 0

	aAdd(aCampos, {"CODCC","C",4,0})
	DbSelectArea("SZY")
	DbGoTop()
	While !Eof()
		IF SZY->ZY_COD == "16" .OR. SZY->ZY_COD == "17" .OR. SZY->ZY_COD == "18" .OR. SZY->ZY_COD == "19"
			//SZY->(DbSkip())
		ELSE
			aAdd(aCategs  , SZY->ZY_COD)
			aAdd(aDesc	  , SZY->ZY_DESC)
			aAdd(aDescRed , SZY->ZY_DESCRED)
			aAdd(aDtVenc  , SZY->ZY_VENCTO)
			aAdd(aCampos  , {"C"+SZY->ZY_COD,"N",14,2})
		END IF
		DbSkip()
	EndDo
	aAdd(aCampos, {"TOTAL","N",14,2})
	wTrab 	:= CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,wTrab,"wTrab")
	DbCreateInd(wTrab,"CODCC",{||CODCC})
	
	aCC:= fCentrosCusto()
	For nIndice:= 1 to Len(aCC)
		RecLock("wTrab",.T.)
		wTrab->CODCC:= aCC[nIndice]
		MsUnlock()
	Next nIndice

	dbSelectArea("SZY")
	dbSetOrder(1)

	//setPrint
	//SetRegua(RecCount())
    
	oReport:SetMeter(SZY->(LastRec()))  
    SZY->(dbGoTop())
	
	While !Eof()

		IF SZY->ZY_COD == "16" .OR. SZY->ZY_COD == "17" .OR. SZY->ZY_COD == "18" .OR. SZY->ZY_COD == "19"
			//SZY->(DbSkip())
			A := "1"
		ELSE
			If oReport:Cancel()
				Exit
          	EndIf

			aTipoFunc:= {}
			cCodAtual:= SZY->ZY_COD
			Do Case
				Case cCodAtual == "01"
				aTipoFunc:= {"M","E"}
				Case cCodAtual == "02"
				aTipoFunc:= {"P"}
				Case cCodAtual == "03"
				aTipoFunc:= {"P"}
				Case cCodAtual == "04"
				aTipoFunc:= {"M","E","A"}
				Case cCodAtual == "05"
				aTipoFunc:= {"P"}
				Case cCodAtual == "06"
				aTipoFunc:= {"M","E","A"}
				Case cCodAtual == "07"
				aTipoFunc:= {"M","A"}
				Case cCodAtual == "08"
				aTipoFunc:= {"P"}
				Case cCodAtual == "09"
				aTipoFunc:= {"M","E","P"}
				Case cCodAtual == "10"
				aTipoFunc:= {"M","P"}
				Case cCodAtual == "11"
				aTipoFunc:= {"M","P"}
				Case cCodAtual == "12"
				aTipoFunc:= {"M","P","E"}
				Case cCodAtual == "13"
				aTipoFunc:= {"M"}
				Case cCodAtual == "14"
				aTipoFunc:= {"M"}
				Case cCodAtual == "15"
				aTipoFunc:= {"M"}
			EndCase

			If mv_par09 = 2
				IF cCodAtual = "01"
					fCat(cCodAtual, aTipoFunc)
				END IF
			ELSEIF mv_par09 = 3
				IF cCodAtual = "01"
					fCat(cCodAtual, aTipoFunc)
				ELSEIF cCodAtual = "04"
					fCat(cCodAtual, aTipoFunc)
				ELSEIF cCodAtual = "06"
					fCat(cCodAtual, aTipoFunc)
				ELSEIF cCodAtual = "07"
					fCat(cCodAtual, aTipoFunc)
				ELSEIF cCodAtual = "10"
					fCat(cCodAtual, aTipoFunc)
				ELSEIF cCodAtual = "11"
					fCat(cCodAtual, aTipoFunc)
				ELSEIF cCodAtual = "15"
					fCat(cCodAtual, aTipoFunc)				
				END IF
			ELSE
				fCat(cCodAtual, aTipoFunc)
			END IF

		END IF

		DbSelectArea("SZY")
		DbSkip()
	EndDo
	
	DbSelectArea("wTrab")
	DbGotop()
	nTam:= wTrab->(fCount())-1
	nTam--

	//inicializo a primeira seção
    oSection1:Init()

	While !Eof()
	    oReport:IncMeter()
        vTot := 0
        
        vTot := wTrab->C01 + wTrab->C02 + wTrab->C04 + wTrab->C05 + wTrab->C06 + wTrab->C07 + wTrab->C08 + wTrab->C09 + wTrab->C10 + wTrab->C11 + wTrab->C12 + wTrab->C13 + wTrab->C14 + wTrab->C15
        oSection1:Cell("TOTAL"):SetValue(vTot)
        oSection1:Printline()
        
		DbSkip()
	EndDo
	
    //finalizo a segunda seção para que seja reiniciada para o proximo registro
    oSection1:Finish()
	
	//area para adicionar as 3 observacoes
	aAdd(aObs, {"OBSERV","C",100,0})
	
	wOBS := CriaTrab(aObs,.T.)
	dbUseArea(.T.,,wOBS,"wOBS")
	
	//preencher a tabela temporaria wOBS
	RecLock("wOBS",.T.)
	wOBS->OBSERV:= "Obs1: "+alltrim(mv_par02)+" "+mv_par03
	MsUnlock()
	
	RecLock("wOBS",.T.)
	wOBS->OBSERV:= "Obs2: "+alltrim(mv_par04)+" "+mv_par05
	MsUnlock()
	
	RecLock("wOBS",.T.)
	wOBS->OBSERV:= "Obs3: "+alltrim(mv_par06)
	MsUnlock()
	
	//ler com select a tabela wObs
	DbSelectArea("wOBS")
	wOBS->(DbGotop())
	
    oReport:SkipLine()
    oReport:SkipLine()
	
	oSection2:Init()
	
	oReport:IncMeter()
	oSection2:Print()
    
    oSection2:Finish()
    
    //fechar a tabela wObs
	wOBS->(DbCloseArea())

    dbSelectArea("SZY")
	dbSetOrder(1)
	oReport:SetMeter(SZY->(LastRec()))  
    SZY->(dbGoTop())
	
	//inicializo a primeira seção
    oSection3:Init()
    vTot := 0
    
    oReport:SkipLine()
    oReport:SkipLine()

	While !Eof()
		
		IF SZY->ZY_COD != "16" .AND. SZY->ZY_COD != "17" .AND. SZY->ZY_COD != "18" .AND. SZY->ZY_COD != "19"
		
			If oReport:Cancel()
				Exit
	      	EndIf
	      	
			oReport:IncMeter()
			
	        fun := "TOTC" + SZY->ZY_COD //nome-chave da coluna na secao um
	        vTot := oReport:GetFunction(fun):GetValue()
	        oSection3:Cell("VALOR"):SetValue(vTot)
	        oSection3:Cell("RUBRICA"):SetValue("__________________________")
	        oSection3:Printline()
	        oReport:SkipLine()
	        
	        fun := ""
	        vTot := 0
        ELSEIF SZY->ZY_COD == "19"
        	/*condição usada apenas para imprimir a ultima coluna de TOTAL, já que ela não faz parte do select original*/
        	
        	oSection3:Cell("ZY_COD"):SetValue("-")
        	oSection3:Cell("ZY_DESC"):SetValue("TOTAL GERAL")
        	oSection3:Cell("ZY_VENCTO"):SetValue("-")
        	oSection3:Cell("VALOR"):SetValue(oReport:GetFunction("TOT"):GetValue())
        	oSection3:Cell("RUBRICA"):SetValue("__________________________")
	        oSection3:Printline()
        END IF
		
		DbSkip()
	enddo

	oSection3:Finish()
	SZY->(DbCloseArea())
	
	wTrab->(DbCloseArea())

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fVerbas   ¦ Autor ¦                      ¦ Data ¦          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Busca Verbas                                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fVerbas(cCodCateg)

	Local i

	Private cQuery	:= ""
	Private cVerbas := ""
	Private aVerbas	:= {}
	Private i:= 0
	Private tam:= 0

	cQuery += "SELECT RV_COD FROM "+RetSqlName("SRV")+" SRV"
	cQuery += " WHERE SRV.RV_YAP LIKE '%"+cCodCateg+"%'"
	cQuery += " OR SRV.RV_YDEDUZ LIKE '%"+cCodCateg+"%'"
	cQuery += " AND D_E_L_E_T_ <> '*'"
	TcQuery cQuery New Alias "Trab"
	DbSelectArea("Trab")
	While !EOF()
		aAdd(aVerbas, Trab->RV_COD)
		DbSkip()
	EndDo
	Trab->(DbCloseArea())

	Tam:= Len(aVerbas)
	If Tam <> 0
		Private cVerbas:= "("
		For i:= 1 to Tam
			cVerbas += "'"+aVerbas[i]+"'"
			If i < Tam
				cVerbas += ","
			EndIf
		Next i
		cVerbas += ")"
	EndIf

Return cVerbas

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fCentrosCusto   ¦ Autor ¦                ¦ Data ¦          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Busca Centro de Custo                                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fCentrosCusto

	aCC:= {}
	Private cQuery:= ""
	cQuery += " SELECT DISTINCT RC_CLVL
	cQuery += "   FROM " + RetSqlName("SRC")
	cQuery += "  WHERE RC_FILIAL = '"+cFilAnt+"'"
	cQuery += "    AND D_E_L_E_T_ = ' '
	cQuery += "  ORDER BY RC_CLVL
	TcQuery cQuery New Alias "TrabSRC"
	DbSelectArea("TrabSRC")
	
	/*
	nHandle := FCreate("c:\temp\consultaSQL2.txt")
	FWrite(nHandle, cQuery)
	FClose(nHandle)
	*/
	
	While !Eof()
		aAdd(aCC, TrabSRC->RC_CLVL)
		DbSkip()
	EndDo
	TrabSRC->(DbCloseArea())

Return aCC

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fChecaVerba   ¦ Autor ¦                  ¦ Data ¦          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Busca Centro de Custo                                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fChecaVerba(cVerba, cCateg)

	DbSelectArea("SRV")
	DbSetOrder(1)
	DbSeek(xFilial("SRV")+cVerba)

	/*If Empty(Alltrim(cCateg))
	Return "X"
	EndIf*/

	If cCateg $ SRV->RV_YAP
		Return "S"
	EndIf

Return "D"

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fCat        ¦ Autor ¦                    ¦ Data ¦          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Categoria padrao, onde nao ha consulta complexa e a        ¦¦¦
¦¦¦          ¦ operacao principal so depende da SRA e da SRC.             ¦¦¦
¦¦¦          ¦ cCodCat    : Codigo da Categoria                           ¦¦¦
¦¦¦          ¦ cTipoFunc  : Codigos de Tipo de Funcionario(em RA_CATFUNC) ¦¦¦
¦¦¦          ¦ Exemplo    : fCat("01","MP")  		                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fCat(cCodCat, aTipoFunc, cSqlAdicional)

	Local i

	Private cQuery  	:= ""
	Private cTrab		:= ""
	Private cCampo		:= "C"+cCodCat
	Private cCatFunc    := ""
	Private i			:= 0

	For i:= 1 to Len(aTipoFunc)
		cCatFunc += "'"+aTipoFunc[i]+"'"
		If i < Len(aTipoFunc)
			cCatFunc += ','
		End
	Next i

	IF MV_PAR09 = 3
		cCatFunc := "'M','E'"
	ENDIF 

	If mv_par09 = 1
		cQuery += "SELECT RA_MAT, RA_BCDEPSA, RA_NOME, RA_SITFOLH, RA_AFASFGT, RC_VALOR VALOR, RC_DATA, RC_CLVL CC, RC_PD VERBA "
		cQuery += "FROM "+RetSqlName("SRA")+" SRA, "+RetSqlName("SRC")+" SRC"
		cQuery += " WHERE RA_FILIAL = RC_FILIAL "
		cQuery += " AND RA_FILIAL = '"+cFilAnt+"'" 
		cQuery += " AND RA_CATFUNC IN ("+cCatFunc+")"
		cQuery += " AND RA_MAT = RC_MAT"
		cQuery += " AND SRA.D_E_L_E_T_ <> '*'"
		cQuery += " AND SRC.D_E_L_E_T_ <> '*'"
		cQuery += " AND SRC.RC_PD IN "+ iif( empty(fVerbas(cCodCat)), "('99985')",fVerbas(cCodCat))
	Endif

	If mv_par09 = 2
		cQuery := "SELECT RA_MAT, RA_BCDEPSA, RA_NOME, RA_SITFOLH, RA_AFASFGT, RC_VALOR VALOR, RC_DATA, RC_CLVL CC, RC_PD VERBA  "
		cQuery += "FROM "+RetSqlName("SRA")+" SRA, "+RetSqlName("SRC")+" SRC "
		cQuery += " WHERE RA_FILIAL = RC_FILIAL "
		cQuery += " AND RA_FILIAL = '"+cFilAnt+"'" 
		cQuery += " AND RA_CATFUNC IN ("+cCatFunc+")" "
		cQuery += " AND RA_MAT = RC_MAT "
		cQuery += " AND SRA.D_E_L_E_T_ <> '*' "
		cQuery += " AND SRC.D_E_L_E_T_ <> '*' "
		cQuery += " AND SRC.RC_PD IN ('066') " //,'709','402','403','447') "
	Endif			

	If mv_par09 = 3
		cQuery += "SELECT RA_MAT, RA_BCDEPSA, RA_NOME, RA_SITFOLH, RA_AFASFGT, RC_VALOR VALOR, RC_DATA, RC_CLVL CC, RC_PD VERBA FROM "+RetSqlName("SRA")+" SRA, "+RetSqlName("SRC")+" SRC"
		cQuery += " WHERE RA_FILIAL = RC_FILIAL "
		cQuery += " AND RA_FILIAL = '"+cFilAnt+"'" 
		cQuery += " AND RA_CATFUNC IN ("+cCatFunc+")"
		cQuery += " AND RA_MAT = RC_MAT"
		cQuery += " AND SRA.D_E_L_E_T_ <> '*'"
		cQuery += " AND SRC.D_E_L_E_T_ <> '*'"	

		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ FOI DEFINIDO POR WANISAY E MADALENO QUE ESTARIAMOS INFORMANDO AS VERBAM QUE IRA COMPOR CADA CATEGORIA DENTRO DO ³
		³ FONTE...                                                                                                        ³
		³ ESTA DECISÃO FOI TOMADA PARA EVITAR A CRIACAO DE CAMPO OU PARAMETRO, SENDO QUE NAO IRIA FUNCIONAR               ³
		³ POIS DEVIARIAMOS CRIAR UM CONTROLE MUITO TRABALHOSO E COMPLICADO PARA OS USUARIOS DO SETOR DE RH ADMINISTRAREM. ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		IF cCodCat = "01"
			cQuery += " AND SRC.RC_PD IN ('709')"
		ELSEIF cCodCat = "04"
			cQuery += " AND SRC.RC_PD IN ('402','780','781','782','327') "
		ELSEIF cCodCat = "06"
			cQuery += " AND SRC.RC_PD IN ('730','758','759','742') "
		ELSEIF cCodCat = "07"
			cQuery +=	 " AND SRC.RC_PD IN ('403') "
		ELSEIF cCodCat = "10"
			cQuery += " AND SRC.RC_PD IN ('447','525','542') "		
		ELSEIF cCodCat = "11"
			cQuery += " AND SRC.RC_PD IN ('744') "		
		ELSEIF cCodCat = "15"
			cQuery += " AND SRC.RC_PD IN ('764') "
		END IF
	Endif

	If cSqlAdicional <> Nil
		cQuery += cSqlAdicional
	EndIf
	cQuery += " ORDER BY RA_MAT"
	TcQuery cQuery New Alias cTrab
	DbSelectArea("cTrab")
	
	/*
	nHandle := FCreate("c:\temp\consultaSQL1.txt")
	FWrite(nHandle, cQuery)
	FClose(nHandle)
	*/
	
	While !cTrab->(Eof())
		DbSelectArea("wTrab")
		DbSetOrder(1)
		//Ú------------------------------------------------¿
		//³IR sobre ordenados - devemos pular os demitidos ³
		//À------------------------------------------------Ù
		//If cCodCat == "07" .And. cTrab->RA_SITFOLH == "D"  Desconsiderar Regra, conf. Sra. Claudia
		//	cTrab->(DbSkip())
		//	Loop
		//Ú------------------------------------------------------------------¿
		//³IR s/ ordenados - Nao considerar Autonomos                        ³
		//À------------------------------------------------------------------Ù
		If cCodCat == "07" .And. cTrab->RA_MAT >= "200000"
			cTrab->(DbSkip())
			Loop
		EndIf

		//Ú------------------------------------------------------------------¿
		//³FGTS - caso tenha sido demitido, devemos pular quem for <> H ou K ³
		//À------------------------------------------------------------------Ù
		// Retirado por Marcos Alberto Soprani em 30/01/18 a pedido da Jéssica Alvarenga
		//If cCodCat == "11" .And. cTrab->RA_SITFOLH == "D" .And. !(cTrab->RA_AFASFGT $ "H/K/J/S")
		//	cTrab->(DbSkip())
		//	Loop
		//EndIf

		DbSeek(cTrab->CC)
		IF ! wTrab->(EOF())
			RecLock("wTrab",.F.)
			If fChecaVerba(cTrab->VERBA, cCodCat) == "S"
				//wTrab->&cCampo += cTrab->VALOR
				wTrab->&(cCampo) := wTrab->&(cCampo) + cTrab->VALOR
			Else
				//wTrab->&cCampo -= cTrab->VALOR
				wTrab->&(cCampo) := wTrab->&(cCampo) - cTrab->VALOR
			EndIf
			MsUnlock()
		END IF
		cTrab->(DbSkip())
	EndDo
	cTrab->(DbCloseArea())

Return
