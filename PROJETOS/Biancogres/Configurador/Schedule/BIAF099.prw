#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF099
@author Tiago Rossini Coradini
@since 01/03/2018
@version 1.0
@description Workflow de status de solicitações de compra 
@obs Ticket: 2206
@type Function
/*/

// Indices das colunas do array de solicitações de compra
#DEFINE _NomSol 1
#DEFINE _MailSol 2
#DEFINE _CodEmp 3
#DEFINE _DesEmp 4
#DEFINE _CodSol 5
#DEFINE _NumBiz 6
#DEFINE _NumSol 7
#DEFINE _IteSol 8
#DEFINE _CodPrd 9
#DEFINE _DesPrd 10
#DEFINE _NumPed 11
#DEFINE _ItePed 12
#DEFINE _NomFor 13
#DEFINE _DatEmi 14
#DEFINE _NomCom 15
#DEFINE _NomApr 16
#DEFINE _StaApr 17
#DEFINE _DatApr 18
#DEFINE _DatChe 19
#DEFINE _StaEnt 20
#DEFINE _Follow 21
#DEFINE _ObsCom 22
#DEFINE _QtdCom 23
#DEFINE _QtdEnt 24
#DEFINE _Residuo 25
#DEFINE _RecNo 26

User Function BIAF099()
Local cSQL := ""
Local consultEmp := {}
Local cSC101 := RetFullName("SC1", "01")
Local cSC105 := RetFullName("SC1", "05")
Local cSC114 := RetFullName("SC1", "14")
Local cSC701 := RetFullName("SC7", "01")
Local cSC705 := RetFullName("SC7", "05")
Local cSC714 := RetFullName("SC7", "14")
Local cSCR01 := RetFullName("SCR", "01")
Local cSCR05 := RetFullName("SCR", "05")
Local cSCR14 := RetFullName("SCR", "14")

Local cSA201 := RetFullName("SA2", "01")
Local cQry := GetNextAlias()
Local cNomSol := ""
Local cMailSol := "" 
Local cNomCom := ""
Local cNomApr := ""
Local cStaApr := ""
Local cDatApr := ""
Local aSolCom := {}
Local nCount := 1
Local cHtml := ""
Local cItem := ""			
Local cBizagi := ""
	
	RpcSetType(3)
	RpcSetEnv("01", "01")

	cBizagi := U_fGetBase("2") 	

	Aadd(consultEmp, {cSC101, cSC701, cSCR01, "0101", "Biancogres"})
	Aadd(consultEmp, {cSC105, cSC705, cSCR05, "0501", "Incesa"})
	Aadd(consultEmp, {cSC114, cSC714, cSCR14, "1401", "Vinílico"})
		
	cSQL := " SELECT * "
	cSQL += " FROM ( "

	//para cada empresa faz o select correspondente
	For nCount := 1 To Len(consultEmp)

		cSQL += " 	SELECT ISNULL(SOLICITANTE, '') AS NOMSOL, ISNULL(EMAIL, '') AS EMAIL, '"+ SubStr(consultEmp[nCount][4], 1, 2) +"' AS CODEMP, '"+ consultEmp[nCount][5] +"' AS DESEMP, C1_USER, C1_YBIZAGI, C1_NUM, C1_ITEM, C1_PRODUTO, C1_DESCRI, C7_NUM, C7_ITEM, "
		cSQL += " 	C7_FORNECE + '-' + C7_LOJA + ' - ' + "
		cSQL += " 	LTRIM(( "
		cSQL += " 		SELECT A2_NOME " 
		cSQL += " 		FROM " + cSA201 + " (nolock) "
		cSQL += " 		WHERE A2_FILIAL = " + ValToSQL(xFilial("SA2"))
		cSQL += " 		AND A2_COD = C7_FORNECE "
		cSQL += " 		AND A2_LOJA = C7_LOJA "
		cSQL += " 		AND D_E_L_E_T_ = '')) AS A2_NOME, C7_EMISSAO, C7_USER, "	  
		cSQL += " 	ISNULL(( "
		cSQL += " 		SELECT TOP 1 CR_USER " 
		cSQL += " 		FROM " + consultEmp[nCount][3]  + " (nolock) "// cSCR01
		cSQL += " 		WHERE CR_FILIAL = " + ValToSQL(xFilial("SCR")) 
		cSQL += " 		AND CR_TIPO = 'PC' "
		cSQL += " 		AND C7_NUM = CR_NUM "
		cSQL += " 		AND D_E_L_E_T_ = '' "
		cSQL += " 		ORDER BY R_E_C_N_O_ DESC), '') AS CR_USER, " 
		cSQL += " 	ISNULL(( "
		cSQL += " 		SELECT TOP 1 CR_DATALIB " 
		cSQL += " 		FROM " + consultEmp[nCount][3]  + " (nolock) "//cSCR01
		cSQL += " 		WHERE CR_FILIAL = " + ValToSQL(xFilial("SCR")) 
		cSQL += " 		AND CR_TIPO = 'PC' "
		cSQL += " 		AND C7_NUM = CR_NUM " 
		cSQL += " 		AND D_E_L_E_T_ = '' " 
		cSQL += " 		ORDER BY R_E_C_N_O_ DESC), '') AS CR_DATALIB, C7_CONAPRO, C7_YDATCHE, "
		cSQL += " 	CASE "
		cSQL += " 	WHEN C7_QUJE = 0 AND C7_RESIDUO = '' THEN 'Pendente' "
		cSQL += " 	WHEN C7_QUANT > C7_QUJE AND C7_RESIDUO = '' THEN 'Entregue Parcial' "
		cSQL += " 	WHEN C7_QUANT = C7_QUJE AND C7_RESIDUO = '' THEN 'Entregue' "
		cSQL += " 	WHEN C7_RESIDUO = 'S' THEN 'Eliminado por Residuo' "
		cSQL += " 	END AS STATUS_ENT, "
		cSQL += " 	C7_YFOLLOW, C7_YOBSCOM, C7_QUANT, C7_QUJE, C7_RESIDUO, SC1.R_E_C_N_O_ AS RECNO "
		cSQL += " 	FROM " + consultEmp[nCount][2] + " (nolock) SC7 " //cSC701
		cSQL += " 	INNER JOIN " + consultEmp[nCount][1] + " (nolock) SC1 " //cSC101
		cSQL += " 	ON C7_FILIAL = C1_FILIAL "
		cSQL += " 	AND C7_NUM = C1_PEDIDO "
		cSQL += " 	AND C7_ITEM = C1_ITEMPED "
		cSQL += " 	LEFT JOIN "+cBizagi+".dbo.BZ_DADOS_SC SC_BIZ (nolock)"
		cSQL += " 	ON BIZAGI COLLATE Latin1_General_BIN = C1_YBIZAGI "
		cSQL += " 	AND PROTHEUS COLLATE Latin1_General_BIN = C1_NUM "
		cSQL += " 	AND EMPRESA = '" + consultEmp[nCount][4] + "' "
		cSQL += " 	WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
		cSQL += " 	AND C7_EMISSAO >= '20170101'
		cSQL += " 	AND SC7.D_E_L_E_T_ = '' "
		cSQL += " 	AND C1_YENVSC = '' "
		cSQL += " 	AND SC1.D_E_L_E_T_ = '' "

		IF (nCount < Len(consultEmp))
			cSQL += " 	UNION ALL	"
		ENDIF

	Next nCount

	cSQL += " ) AS SC "	
	cSql += "  WHERE C7_USER <> '000580' "
	cSQL += " ORDER BY EMAIL, CODEMP, C7_EMISSAO, C1_YBIZAGI, C1_NUM, C7_NUM, C7_ITEM "	
			
	TcQuery cSQL New Alias (cQry)
	  			
	While (cQry)->(!Eof())			 			
		 
		cNomSol := Capital(fRetNome(AllTrim((cQry)->NOMSOL)))
		
		If Empty(cNomSol)
		
			cNomSol := Capital(fRetNome(AllTrim(UsrFullName((cQry)->C1_USER))))
		
		EndIf
		
		cMailSol := AllTrim((cQry)->EMAIL)
		
		If Empty(cMailSol)
		
			cMailSol := AllTrim(UsrRetMail((cQry)->C1_USER))
		
		EndIf
		
		If !Empty(cNomSol) .And. !Empty(cMailSol)
		
			cNomCom := Capital(fRetNome(AllTrim(UsrFullName((cQry)->C7_USER))))
						
			If !Empty((cQry)->CR_USER)
			
				cNomApr := Capital(fRetNome(AllTrim(UsrFullName((cQry)->CR_USER))))
			
			Else
				
				cNomApr := "Automático"
				
			EndIf
			
			If (cQry)->C7_CONAPRO == "L"
			
				cStaApr := "Aprovado"
				
				If !Empty((cQry)->CR_DATALIB)
				
					cDatApr := dToC(sToD((cQry)->CR_DATALIB))
					
				Else
				
					cDatApr := dToC(sToD((cQry)->C7_EMISSAO))
				
				EndIf
				
			Else
			
				cStaApr := "Bloqueado"
				cDatApr := ""
			
			EndIf

			aAdd(aSolCom, {cNomSol, cMailSol, (cQry)->CODEMP, (cQry)->DESEMP, (cQry)->C1_USER, (cQry)->C1_YBIZAGI, (cQry)->C1_NUM, (cQry)->C1_ITEM, AllTrim((cQry)->C1_PRODUTO), AllTrim((cQry)->C1_DESCRI),; 
										(cQry)->C7_NUM, (cQry)->C7_ITEM, (cQry)->A2_NOME, dToC(sToD((cQry)->C7_EMISSAO)), cNomCom, cNomApr, cStaApr, cDatApr, dToC(sToD((cQry)->C7_YDATCHE)),;
										(cQry)->STATUS_ENT, (cQry)->C7_YFOLLOW, (cQry)->C7_YOBSCOM, (cQry)->C7_QUANT, (cQry)->C7_QUJE, (cQry)->C7_RESIDUO, (cQry)->RECNO})			
	  EndIf
	  
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(dbCloseArea())
	
		
	If !Empty(aSolCom)
		
		aSolCom := aSort(aSolCom,,, {|x,y| x[_MailSol] + x[_DesEmp] + x[_DatEmi] + x[_NumBiz] + x[_NumSol] + x[_IteSol] + x[_NumPed] + x[_ItePed] < ;
																			 y[_MailSol] + y[_DesEmp] + y[_DatEmi] + y[_NumBiz] + y[_NumSol] + y[_IteSol] + y[_NumPed] + y[_ItePed]})

    cMailSol := aSolCom[1, _MailSol]
    
    While nCount <= Len(aSolCom)
    	
			While nCount <= Len(aSolCom) .And. cMailSol == aSolCom[nCount, _MailSol]
			
				cItem	+= fRetItem(aSolCom[nCount])
				
				fUpdEnv(aSolCom[nCount])
					
				cMailSol := aSolCom[nCount, _MailSol]
				
				nCount++
				
			EndDo()
						
			cHtml	:= fRetCab()
			cHtml	+= cItem
			cHtml	+= fRetRod()
			
			fSendMail(cMailSol, cHtml)
						
			cItem := ""
			
			If nCount <= Len(aSolCom)
				cMailSol := aSolCom[nCount, _MailSol]
			EndIf
    	    	
    EndDo()
    
	EndIf
			
	RpcClearEnv()
		
Return()


Static Function fRetCab()
Local cRet := ""

	cRet := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cRet += '<html xmlns="http://www.w3.org/1999/xhtml">
	cRet += '<head>
	cRet += '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cRet += '    <title>Workflow</title>
	cRet += '    <style type="text/css">
	cRet += '        <!-- 
	cRet += '		.styleTable{
	cRet += '			border:0;
	cRet += '			cellpadding:3;
	cRet += '			cellspacing:2;
	cRet += '			width:100%;
	cRet += '		}
	cRet += '		.styleTableCabecalho{
	cRet += '            background: #fff;
	cRet += '            color: #ffffff;
	cRet += '            font: 14px Arial, Helvetica, sans-serif;
	cRet += '			font-weight: bold;
	cRet += '		}
	cRet += '        .styleCabecalho{
	cRet += '            background: #0c2c65;
	cRet += '            color: #ffffff;
	cRet += '            font: 12px Arial, Helvetica, sans-serif;
	cRet += '			font-weight: bold;
	cRet += '			padding: 5px;
	cRet += '        }
	cRet += '		.styleLinha{
	cRet += '            background: #f6f6f6;
	cRet += '            color: #747474;
	cRet += '            font: 11px Arial, Helvetica, sans-serif;
	cRet += '			padding: 5px;
	cRet += '        }
	cRet += '        .styleRodape{
	cRet += '            background: #0c2c65;
	cRet += '            color: #ffffff;
	cRet += '            font: 12px Arial, Helvetica, sans-serif;
	cRet += '			font-weight: bold;
	cRet += '			text-align: center;
	cRet += '			padding: 5px;
	cRet += '        }
	cRet += '		.styleLabel{
	cRet += '			color:#0c2c65;
	cRet += '		}
	cRet += '		.styleValor{
	cRet += '			color:#747474;
	cRet += '		}
	cRet += '        -->
	cRet += '    </style>
	cRet += '</head>
	cRet += '<body>	

	cRet += '    <table class="styleTable" align="center">
	
	cRet += '        <tr align=center>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Empresa </th>	
	cRet += '            <th class="styleCabecalho" width="85" scope="col"> SC Bizagi </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> SC </th>
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Solicitante </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Pedido </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Item </th>	
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Descrição </th>
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Fornecedor </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Emissão </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Comprador </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Aprovador </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Status </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Aprovação </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Chegada </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Status Entrega </th>
	cRet += '            <th class="styleCabecalho" width="150" scope="col"> Follow Up </th>
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Observação </th>	
	
	cRet += '        </tr>
			
Return(cRet)


Static Function fRetItem(aSolCom)
Local cRet := ""
	
	cRet += '        <tr align=center>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_DesEmp] +' </th>
	cRet += '            <th class="styleLinha" width="85" scope="col"> '+ aSolCom[_NumBiz] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_NumSol] +' </th>
	cRet += '            <th class="styleLinha" width="200" scope="col"> '+ aSolCom[_NomSol] +' </th>	
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_NumPed] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_ItePed] +' </th>
	cRet += '            <th class="styleLinha" width="200" scope="col"> '+ aSolCom[_CodPrd] + " - " + aSolCom[_DesPrd] +' </th>
	cRet += '            <th class="styleLinha" width="200" scope="col"> '+ aSolCom[_NomFor] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_DatEmi] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_NomCom] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_NomApr] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_StaApr] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_DatApr] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_DatChe] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_StaEnt] +' </th>
	cRet += '            <th class="styleLinha" width="150" scope="col"> '+ aSolCom[_Follow] +' </th>
	cRet += '            <th class="styleLinha" width="200" scope="col"> '+ aSolCom[_ObsCom] +' </th>		
	cRet += '        </tr>
		
Return(cRet)


Static Function fRetRod()
Local cRet := ""

	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td class="styleRodape" width="60" scope="col" colspan="18">
	cRet += '                E-mail enviado automaticamente pelo sistema Protheus (by BIAF099).
	cRet += '            </td>
	cRet += '        </tr>
	cRet += '	</table>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Static Function fSendMail(cMail, cHtml) 
	If U_BIAEnvMail(,cMail, "Status das Solicitações de Compra", cHtml)
		ConOut("[" + cValToChar(dDataBase) + Space(1) + Time() + "] - BIAF099:fSendMail('"+ cMail +"')")
	
	EndIf
		
Return()


Static Function fUpdEnv(aSolCom)
Local cSQL := ""

	If (aSolCom[_QtdCom] == aSolCom[_QtdEnt] .And. Empty(aSolCom[_Residuo])) .Or. aSolCom[_Residuo] == "S" 			
		
		cSQL := " UPDATE "+ RetFullName("SC1", aSolCom[_CodEmp])
		cSQL += " SET C1_YENVSC = 'S' "
		cSQL += " WHERE R_E_C_N_O_ = " + ValToSQL(aSolCom[_RecNo])
		
		TcSQLExec(cSQL)
		
	EndIf

Return()


Static Function fRetNome(cNome)
Local cRet := ""
Local aNome := {}
Local nCount := 1
Local nLen := 2	
	
	aNome := StrTokArr2(Upper(cNome), Space(1))

	If Len(aNome) > 0
	
		nPos := aScan(aNome, {|x| x $ "DAS/DOS/DA/DO/DE"})
		
		If nPos == 2	
			nLen := 3
		EndIf
		
		For nCount := 1 To nLen
		
			cRet += aNome[nCount] + Space(1)
							
		Next
		
	EndIf

Return(cRet)
