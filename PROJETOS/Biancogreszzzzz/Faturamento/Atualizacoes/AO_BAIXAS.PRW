#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} AO_BAIXAS
@description Relatorio e Processos de Baixa e calculos de AutorizaÁ„o de Investimento
@author Fernando Rocha
@since 17/02/2017
@version undefined

@type function
/*/

User Function AO_BAIXAS
	Private oReport,oSection1,oSection2

	Private cPerg := "AO_BAIXAS"
	Private aRegs := {}

	Private cQuery	 := "QUERY"
	Private cQuery2	 := "QUERY2"

	oReport:=ReportDef()
	oReport:PrintDialog()

Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±≥ESTRUTURA DO RELATORIO													≥±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Static Function ReportDef()
	Local cReport := "AO_BAIXAS"
	Local cAlias1 := "QUERY"
	Local cAlias2 := "QUERY2"
	Local cTitulo := "Extrato de Baixas de Acordo Objetivo"
	Local cDescri := "Extrato de Baixas de Acordo Objetivo"
	Local bReport := { |oReport|	oReport:SetTitle( oReport:Title() ),	ReportPrint( oReport ) }
	Local aOrd := {}

	ValPerg()
	Pergunte(cPerg , .T. )

	oReport  := TReport():New( cReport, cTitulo, cPerg , bReport, cDescri )
	//oReport:cFontBody := 'Arial'
	//oReport:nFontBody := 8
	//oReport:SetLeftMargin(3)
	//oReport:SetLeftMargin(3)
	//oReport:SetLineHeight(50)

	oReport:SetLandScape()


	//SECTION1
	oSection1 := TRSection():New( oReport, "", {cAlias1}, aOrd )

	TRCell():New(oSection1	,"ZO_SI"		,""	,"No. SI"			,"@!"	,012,/*lPixel*/,{|| (cQUERY)->ZO_SI 		})
	TRCell():New(oSection1	,"ZO_CLIENTE"	,""	,"Cliente"			,"@!"	,030,/*lPixel*/,{|| (cQUERY)->ZO_CLIENTE	})
	TRCell():New(oSection1	,"ZO_REPRE"		,""	,"Representante"	,"@!"	,030,/*lPixel*/,{|| (cQUERY)->ZO_REPRE		})
	TRCell():New(oSection1	,"ZO_VALOR"		,""	,"Valor"			,"@E 999,999,999.99"	,015,/*lPixel*/,{|| (cQUERY)->ZO_VALOR		})
	TRCell():New(oSection1	,"ZO_STATUS"	,""	,"Status"			,"@!"	,020,/*lPixel*/,{|| (cQUERY)->ZO_STATUS	})
	TRCell():New(oSection1	,"ZO_DATA"		,""	,"Data"				,"@!"	,015,/*lPixel*/,{|| (cQUERY)->ZO_DATA		})
	TRCell():New(oSection1	,"ZO_DATAPRO"	,""	,"Dt.Aprov."		,"@!"	,015,/*lPixel*/,{|| (cQUERY)->ZO_DATAPRO	})
	TRCell():New(oSection1	,"ZO_HORAAPR"	,""	,"Hr.Aprov."		,"@!"	,008,/*lPixel*/,{|| (cQUERY)->ZO_HORAAPR	})
	TRCell():New(oSection1	,"ZO_USUAPRO"	,""	,"Aprovador"		,"@!"	,015,/*lPixel*/,{|| (cQUERY)->ZO_USUAPRO	})
	TRCell():New(oSection1	,"ZO_ITEMCTA"	,""	,"Item CTA"			,"@!"	,015,/*lPixel*/,{|| (cQUERY)->ZO_ITEMCTA	})

	//SECTION2
	oSection2 := TRSection():New( oReport, "", {cAlias2}, aOrd )
	TRCell():New(oSection2	,"ZO_SI"			,""	,""					,"@!"	,040,/*lPixel*/,{|| (cQuery2)->TIPO_PED	})
	TRCell():New(oSection2	,"PRODUTO"			,""	,"Produto"			,"@!"	,030,/*lPixel*/,{|| AllTrim((cQuery2)->PRODUTO)+"-"+(cQuery2)->PROD_DESC	})
	TRCell():New(oSection2	,"DOC"				,""	,"Documento"   		,"@!"	,030,/*lPixel*/,{|| AllTrim((cQuery2)->DOC)+"/"+(cQuery2)->ITEM+"-"+DTOC(STOD((cQuery2)->EMISSAO)) 	})
	TRCell():New(oSection2	,"VALOR"			,""	,"Valor"	   		,"@E 999,999,999.99"	,015,/*lPixel*/,{|| (cQuery2)->VALOR })

Return oReport


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±≥Impressao do Relatorio												    ≥±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Static Function ReportPrint( oReport )
	Local oSection1	:= oReport:Section(1)
	Local nOrder	:= oSection1:GetOrder()
	Local nSaldo

	oSection1:BeginQuery()

	BeginSql Alias cQuery
		%NOPARSER%

		SELECT
		ZO_SI,
		ZO_CLIENTE = ZO_CLIENTE+'-'+A1_NREDUZ,
		ZO_REPRE = ZO_REPRE+'-'+A3_NREDUZ,
		ZO_VALOR,
		ZO_STATUS,
		ZO_DATA,
		ZO_DATAPRO,
		ZO_HORAAPR,
		ZO_USUAPRO,
		ZO_ITEMCTA

		FROM %TABLE:SZO% SZO (nolock)
		JOIN %TABLE:SA1% SA1 (nolock) ON A1_FILIAL = '  ' AND A1_COD = ZO_CLIENTE AND ZO_LOJA = ZO_LOJA
		JOIN %TABLE:SA3% SA3 (nolock) ON A3_FILIAL = '  ' AND A3_COD = ZO_REPRE

		WHERE
		ZO_FILIAL = '01'
		AND ZO_SI BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
		AND ZO_DATA BETWEEN %EXP:DTOS(MV_PAR03)% AND %EXP:DTOS(MV_PAR04)%
		AND ZO_DATAPRO BETWEEN %EXP:DTOS(MV_PAR05)% AND %EXP:DTOS(MV_PAR06)%
		AND SZO.%NOTDEL%
		AND SA1.%NOTDEL%
		AND SA3.%NOTDEL%

	EndSql

	sDebug:= GetLastQuery()[2]
	oSection1:EndQuery()



	oSection1:Init()
	(cQuery)->(DbGoTop())
	While !(cQuery)->(Eof())

		oSection1:PrintLine()

		//Impressao das baixas   
		oSection2:BeginQuery()
		QtyBaixas((cQUERY)->ZO_SI)
		oSection2:EndQuery()

		If !(cQuery2)->(Eof())

			oReport:Say(oReport:Row(), 10, "BAIXAS:" )

			nSaldo := (cQUERY)->ZO_VALOR

			oSection2:Init()
			(cQuery2)->(DbGoTop())
			While !(cQuery2)->(Eof())

				oSection2:Cell("VALOR"):SetValue(-(cQuery2)->VALOR)
				oSection2:PrintLine()

				nSaldo -= (cQuery2)->VALOR

				(cQuery2)->(DbSkip())
			EndDo
			(cQuery2)->(DbCloseArea())  

			oSection2:Cell("ZO_SI"):SetValue("")
			oSection2:Cell("PRODUTO"):SetValue("")
			oSection2:Cell("DOC"):SetValue("SALDO:")
			oSection2:Cell("VALOR"):SetValue(nSaldo)
			oSection2:PrintLine()

			oSection2:Finish()

		EndIf

		(cQuery)->(DbSkip())
	EndDo
	oSection1:Finish()
	(cQuery)->(DbCloseArea())

Return Nil



/*/{Protheus.doc} QtyBaixas
@description Query dos movimentos de baixa de AI
@author Fernando Rocha
@since 17/02/2017
@version undefined
@param _NUM_SI, , descricao
@type function
/*/
Static Function QtyBaixas(_NUM_SI, _CEMP) 

	Default _CEMP := CEMPANT

	_cSQL := "exec SP_POL_GET_BAIXAS_AI_"+_CEMP+" '"+_NUM_SI+"'"		
	TcQuery _cSQL New Alias (cQuery2)

Return    


/*/{Protheus.doc} AO_SALDO
@description Calculo de Saldo do AO
@author Fernando Rocha
@since 17/02/2017
@version undefined
@param _NUM_SI, , descricao
@type function
/*/
User Function AO_SALDO(_NUM_SI, _CPEDIDO, _LMEM, _DESPED)    
	Local nSaldo := 0
	Local cTabSZO
	Local cQrySZO
	Local cLinha
	Local cCodEmP
	Local _cEmp

	Default _LMEM := .T. 
	Default _DESPED := .F. //Se desconta valor do proprio pedido

	Private cQuery2	 := "QUERY2"

	If _LMEM
		cLinha  := M->C5_YLINHA
		cCodEmP := M->C5_YEMPPED
	Else
		SC5->(DbSetOrder(1))
		SC5->(DbSeek(XFilial("SC5")+_CPEDIDO))
		cLinha 	:= SC5->C5_YLINHA	
		cCodEmP	:= SC5->C5_YEMPPED
	EndIf		

	If AllTrim(CEMPANT) == "07"

		If (!Empty(cCodEmP))

			_cEmp		:= AllTrim(cCodEmP)
			cTabSZO 	:= "% SZO"+_cEmp+"0 %"		

		Else

			If ( cLinha $ "1_5")		
				cTabSZO := "% SZO010 %"
				_cEmp := "01"
			Else
				cTabSZO := "% SZO050 %"
				_cEmp := "05"
			EndIf

		EndIf	

	Else
		cTabSZO := "% SZO"+AllTrim(CEMPANT)+"0 %"
		_cEmp := CEMPANT
	EndIf

	cQrySZO := GetNextAlias()
	BeginSql Alias cQrySZO
		%NoParser%

		SELECT ZO_VALOR FROM %Exp:cTabSZO% WHERE ZO_FILIAL = '01' AND ZO_SI = %Exp:_NUM_SI% AND %NotDel%

	EndSql

	(cQrySZO)->(DbGoTop())
	IF !(cQrySZO)->(Eof())

		nSaldo := (cQrySZO)->ZO_VALOR

		QtyBaixas(_NUM_SI, _cEmp)
		If !(cQuery2)->(Eof())

			nSaldo := (cQuery2)->SALDO_FINAL

			//para verificar se a AI tem desconto do propio pedido sendo alterado e desconsiderar
			If _DESPED .And. !Empty(_CPEDIDO)

				While !(cQuery2)->(Eof())

					//ticket 11887: empresa Biancogres com AI de marca Incesa
					If AllTrim((cQuery2)->DOC) == AllTrim(_CPEDIDO) //.And. SubStr((cQuery2)->EMPRESA,1,2) == _cEmp
						nSaldo += (cQuery2)->VALOR 
					EndIf

					(cQuery2)->(DbSkip())
				EndDo

			EndIf

		EndIf
		(cQuery2)->(DbCloseArea())

	ENDIF
	(cQrySZO)->(DbCloseArea())

Return(nSaldo)


/*/{Protheus.doc} AI_QRYBX
@description Query com a lista de baixas da AI
@author Fernando Rocha
@since 03/03/2017
@version undefined
@param _NUM_SI, , descricao
@type function
/*/
User Function AI_QRYBX(_NUM_SI, cQAlias)    
	Local nSaldo := 0
	Private cQuery2	 := cQAlias

	SZO->(DbSetOrder(5))
	IF SZO->(DbSeek(XFilial("SZO")+_NUM_SI))

		nSaldo := SZO->ZO_VALOR

		QtyBaixas(SZO->ZO_SI)
		If !(cQuery2)->(Eof())

			Return .T.

		EndIf
		(cQuery2)->(DbCloseArea())

	ENDIF

Return .F.


/*/{Protheus.doc} AO_VALID
@description Validaao com calculo de saldo do AO
@author Fernando Rocha
@since 17/02/2017
@version undefined
@param _NUM_SI, , descricao
@type function
/*/
User Function AO_VALID(_NUM_SI)
	Local lRet := .T.

	lRet := U_AO_VAL_E(_NUM_SI)

Return(lRet)

User Function AO_VAL_E(_NUM_SI)

	Local lRet := .T.
	Local nSaldo
	Local nValor
	Local cQUERY
	Local _cTabSZO
	Local aSI := {}
	Local cAliasTmp
	Local _cEmp
	Local lOutAI

	If Empty(_NUM_SI)
		Return(.T.)
	EndIf   

	If Alltrim(M->C5_YSUBTP) == "B" .And. SC6->(FieldPos("C6_YDAI")) > 0
		If (AllTrim(ReadVar()) == "M->C5_YNUMSI" .And. !Empty(M->C5_YNOUTAI)) .Or.;
		(AllTrim(ReadVar()) == "M->C5_YNOUTAI" .And. !Empty(M->C5_YNUMSI))

			MsgAlert("Pedido de BonificaÁ„o - Somente pode usar um dos dois campos de AI: 'N∫ AI ref.AO' OU 'N∫ AI Outros'","AutorizaÁ„o de Investimento (AO_BAIXAS)")
			Return(.F.)

		EndIf		
	EndIf

	If Alltrim(M->C5_YLINHA) $ "2#3" .And. AllTrim(CEMPANT) $ "05"  //ticket 10958 marreta provisoria AI Incesa na Bianco
		_cTabSZO 	:= "SZO050"
		_cEmp		:= "05"
	Else                    
		_cTabSZO	:= "SZO010"
		_cEmp		:= "01"
	EndIf

	If (AllTrim(CEMPANT) == "07")
		If ((ValType(aCols) <> "U" .And. Len(aCols) < 1) .Or. Empty(M->C5_YEMPPED))
			Aviso("AUTORIZA«√O DE INVESTIMENTO","AtenÁ„o: Na Empresa - LM, È necessario preencher uma linha do pedido, para depois informado o cÛdigo da AI.",{"OK"},2,"SI informada: "+_NUM_SI)
			Return(.F.)
		EndIf

		If (!Empty(M->C5_YEMPPED))
			_cEmp		:= AllTrim(M->C5_YEMPPED)
			_cTabSZO 	:= "SZO"+_cEmp+"0"		
		EndIf			
	EndIf


	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	cQUERY := "select ZO_SI, ZO_ITEMCTA from "+_cTabSZO+" where ZO_SI = '"+_NUM_SI+"' and RTRIM(ZO_STATUS) not in ('Baixa Total','Aguard. AprovaÁ„o','Aguard. Aprov. Dir.') and D_E_L_E_T_ = '' "

	TcQuery cQUERY New Alias "QRY"

	QRY->(dbGoTop())

	IF !QRY->(Eof())

		If AllTrim(ReadVar()) == "M->C5_YNUMSI" .And. AllTrim(QRY->ZO_ITEMCTA) <> "I0201"
			Aviso("AUTORIZA«√O DE INVESTIMENTO","AtenÁ„o: A SI informada n„o È proveniente de Acordo de Objetivos."+CRLF+"Utilize o campo 'No.AI Outras'",{"OK"},2,"SI informada: "+_NUM_SI)
			QRY->(DbCloseArea())
			Return(.F.)		
		EndIf

		If AllTrim(ReadVar()) == "M->C5_YNOUTAI" .And. AllTrim(QRY->ZO_ITEMCTA) == "I0201"
			Aviso("AUTORIZA«√O DE INVESTIMENTO","AtenÁ„o: A SI informada È proveniente de Acordo de Objetivos."+CRLF+"Utilize o campo 'No.AI ref.AO'",{"OK"},2,"SI informada: "+_NUM_SI)
			QRY->(DbCloseArea())
			Return(.F.)		
		EndIf

	ELSE
		lRet := .F.	
	ENDIF	

	//Validacao de cliente
	If lRet

		lOutAI := ( AllTrim(ReadVar()) == "M->C5_YNOUTAI" )

		cAliasTmp := GetNextAlias()
		cQUERY := "exec SP_AI_COM_SALDO_CLIENTE_"+_cEmp+" '"+M->C5_CLIENTE+"','"+M->C5_LOJACLI+"', "+IIF(lOutAI,"1","0")+"  "
		TcQuery cQUERY New Alias (cAliasTmp)

		lRet := .F.
		(cAliasTmp)->(dbGoTop())
		While !(cAliasTmp)->(Eof())

			If _NUM_SI == (cAliasTmp)->NUM_AI
				lRet := .T.
				Exit			
			EndIf

			(cAliasTmp)->(dbSkip())
		End
		(cAliasTmp)->(dbCloseArea())

	EndIf	

	IF !lRet

		Aviso("AUTORIZA«√O DE INVESTIMENTO","AtenÁ„o: A SI informada n„o atende aos critÈrios:"+CRLF+;
		"A SI informada precisa estar APROVADA"+CRLF+;
		"A SI informada tem que pertencer a algum cliente do GRUPO"+CRLF+;
		"A SI precisa ter SALDO disponÌvel.",{"OK"},2,"SI informada: "+_NUM_SI)
		lRet := .F.

	ENDIF

	QRY->(DbCloseArea())

Return(lRet)

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±≥ValPerg - Funcao para criar o grupo de perguntas SX1 se nao existir    ≥±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Static Function ValPerg()
	Local i,j,nX
	Local aTRegs := {}
	Local aHelpPor := {}
	Local aHelpEng := {}
	Local aHelpSpa := {}

	cPerg := PADR(cPerg,10)

	//DECLARACAO DAS PERGUNTAS NA ORDEM QUE DESEJA CRIAR
	aAdd(aTRegs,{"Da SI?","C",6,0,0,"G","","","","","","","","","Numero inicial da SI #a ser feita a an·lise."})
	aAdd(aTRegs,{"Ate a SI?","C",6,0,0,"G","","","","","","","","Numero final da SI #a ser feita a an·lise."})
	aAdd(aTRegs,{"Data De?","D",8,0,0,"G","","","","","","","","Data inicial da SI."})
	aAdd(aTRegs,{"Data Ate?","D",8,0,0,"G","","","","","","","","Data final da SI."})
	aAdd(aTRegs,{"Data Aprov. De?","D",8,0,0,"G","","","","","","","","Data inicial #de aprovaÁ„o da SI."})
	aAdd(aTRegs,{"Data Aprov. Ate?","D",8,0,0,"G","","","","","","","","Data final #de aprovaÁ„o da SI."})

	//Criar aRegs na ordem do vetor Temporario
	aRegs := {}
	For I := 1 To Len(aTRegs)
		aAdd(aRegs,{cPerg,StrZero(I,2),aTRegs[I][1],aTRegs[I][1],aTRegs[I][1]	,"mv_ch"+Alltrim(Str(I)),aTRegs[I][2],aTRegs[I][3],aTRegs[I][4],aTRegs[I][5],aTRegs[I][6],aTRegs[I][7],;
		"mv_par"+StrZero(I,2),aTRegs[I][8],"","","","",aTRegs[I][9],"","","","",aTRegs[I][10],"","","","",aTRegs[I][11],"","","","",aTRegs[I][12],"","","",aTRegs[I][13],""})
	Next I

	//Grava no SX1 se ja nao existir
	dbSelectArea("SX1")
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Else
			//ATUALIZA SX1
			RecLock("SX1",.F.)
			For j:=3 to FCount()
				If j <= Len(aRegs[i])
					If SubStr(FieldName(j),1,6) <> "X1_CNT"
						FieldPut(j,aRegs[i,j])
					EndIf
				Endif
			Next
			MsUnlock()
		EndIf

		//HELP DAS PERGUNTAS
		aHelpPor := {}
		__aRet := STRTOKARR(aTRegs[I][14],"#")
		FOR nX := 1 To Len(__aRet)
			AADD(aHelpPor,__aRet[nX])
		NEXT nX
		PutSX1Help("P."+AllTrim(cPerg)+aRegs[i,2]+".",aHelpPor,aHelpEng,aHelpSpa)
	Next

	//Renumerar perguntas
	_ncont := 1
	SX1->(dbSeek(cPerg))
	While .Not. SX1->(Eof()) .And. X1_GRUPO == cPerg
		RecLock("SX1",.F.)
		SX1->X1_ORDEM := StrZero(_ncont,2)
		SX1->(MsUnlock())
		SX1->(DbSkip())
		_ncont++
	EndDo

	//Deletar Perguntas sobrando - apagadas do vetor
	While SX1->(dbSeek(cPerg+StrZero(i,2)))
		RecLock("SX1",.F.)
		SX1->(DbDelete())
		SX1->(MsUnlock())
		i++
	EndDo

Return


/*/{Protheus.doc} AO_INCBX
@description INCLUSAO DE BAIXAS DE ACORDO APOS COLOCACAO DO PEDIDO
@author Fernando Rocha
@since 17/02/2017
@version undefined
@param _CPEDIDO, , descricao
@param _CNUMSI, , descricao
@type function
/*/
User Function AO_INCBX(_CPEDIDO,_CNUMSI, _CTEXTO, _NOPC)
	//_NOPC == 1 >> desconto de AI de AO
	//_NOPC == 2 >> desconto de outras AI

	Local __cAliasAux
	Local oDesconto, _nDescVer
	Local _NVALOR := 0
	Local _nFatEntrega
	Local _cSQL
	Local _cEmpDest := ""
	Local _aAreaC5

	Default _CTEXTO		:= "Baixa Aut. Acordo"
	Default _NOPC		:= 1

	//Buscando descontos de acordo objetivo
	__cAliasAux := GetNextAlias()
	_cSQL := "select VDESC = dbo.FNC_POL_VALDESC_AI('"+XFILIAL("SC5")+"','"+AllTrim(CEMPANT)+"','"+_CPEDIDO+"',"+AllTrim(Str(_NOPC))+")"
	TCQuery _cSQL Alias (__cAliasAux) New

	(__cAliasAux)->(DbGoTop())		
	If !(__cAliasAux)->(Eof())
		_NVALOR := (__cAliasAux)->VDESC
	Else
		_NVALOR := 0
	EndIf
	(__cAliasAux)->(DbCloseArea())

	//Inclusao da AI
	If (_NVALOR > 0)

		//
		If AllTrim(CEMPANT) == "07"

			_aAreaC5 := SC5->(GetArea())
			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(XFilial("SC5")+_CPEDIDO))

				_cEmpDest := SC5->C5_YEMPPED

			EndIf
			RestArea(_aAreaC5)

		EndIf 

		If Empty(_cEmpDest) .Or. ( AllTrim(CEMPANT) $ "01#05#13" )  // Ajuste Ticket 11063 - Se o pedido est· na empresa fabrica - a AI tem que estar nesta empresa - nao usar a regra da marca pois apos consolidacao os pedidos sao todos na Biancogres 

			lRet := U_AO_IBX_E(_CPEDIDO,_CNUMSI,_NVALOR,,_CTEXTO)

		Else

			lRet := U_FROPCPRO(SubStr(_cEmpDest,1,2),"01","U_AO_IBX_E", _CPEDIDO, _CNUMSI,_NVALOR, AllTrim(CEMPANT)+AllTrim(CFILANT), _CTEXTO)

		EndIf

	Else

		//Valor Zero
		//Se existir baixa na AI, excluir
		_aAreaC5 := SC5->(GetArea())
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(XFilial("SC5")+_CPEDIDO))

			U_AIEXCBX(_CPEDIDO, SC5->C5_YLINHA, _CNUMSI, SC5->C5_CLIENTE, SC5->C5_YEMPPED)

		EndIf
		RestArea(_aAreaC5)

	EndIf

Return

/*/{Protheus.doc} AO_IBX_E
@description Inclusao de Baixas de AI
@author Fernando Rocha
@since 05/05/2017
@version undefined
@param _CPEDIDO, , descricao
@param _CNUMSI, , descricao
@param _NVALOR, , descricao
@param _CEMPORI, , descricao
@param _CTEXTO, , descricao
@type function
/*/
User Function AO_IBX_E(_CPEDIDO,_CNUMSI,_NVALOR, _CEMPORI, _CTEXTO)

	Local cQryIt
	Local cQryTmp
	Local _cItem 	:= "0001"
	Local _cDoc
	Local _lAltera	:= .F.
	Local _aArea := GetArea()
	Local _aAreaZZQ := ZZQ->(GetArea())

	Default _CEMPORI	:= AllTrim(CEMPANT)+AllTrim(CFILANT) 
	Default _CTEXTO		:= "Baixa Aut. Acordo" 	

	//verifica se eh pedido LM e busca o pedido e empresa na LM
	cQryTmp := GetNextAlias()
	BeginSql Alias cQryTmp
		%NoParser%

		select C5_FILIAL, C5_NUM from SC5070 (nolock) where C5_FILIAL <> ' ' and C5_YEMPPED = %Exp:SubStr(_CEMPORI,1,2)% and C5_YPEDORI = %Exp:_CPEDIDO% and %NotDel% 

	EndSql
	if !(cQryTmp)->(Eof())
		_CPEDIDO := (cQryTmp)->C5_NUM
		_CEMPORI := "07"+(cQryTmp)->C5_FILIAL
	EndIf
	(cQryTmp)->(DbCloseArea())

	//documento
	If Len(AllTrim(_CPEDIDO)) == 6
		_cDoc	:= "PED"+_CPEDIDO
	Else
		_cDoc	:= _CPEDIDO
	EndIf

	//verifica de baixa do documento ja existe
	cQryIt := GetNextAlias()
	BeginSql Alias cQryIt
		%NoParser%

		select ITEM = ZZQ_ITEM from %Table:ZZQ% (nolock) where ZZQ_COD = %Exp:_CNUMSI% and ZZQ_FORNEC = %Exp:_CEMPORI% and ZZQ_DOC = %Exp:_cDoc% and D_E_L_E_T_=''

	EndSql

	ZZQ->(DbSetOrder(1))
	If !(cQryIt)->(Eof()) .And. ZZQ->(DbSeek(XFilial("ZZQ")+_CNUMSI+(cQryIt)->ITEM+_cDoc))
		_lAltera := .T.
	Else

		cQryTmp := GetNextAlias()
		BeginSql Alias cQryTmp
			%NoParser%

			select ITEM = RIGHT('0000' + cast(isnull((select max(convert(int,ZZQ_ITEM)) from %Table:ZZQ% (nolock) where ZZQ_COD = %Exp:_CNUMSI% and D_E_L_E_T_ = ''),0)+1 as varchar(4)),4)

		EndSql

		If !(cQryTmp)->(Eof())
			_cItem := (cQryTmp)->ITEM 
		EndIf

		(cQryTmp)->(DbCloseArea())

	EndIf

	(cQryIt)->(DbCloseArea())

	If _lAltera 

		//Se for alteracao somente mudar quando mudanca de valor
		If (ZZQ->ZZQ_VALOR <> _NVALOR)

			RecLock("ZZQ",.F.)
			ZZQ->ZZQ_VALOR	:= _NVALOR	   
			ZZQ->(MsUnlock())

		EndIf

	Else

		RecLock("ZZQ",.T.) 
		ZZQ->ZZQ_FILIAL := XFilial("ZZQ")
		ZZQ->ZZQ_DATA	:= dDataBase
		ZZQ->ZZQ_COD	:= _CNUMSI
		ZZQ->ZZQ_FORNEC := _CEMPORI  //provisorio com o campo ZZQ_FORNEC
		ZZQ->ZZQ_EMPORI := _CEMPORI
		ZZQ->ZZQ_LOJA	:= "01"
		ZZQ->ZZQ_ITEM	:= _cItem
		ZZQ->ZZQ_DOC	:= _cDoc
		ZZQ->ZZQ_VALOR	:= _NVALOR
		ZZQ->ZZQ_ITFORN	:= _CTEXTO   
		ZZQ->(MsUnlock()) 

	EndIf 

	RestArea(_aArea)
	RestArea(_aAreaZZQ)
Return


/*/{Protheus.doc} AIEXCBX
@description Exclusao de Baixas de AI
@author Fernando Rocha
@since 05/05/2017
@version undefined
@param _cPedido, , descricao
@param _cLinha, , descricao
@param _CNUMSI, , descricao
@param _cCliente, , descricao
@type function
/*/
User Function AIEXCBX(_cPedido, _cLinha, _CNUMSI, _cCliente, _cEmpPed)

	Local _cEmpOri := AllTrim(cEmpAnt)+AllTrim(cFilAnt)
	Local _cQTmp

	//Verificar se existe baixa de AI do pedido e excluir a baixa
	__cDoc  := 'PED'+_cPedido
	__cTabZZQ := "ZZQ"+AllTrim(cEmpAnt)+"0"

	If AllTrim(cEmpAnt) == "07"

		If (!Empty(_cEmpPed))

			__cTabZZQ 	:= "ZZQ"+AllTrim(_cEmpPed)+"0"		

		Else
			If (_cLinha $ "1_5")
				__cTabZZQ := "ZZQ010"
			Else
				__cTabZZQ := "ZZQ050"
			EndIf
		EndIf
			
	Else

		If AllTrim(_cCliente) == "010064"
			_cEmpOri := "0701"

			//buscar pedido LM
			_cQTmp := GetNextAlias()
			BeginSql Alias _cQTmp
				%NoParser%

				SELECT C5_NUM FROM SC5070 (nolock) WHERE C5_FILIAL = '01' AND C5_YEMPPED = %Exp:AllTrim(cEmpAnt)% AND C5_YPEDORI = %Exp:_cPedido% AND D_E_L_E_T_=''

			EndSql			

			If !(_cQTmp)->(Eof())

				__cDoc  := 'PED'+(_cQTmp)->C5_NUM	
				__cTabZZQ := "ZZQ"+AllTrim(cEmpAnt)+"0"

			EndIf
			(_cQTmp)->(DbCloseArea())

		EndIf

	EndIf

	__cTabSql := "% "+__cTabZZQ+" %"

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp	
	%NoParser%

		//fernando em 04/04/2017 - usando o campo ZZQ_FORNEC como empresa origem provisorio - estava dando erro com o ZZQ_ITEM

		select 1 from %Exp:__cTabSql% where ZZQ_COD = %Exp:_CNUMSI% and ZZQ_FORNEC = %Exp:_cEmpOri% and ZZQ_DOC = %Exp:__cDoc% and %NotDel%		

	EndSql

	ZZQ->(DbSetOrder(1))

	(cAliasTmp)->(DbGoTop())
	If !(cAliasTmp)->(Eof())

		__cSql := " update "+__cTabZZQ+" set D_E_L_E_T_ = '*' where ZZQ_COD = '"+_CNUMSI+"' and ZZQ_FORNEC = '"+_cEmpOri+"' and ZZQ_DOC = '"+__cDoc+"' and D_E_L_E_T_='' " 
		TCSQLExec(__cSql)

	EndIf
	(cAliasTmp)->(DbCloseArea())

Return

/*/{Protheus.doc} B410CBAI
@description Chamada da funcao de recalculo de baixa de AI por botao no AROTINA do pedido de vendas
@author Fernando Rocha
@since 15/12/2017
@version 1.0
@type function
/*/
User Function B410CBAI

	If MsgNoYes("Deseja recalcular as baixas de AI/AO do pedido: "+SC5->C5_NUM+"?")

		If !Empty(SC5->C5_YNUMSI)
			//incluir nova baixa para itens restantes do pedido
			U_AO_INCBX(SC5->C5_NUM,SC5->C5_YNUMSI)
		EndIf

		If !Empty(SC5->C5_YNOUTAI)
			//incluir nova baixa para itens restantes do pedido
			U_AO_INCBX(SC5->C5_NUM,SC5->C5_YNOUTAI,"Baixa.Aut.Ped.c/Desc.", 2)
		EndIf

	EndIf

Return