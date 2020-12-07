#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIABC015
@author Barbara Coelho	  
@since 22/07/2020
@version 1.0
@description arquivo de importação com compra de pisos de colaboradores - integração SENIOR
@type function
/*/																								

User Function BIABC015()
	Local x
	Private xViaSched := (Select("SX6")== 0)
	private aPergs := {}
	Private sdtInicial := ""
	Private sdtFinal := ""
	Private sMes := 0
	Private sAno := 0
	

	If (xViaSched)                          
		xv_Emps    := U_BAGtEmpr("01_05")
		cDir := "\P10\BaseFaturamento\"


		For x := 1 to Len(xv_Emps)
			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])                    

			ConOut("HORA: "+TIME()+" - Gerando a listagem de compras de colaboradores Mensal " + xv_Emps[x,1])
			MontaArquivo(xv_Emps[x,1], cDir)

			ConOut("HORA: "+TIME()+" - Fim da geração da listagem de compras de colaboradores Mensal" + xv_Emps[x,1])

			//Finaliza o ambiente criado
			RpcClearEnv()
		Next
	Else
		sdtInicial := ""
		sdtFinal := ""
		
		If !fValidPerg()
			Return
		EndIf
		
		sMes := rtrim(ltrim(substr(MV_PAR01,1,2)))
		sAno := rtrim(ltrim(substr(MV_PAR01,4,4)))
		
		if sMes = '01'
			sMes := '12'
			sAno := rtrim(ltrim(str(val(sAno)-1)))
		else
			sMes := rtrim(ltrim(str(val(sMes)-1)))
			if len(sMes) = 1
				sMes := "0" + rtrim(ltrim(sMes))
			endif
		endif		
		
		if sMes < '01' .or. sMes > '12'
			MsgStop('O mês informado não é válido.')
			return		  
		endif
		
		if sAno < '1900' .or. sAno > ltrim(rtrim(str(Year(Date()))))
			MsgStop('O ano informado não é válido.')
			return		  
		endif
		
		sdtInicial := "01/" + sMes + '/' + sAno
		sdtInicial := FirstDate(CTOD(sdtInicial))	
		sdtFinal := LastDate(sdtInicial)		
		MontaArquivo(cempant, sdtInicial, sdtFinal)
		
		MessageBox('O arquivo foi gerado com sucesso na pasta C:\TEMP\.','Compra de Pisos de Colaboradores', 0)
	EndIf

Return 

Static Function MontaArquivo(cEmpresa,sdtInicial, sdtFinal)

	Local nHandle
	Private cDirTemp := "C:\TEMP\"
	Private cArqTemp := "Compras_Colab_" + STUFF(MV_PAR01, 3, 1, '')
	Private cPathArq := cDirTemp + cArqTemp + ".txt"
	
	cCrLf := Chr(13) + Chr(10)
	
	cSql := "SELECT RK_MAT, " + cCrLf
	cSql += "       CASE LEN(RTRIM(LTRIM(SUBSTRING(CAST (RK_VALORTO AS VARCHAR(9)), CHARINDEX('.', RK_VALORTO)+1,2)))) WHEN 1 THEN" + cCrLf
	cSql += "            REPLACE(CAST (RK_VALORTO AS VARCHAR(9)),'.',',') + '0'" + cCrLf
	cSql += "       ELSE REPLACE(CAST (RK_VALORTO AS VARCHAR(9)),'.',',') " + cCrLf
	cSql += "       END RK_VALORTO, " + cCrLf
	cSql += "       CAST(RK_PARCELA AS VARCHAR(2)) RK_PARCELA," + cCrLf
	cSql += "       SUBSTRING(RK_DTMOVI,7,2)+'/'+SUBSTRING(RK_DTMOVI,5,2)+'/'+SUBSTRING(RK_DTMOVI,1,4) DTFATUR, " + cCrLf
	cSql += "       RK_YNFISCA,'" + cCrLf
	cSql +=         MV_PAR01 + "' COMPET " + cCrLf
	cSql += "  FROM SRA010 SRA WITH (NOLOCK) " + cCrLf
	cSql += " INNER JOIN SRK010 SRK WITH (NOLOCK) " + cCrLf 
	cSql += "	 ON (RK_FILIAL = RA_FILIAL " + cCrLf
	cSql += "	AND RK_MAT = RA_MAT " + cCrLf
	cSql += "	AND RK_PD = '430' " + cCrLf
	cSql += "	AND SRK.D_E_L_E_T_ = '' " + cCrLf
	cSql += "	AND SRA.D_E_L_E_T_ = '') " + cCrLf
	cSql += "	AND RK_STATUS <> 3 " + cCrLf
	cSql += "	AND RK_DTMOVI BETWEEN '"+dtos(sdtInicial)+"' AND '"+dtos(sdtFinal)+"' " + cCrLf
	cSql += " ORDER BY RA_NOME, RK_DTVENC " + cCrLf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'QRY',.F.,.T.)
	dbSelectArea('QRY')
	dbGoTop()
	//ProcRegua(RecCount())
	aStru := ("QRY")->(dbStruct())

	ConOut("BIABC015 - "+cPathArq)

	If FILE(cPathArq)   
		FErase(cPathArq)	
	EndIf

	nHandle := MSFCREATE(cPathArq,0)
	ConOut("BIABC015 - handle "+cvaltochar(nHandle))


	If nHandle == -1 .Or. nHandle == 0
		conout("BIABC015 Erro ao criar arquivo - ferror " + Str(Ferror()))              
		Return
	EndIf 

	If nHandle > 0

		//popula o componente Excel, conforme definição dos campos.
		//aEval(aStru, {|e, nX| fWrite(nHandle, e[1] + If(nX < Len(aStru), ";", "") ) },2 )
		//fWrite(nHandle, cCrLf ) // Pula linha

		While !Eof()
			FWrite(nHandle, 	 ;
			RTRIM(LTRIM(QRY->RK_MAT))		+";"+;
			RTRIM(LTRIM(QRY->RK_VALORTO)) 	+";"+;
			RTRIM(LTRIM(QRY->RK_PARCELA)) 	+";"+;
			RTRIM(LTRIM(QRY->DTFATUR))		+";"+;
			RTRIM(LTRIM(QRY->RK_YNFISCA))	+";"+;
			MV_PAR01 		 	 ;
			)
			fWrite(nHandle, cCrLf ) // Pula linha
			dbSelectArea('QRY')
			dbSkip()
		End 

		FClose(nHandle)
		QRY->(dbCloseArea()) 
	EndIf
Return

Static Function fValidPerg()

	local cLoad	    := "BIABC015"
	local cFileName := RetCodUsr() + "_" + cLoad  
	local lRet		:= .F.

	MV_PAR01 := SPACE(7)
	
	aAdd( aPergs ,{1,"Competência: (MM/AAAA)", MV_PAR01, "", "NAOVAZIO()", '', '.T.', 50, .F.})	

	If ParamBox(aPergs ,"Compra de Pisos de Colaboradores ",,,,,,,,cLoad,.T.,.T.)
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
	EndIf
Return lRet