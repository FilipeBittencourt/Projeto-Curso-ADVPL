#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"

/*/{Protheus.doc} BIA935
@author Wlysses Cerqueira (Facile)
@since 16/07/2019
@project Ticket 11455: Implementar Extratos Bancários em Excel no protheus.
@version 1.0
@description 
@type class
/*/

#DEFINE NPOSBANCO	1
#DEFINE NPOSAGENCIA	2
#DEFINE NPOSCONTA	3
#DEFINE NPOSCONTACT	4
#DEFINE NPOSSALINI	5
#DEFINE NPOSSALATU	6
#DEFINE NPOSADD		7

#DEFINE NPOSV3FIL	1
#DEFINE NPOSV3DSEQ	2
#DEFINE NPOSV3DC	3
#DEFINE NPOSV3DEB	4
#DEFINE NPOSV3CRE	5
#DEFINE NPOSV3VLR	6
#DEFINE NPOSV3HIST	7
#DEFINE NPOSV3TAB	8
#DEFINE NPOSV3RECO	9
#DEFINE NPOSV3USAD	10

#DEFINE NPOSE5FIL	1
#DEFINE NPOSE5DATA	2
#DEFINE NPOSE5REPA	3
#DEFINE NPOSE5TIPO	4
#DEFINE NPOSE5VLR	5
#DEFINE NPOSE5NAT	6
#DEFINE NPOSE5BANC	7
#DEFINE NPOSE5AGEN	8
#DEFINE NPOSE5CONT	9
#DEFINE NPOSE5CHQ	10
#DEFINE NPOSE5HIST	11
#DEFINE NPOSE5NUM	12
#DEFINE NPOSE5PAR	13
#DEFINE NPOSE5CLIF	14
#DEFINE NPOSE5LOJA	15
#DEFINE NPOSE5REC	16
#DEFINE NPOSE5USAD	17
							
Class BIA935 From LongClassName
    	
	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data cFilDe
	Data cFilAte
	
	Data oFWExcel
	Data cDir
	Data cDirTemp
	Data cFile

	Data cBanco
	Data cAgencia
	Data cConta
	
	Data oTable
	Data aSE5
	Data aCV3

	Data aSintContab
	Data aSintFinan
	Data aConta
	
	Data lDisponib
	Data cContaDe
	Data cContaAte
	Data dDataDe
	Data dDataAte
	
	Method New() Constructor
	Method Pergunte()
	Method Processa()
	Method GetConta()
	Method IncRecno(cTab, nRecno, dDataBaixa)
	
	Method SaldoContabil(cConta)
	Method PrintAnalitico()
	Method PrintSintetico()
	 	
EndClass

Method New() Class BIA935

    Local aFields := {}
    
	::cName := "BIA935"
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.
 	
 	::lDisponib := "1"
 	
	::cContaDe := Space(TamSx3("CT1_CONTA")[1])
	::cContaAte := Space(TamSx3("CT1_CONTA")[1])
	::dDataDe := StoD("  /  /  ")
	::dDataAte := StoD("  /  /  ")
	
	::cFilDe := Space(TamSx3("E2_FILIAL")[1])
	::cFilAte := Space(TamSx3("E2_FILIAL")[1])
	
	::oFWExcel	:= FWMsExcel():New()

	::cDir		:= GetSrvProfString("Startpath", "")
	::cDirTemp	:= AllTrim(GetTempPath())
	::cFile		:= "Contabil-" + __cUserID + "-" + dToS(Date()) + "-" + StrTran(Time(), ":", "") + ".xml"
	
	::aSE5 := {}
	::aCV3 := {}
	::aSintContab := {}
	::aSintFinan := {}
	
	::oTable := FWTemporaryTable():New( /*cAlias*/, /*aFields*/)

	aAdd(aFields, {"DATABX"	, "D", 08, 0})
    aAdd(aFields, {"TAB"	, "C", 03, 0})
    aAdd(aFields, {"RECNO"	, "N", 10, 0})
    
    ::oTable:SetFields(aFields)
	
	::oTable:AddIndex("01", {"DATABX"} )
    ::oTable:AddIndex("02", {"TAB"		} )
    ::oTable:AddIndex("03", {"RECNO"	} )
    ::oTable:AddIndex("04", {"RECNO", "TAB"		, "DATABX" } )
    ::oTable:AddIndex("05", {"TAB"	, "RECNO"	, "DATABX" } )

    ::oTable:Create()
    
Return()

Method Processa() Class BIA935
	
	Local nW := 0
	Local cSQL := ""
	Local cQry := ""
	Local nTotReg := 0
	Local nSaldoAtu := 0
	Local nSaldoIni := 0
	Local oMSExcel := Nil

	Private nMoedaBco	:= 1
	
	::aConta := ::GetConta()
			
	For nW := 1 To Len(::aConta)
	
		cQry := GetNextAlias()
			
		cSQL := "SELECT * "
		cSQL += "FROM " + RetSqlName("SE5") + " SE5 "
		cSQL += "WHERE "
		cSQL += "    E5_DTDISPO         >= " + ValToSql(::dDataDe)
		cSQL += "    AND E5_DTDISPO     <= " + ValToSql(::dDataAte)
		cSQL += "    AND E5_BANCO       = " + ValToSql(::aConta[nW][NPOSBANCO])
		cSQL += "    AND E5_AGENCIA     = " + ValToSql(::aConta[nW][NPOSAGENCIA])
		cSQL += "    AND E5_CONTA       = " + ValToSql(::aConta[nW][NPOSCONTA])
		cSQL += "    AND E5_TIPODOC NOT IN ( "
		cSQL += "                              'DC', 'JR', 'MT', 'CM', 'D2', 'J2', 'M2', 'V2', 'C2', 'CP', 'TL', 'BA', 'I2', 'EI' "
		cSQL += "                          ) "
		cSQL += "    AND NOT ( "
		cSQL += "                E5_MOEDA IN ( "
		cSQL += "                                'C1', 'C2', 'C3', 'C4', 'C5', 'CH' "
		cSQL += "                            ) "
		cSQL += "                AND E5_NUMCHEQ = '               ' "
		cSQL += "                AND (E5_TIPODOC NOT IN ( "
		cSQL += "                                           'TR', 'TE' "
		cSQL += "                                       ) "
		cSQL += "                    ) "
		cSQL += "            ) "
		cSQL += "    AND NOT ( "
		cSQL += "                E5_TIPODOC IN ( "
		cSQL += "                                  'TR', 'TE' "
		cSQL += "                              ) "
		cSQL += "                AND "
		cSQL += "                    ( "
		cSQL += "                        ( "
		cSQL += "							E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ' "
		cSQL += "                        ) "
		cSQL += "                        OR ( "
		cSQL += "								E5_DOCUMEN BETWEEN '*                ' AND '*ZZZZZZZZZZZZZZZZ' "
		cSQL += "                           ) "
		cSQL += "                    ) "
		cSQL += "            ) "
		cSQL += "    AND NOT ( "
		cSQL += "                E5_TIPODOC IN ( "
		cSQL += "                                  'TR', 'TE' "
		cSQL += "                              ) "
		cSQL += "                AND E5_NUMERO = '      ' "
		cSQL += "                AND E5_MOEDA NOT IN ( "
		cSQL += "                                        'CC', 'CD', 'CH', 'CO', 'DOC', 'FI', 'R$', 'TB', 'TC', 'VL', 'DO' "
		cSQL += "                                    ) "
		cSQL += "            ) "
		cSQL += "    AND E5_SITUACA     <> 'C' "
		cSQL += "    AND E5_VALOR       <> 0 "
		cSQL += "    AND NOT ( "
		cSQL += "				E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ' "
		cSQL += "            ) "
		cSQL += "    AND SE5.D_E_L_E_T_ = ' ' "
		cSQL += "   ORDER BY E5_DTDISPO " //Thiago Haagensen - Ticket 24548 - Inserido ORDER BY para gerar na sequencia das datas.
		TcQuery cSQL New Alias (cQry)

		(cQry)->(DbGoTop())
		
		While !(cQry)->(Eof())
			
			nPos := aScan(::aSintFinan, {|x| x[1] + x[2] == ::aConta[nW][NPOSCONTACT] + If(::lDisponib, (cQry)->E5_DTDISPO, (cQry)->E5_DATA)})
			
			If nPos > 0
			
				::aSintFinan[nPos][3] += If((cQry)->E5_RECPAG == "R", (cQry)->E5_VALOR, 0)
	
				::aSintFinan[nPos][4] += If((cQry)->E5_RECPAG == "P", (cQry)->E5_VALOR, 0)
				
			Else
			
				aAdd(::aSintFinan, {::aConta[nW][NPOSCONTACT], If(::lDisponib, (cQry)->E5_DTDISPO, (cQry)->E5_DATA), 0, 0, 0, .T.})
				
				nPos := Len(::aSintFinan)
				
				::aSintFinan[nPos][3] += If((cQry)->E5_RECPAG == "R", (cQry)->E5_VALOR, 0)
	
				::aSintFinan[nPos][4] += If((cQry)->E5_RECPAG == "P", (cQry)->E5_VALOR, 0)
					
			EndIf
			
			If AllTrim((cQry)->E5_ORIGEM) == "FINA090" .And. Empty((cQry)->E5_NUMERO)
			
				cQry2 := GetNextAlias()
				
				cSQL2 := " SELECT * "
				cSQL2 += " FROM " + RetSqlName("SE5") + " SE5 "
				cSQL2 += " WHERE E5_FILIAL	= " + ValToSql((cQry)->E5_FILIAL)
				cSQL2 += " AND E5_DTDISPO	= " + ValToSql((cQry)->E5_DTDISPO)
				cSQL2 += " AND E5_ORIGEM 	= " + ValToSql((cQry)->E5_ORIGEM)
				cSQL2 += " AND E5_LOTE 		= " + ValToSql((cQry)->E5_LOTE)
				cSQL2 += " AND E5_BANCO 	= " + ValToSql((cQry)->E5_BANCO)
				cSQL2 += " AND E5_AGENCIA 	= " + ValToSql((cQry)->E5_AGENCIA)
				cSQL2 += " AND E5_CONTA 	= " + ValToSql((cQry)->E5_CONTA)
				cSQL2 += " AND E5_TIPODOC 	= 'BA' "
				cSQL2 += " AND SE5.D_E_L_E_T_ = ' ' "
				cSQL2 += "   ORDER BY E5_DTDISPO " //Thiago Haagensen - Ticket 24548 - Inserido ORDER BY para gerar na sequencia das datas.
				
				TcQuery cSQL2 New Alias (cQry2)
		
				(cQry2)->(DbGoTop())
				
				If (cQry2)->(Eof()) // Significa que os titulos dessa baixa foi estornado, nesse caso inclui o titulo aglutidado principal.
				
					aAdd(::aSE5,;
					{;	
						(cQry)->E5_FILIAL,;
						DTOC(STOD((cQry)->E5_DTDISPO)),;
						(cQry)->E5_RECPAG,;
						(cQry)->E5_TIPO,;
						(cQry)->E5_VALOR,;
						(cQry)->E5_NATUREZ,;
						(cQry)->E5_BANCO,;
						(cQry)->E5_AGENCIA,;
						(cQry)->E5_CONTA,;
						(cQry)->E5_NUMCHEQ,;
						(cQry)->E5_HISTOR,;
						(cQry)->E5_NUMERO,;
						(cQry)->E5_PARCELA,;
						(cQry)->E5_CLIFOR,;
						(cQry)->E5_LOJA,;
						(cQry)->R_E_C_N_O_,;
						.T.;
					})
					
					::IncRecno("SE5", (cQry)->R_E_C_N_O_, STOD((cQry)->E5_DATA))
				
				Else
				
					While !(cQry2)->(Eof())
					
						aAdd(::aSE5,;
						{;	
							(cQry2)->E5_FILIAL,;
							DTOC(STOD((cQry2)->E5_DTDISPO)),;
							(cQry2)->E5_RECPAG,;
							(cQry2)->E5_TIPO,;
							(cQry2)->E5_VALOR,;
							(cQry2)->E5_NATUREZ,;
							(cQry2)->E5_BANCO,;
							(cQry2)->E5_AGENCIA,;
							(cQry2)->E5_CONTA,;
							(cQry2)->E5_NUMCHEQ,;
							(cQry2)->E5_HISTOR,;
							(cQry2)->E5_NUMERO,;
							(cQry2)->E5_PARCELA,;
							(cQry2)->E5_CLIFOR,;
							(cQry2)->E5_LOJA,;
							(cQry2)->R_E_C_N_O_,;
							.T.;
						})
						
						::IncRecno("SE5", (cQry2)->R_E_C_N_O_, STOD((cQry2)->E5_DATA))
						
						(cQry2)->(DBSkip())
					
					EndDo
					
				EndIf
				
				(cQry2)->(DbCloseArea())
				
			Else
			 
				aAdd(::aSE5,;
					{;	
						(cQry)->E5_FILIAL,;
						DTOC(STOD((cQry)->E5_DTDISPO)),;
						(cQry)->E5_RECPAG,;
						(cQry)->E5_TIPO,;
						(cQry)->E5_VALOR,;
						(cQry)->E5_NATUREZ,;
						(cQry)->E5_BANCO,;
						(cQry)->E5_AGENCIA,;
						(cQry)->E5_CONTA,;
						(cQry)->E5_NUMCHEQ,;
						(cQry)->E5_HISTOR,;
						(cQry)->E5_NUMERO,;
						(cQry)->E5_PARCELA,;
						(cQry)->E5_CLIFOR,;
						(cQry)->E5_LOJA,;
						(cQry)->R_E_C_N_O_,;
						.T.;
					})
					
					::IncRecno("SE5", (cQry)->R_E_C_N_O_, STOD((cQry)->E5_DATA))
			
			EndIf
			
			(cQry)->(DBSkip())
				
		EndDo
			
		(cQry)->(DbCloseArea())
		
		cQry := GetNextAlias()
		
		cSQL := "SELECT * "
		cSQL += "FROM " + RetSqlName("CV3") + " A (NOLOCK) "
		cSQL += "WHERE "
		cSQL += "    A.CV3_DTSEQ BETWEEN " + ValToSql(::dDataDe) + " AND " + ValToSql(::dDataAte)
		//cSQL += "    AND A.CV3_TABORI = 'SE5' "
		cSQL += "	 AND ( A.CV3_DEBITO IN (" + ValToSql(::aConta[nW][NPOSCONTACT]) + "," + ValToSql(::aConta[nW][NPOSCONTACT]) + ") OR A.CV3_CREDIT IN (" + ValToSql(::aConta[nW][NPOSCONTACT]) + "," + ValToSql(::aConta[nW][NPOSCONTACT]) + ") ) "
		cSQL += "    AND A.D_E_L_E_T_ = '' "
		cSQL += "    AND NOT EXISTS "
		cSQL += "    ( "
		cSQL += "    	SELECT NULL "
		cSQL += "    	FROM " + RetSqlName("CT2") + " CT2 (NOLOCK) "
		cSQL += "    	WHERE CT2.D_E_L_E_T_ = '*' "
		cSQL += "    	AND CV3_RECDES = CT2.R_E_C_N_O_ "			
		cSQL += "    ) "
		
		cSQL += " UNION "
		
		cSQL += "SELECT * "
		cSQL += "FROM " + RetSqlName("CV3") + " A WITH (NOLOCK, INDEX(CV3"+cEmpAnt+"01)) "
		cSQL += "WHERE "
		cSQL += "    NOT EXISTS "
		cSQL += "    ( "
		cSQL += "    	SELECT NULL "
		cSQL += "    	FROM " + RetSqlName("CT2") + " CT2 (NOLOCK) "
		cSQL += "    	WHERE CT2.D_E_L_E_T_ = '*' "
		cSQL += "    	AND CV3_RECDES = CT2.R_E_C_N_O_ "			
		cSQL += "    ) "
		
		cSQL += "	AND EXISTS 	( "
		cSQL += "				SELECT * FROM " + ::oTable:GetRealName()
		cSQL += "				WHERE CV3_FILIAL 	= " + ValToSql(xFilial("CV3"))
		cSQL += "				AND DATABX 			= CV3_DTSEQ "
		cSQL += "				AND RECNO 			= CV3_RECORI "
		cSQL += "				AND TAB 			= CV3_TABORI "
		cSQL += "    		) "
		cSQL += "	AND ( A.CV3_DEBITO IN (" + ValToSql(::aConta[nW][NPOSCONTACT]) + "," + ValToSql(::aConta[nW][NPOSCONTACT]) + ") OR A.CV3_CREDIT IN (" + ValToSql(::aConta[nW][NPOSCONTACT]) + "," + ValToSql(::aConta[nW][NPOSCONTACT]) + ") ) "
		cSQL += "	AND A.D_E_L_E_T_ = '' "
		cSQL += " ORDER BY CV3_DTSEQ "	//Thiago Haagensen - Ticket 24548 - Inserido ORDER BY para gerar na sequencia das datas.
		TcQuery cSQL New Alias (cQry)
			
		Count To nTotReg
			
		(cQry)->(DbGoTop())
			
		ProcRegua(nTotReg * 3)
			
		While !(cQry)->(Eof())

			aAdd(::aCV3,;
				{;	
					(cQry)->CV3_FILIAL,;
					DTOC(STOD((cQry)->CV3_DTSEQ)),;
					(cQry)->CV3_DC,;
					(cQry)->CV3_DEBITO,;
					(cQry)->CV3_CREDIT,;
					(cQry)->CV3_VLR01,;
					(cQry)->CV3_HIST,;
					(cQry)->CV3_TABORI,;
					Val((cQry)->CV3_RECORI),;
					.T.;
				})
							
			(cQry)->(DBSkip())
				
		EndDo
			
		(cQry)->(DbCloseArea())
		
		::SaldoContabil(::aConta[nW][NPOSCONTACT])
	
	Next nW
	
	::oTable:Delete()

	If Len(::aConta) > 0
		
		::PrintAnalitico()
		
		::PrintSintetico()
		
		::oFWExcel:Activate()
		::oFWExcel:GetXMLFile(::cFile)
		::oFWExcel:DeActivate()

		If Right(::cDir,1) <> "\"
				
			::cDir := ::cDir + "\"
				
		EndIf
					
		If CpyS2T(::cDir + ::cFile, ::cDirTemp, .T.)
				
			If ApOleClient('MsExcel')
				
				oMSExcel := MsExcel():New()
				oMSExcel:WorkBooks:Close()
				oMSExcel:WorkBooks:Open(::cDirTemp + ::cFile)
				oMSExcel:SetVisible(.T.)
				oMSExcel:Destroy()
					
			EndIf
		
		Else
			
			MsgInfo("Arquivo não copiado para a pasta temporária do usuário!")
			
		EndIf

	Else

		MsgInfo("Não foi encontrado movimentação bancária para conta contábil informada!")

	EndIf
	
Return()

Method GetConta() Class BIA935

	Local aConta := {}
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local nSaldoAtu := 0
	Local nSaldoIni := 0
	Local aPerg := {}
	
	cSQL += " SELECT * "
	cSQL += " FROM " + RetSqlName("SA6") + " A (NOLOCK) "
	cSQL += " WHERE "
	cSQL += "    A.A6_CONTA BETWEEN " + ValToSql(::cContaDe) + " AND " + ValToSql(::cContaAte)
	cSQL += "    AND A.A6_BLOCKED <> '1' "
	cSQL += "    AND A.D_E_L_E_T_ = '' "
		
	TcQuery cSQL New Alias (cQry)
				
	(cQry)->(DbGoTop())

	DBSelectArea("SA6")
	SA6->(DBSetOrder(1)) // A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON, R_E_C_N_O_, D_E_L_E_T_
		
	While !(cQry)->(Eof())

		nSaldoAtu := 0
			
		nSaldoIni := 0
			
		If SA6->(DBSeek(xFilial("SA6") + (cQry)->A6_COD + (cQry)->A6_AGENCIA + (cQry)->A6_NUMCON))
		
			Pergunte("FIN470", .F.,,,,, @aPerg)
	
			MV_PAR01 := SA6->A6_COD
			MV_PAR02 := SA6->A6_AGENCIA 
			MV_PAR03 := SA6->A6_NUMCON
			MV_PAR04 := ::dDataDe
			MV_PAR05 := ::dDataAte
			
			__SaveParam("FIN470", aPerg)

			dbSelectArea("SE8")
			dbSetOrder(1)

			dbSeek(xFilial("SE8")+mv_par01+mv_par02+mv_par03+Dtos(mv_par04),.T.)   // filial + banco + agencia + conta
			dbSkip(-1)
		
			IF E8_FILIAL != xFilial("SE8") .Or. E8_BANCO!=mv_par01 .or. E8_AGENCIA!=mv_par02 .or. E8_CONTA!=mv_par03 .or. BOF() .or. EOF()
			
				nSaldoAtu := 0
			
				nSaldoIni := 0
			
			Else
				
				nSaldoAtu := SE8->E8_SALATUA
				
				nSaldoIni := SE8->E8_SALATUA
				
			Endif	
					
			//StaticCall(FINR470, CalcSldIni, @nSaldoAtu, @nSaldoIni)
		
		EndIf
				
		aAdd(aConta,;
			{;
				(cQry)->A6_COD,;
				(cQry)->A6_AGENCIA,;
				(cQry)->A6_NUMCON,;
				(cQry)->A6_CONTA,;
				nSaldoIni,;
				nSaldoAtu,;
				.T.;
			})

		(cQry)->(DBSkip())
				
	EndDo
			
	(cQry)->(DbCloseArea())

Return(aConta)

Method IncRecno(cTab, nRecno, dDataBaixa) Class BIA935

	Local cAlias 	 := ::oTable:GetAlias()

    (cAlias)->(DBAppend())
    (cAlias)->DATABX	:= dDataBaixa
    (cAlias)->RECNO := nRecno
    (cAlias)->TAB 	:= cTab
    (cAlias)->(DBCommit())

Return()

Method SaldoContabil(cConta) Class BIA935

	Local cContaIni		:= ""
	Local cContaFIm		:= ""
	Local dDataIni		:= ""
	Local dDataFim		:= ""
	Local cMoeda		:= ""
	Local cSaldo		:= ""
	Local cCustoIni		:= ""
	Local cCustoFim		:= ""
	Local cItemIni		:= ""
	Local cItemFim		:= ""
	Local cCLVLIni		:= ""
	Local cCLVLFim		:= ""

	Local cFiltro		:= ""
	Local lAnalitico	:= ""
	Local lNoMov		:= ""
	Local lSldAnt		:= ""
	Local lJunta		:= ""
	Local lPrintZero	:= ""
	Local aSetOfBook 	:= {}

	Local lSldAntCta	:= .F.
	Local lSldAntCC		:= .F.
	Local lSldAntIt  	:= .F.
	Local lSldAntCv  	:= .F.
	Local lProcSld      := .F.
	Local lTodasFil 	:= .T.
	Local aSelFil		:= If(IsBlind(), FWAllFilial(), AdmGetFil(@lTodasFil))
	Local aPerg 		:= {}

	Local cSepara1		:= ""	
	Local cMascara1 	:= ""
	Local nVlrDeb		:= 0
	Local nVlrCrd		:= 0
	Local nTotDeb		:= 0
	Local nTotCrd		:= 0
	Local nTotGerDeb	:= 0
	Local nTotGerCrd	:= 0
	
	Default cConta		:= ""
		
	Private cArqTmp		:= GetNextAlias()
	
	SetFunName("CTBR400")
		
	Pergunte("CTR400", .F.,,,,, @aPerg)

	MV_PAR01	:= cConta
	MV_PAR02	:= cConta
	MV_PAR03	:= ::dDataDe
	MV_PAR04	:= ::dDataAte
	MV_PAR05	:= "01"
	MV_PAR06	:= "1"
	MV_PAR07	:= "001"
	MV_PAR08	:= 3 //[1=Analitico;2=Resumido;3=Sintetico]
	MV_PAR09	:= 2 //[1=Sim;2=Nao;3=Nao c/saldo anterior]
	MV_PAR10	:= 1
	MV_PAR11	:= 1
	MV_PAR12	:= 1
	
	MV_PAR13	:= "         "
	MV_PAR14	:= "ZZZZZZZZZ"
	MV_PAR15	:= 1
	MV_PAR16	:= "         "
	MV_PAR17	:= "ZZZZZZZZZ"
	MV_PAR18	:= 1
	MV_PAR19	:= "         "
	MV_PAR20	:= "ZZZZZZZZZ"
	
	cContaIni	:= MV_PAR01 // da conta
	cContaFIm	:= MV_PAR02 // ate a conta
	dDataIni	:= MV_PAR03 // da data
	dDataFim	:= MV_PAR04 // Ate a data
	cMoeda		:= MV_PAR05 // Moeda
	cSaldo		:= MV_PAR06 // Saldos
	lAnalitico	:= If(MV_PAR08==1,.T.,.F.)
	lNoMov		:= If(MV_PAR09==1,.T.,.F.) // Imprime conta sem movimento?
	lSldAnt		:= If(MV_PAR09==3,.T.,.F.) // Imprime conta sem movimento?
	lJunta		:= If(MV_PAR10==1,.T.,.F.) // Junta Contas com mesmo C.Custo?
	cCustoIni	:= MV_PAR13 // Do Centro de Custo
	cCustoFim	:= MV_PAR14 // At‚ o Centro de Custo
	cItemIni	:= MV_PAR16 // Do Item
	cItemFim	:= MV_PAR17 // Ate Item
	cCLVLIni	:= MV_PAR19 // Imprime Classe de Valor?
	cCLVLFim	:= MV_PAR20 // Ate a Classe de Valor
	lPrintZero	:= If(MV_PAR30==1,.T.,.F.) // Imprime valor 0.00
	lSldAntCta	:= If(MV_PAR33 == 1, .T.,.F.)
	lSldAntCC	:= If(MV_PAR33 == 2, .T.,.F.)
	lSldAntIt  	:= If(MV_PAR33 == 3, .T.,.F.)
	lSldAntCv  	:= If(MV_PAR33 == 4, .T.,.F.)
						   
	cFiltro		:= ""
				
	aSetOfBook 	:= CTBSetOf(MV_PAR07)
	
	// Mascara da Conta
	If Empty(aSetOfBook[2])
		cMascara1 := GetMv("MV_MASCARA")
	Else
		cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
	EndIf
	
	__SaveParam("CTR400", aPerg)
	
	cArqTmp := CTBGerRaz(,,,,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
						cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
						aSetOfBook,lNoMov,cSaldo,lJunta,"1",lAnalitico,,,cFiltro,lSldAnt,aSelFil, .T.)

	dbSelectArea("cArqTmp")
	dbGoTop()

	While cArqTmp->(!Eof())

		If lSldAntCC
			aSaldo    := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
			aSaldoAnt := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
		ElseIf lSldAntIt
			aSaldo    := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
			aSaldoAnt := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
		ElseIf lSldAntCv
			aSaldo    := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
			aSaldoAnt := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
		Else
		
			If lProcSld  // se existe parametro MV_CTBRAZD com .t. e conseguiu criar procedure
			
				aRet   := {}
				aRet   := TcSpExec(cTmpProc, cFilAnt, "CQ1",cArqTmp->CONTA," "," ", " ",cSaldo,cMoeda, Dtos(cArqTmp->DATAL))
				
				If Empty(aRet)
					aSaldo 		:= SaldoCT7Fil(cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,,,,aSelFil,,lTodasFil)
				Else
					aSaldo    := { aRet[1], aRet[2], aRet[3], aRet[4], aRet[5], aRet[6], aRet[7],aRet[8]}
				EndIf

				aRet   := {}
				aRet   := TcSpExec(cTmpProc, cFilAnt, "CQ1",cArqTmp->CONTA," "," ", " ",cSaldo,cMoeda, Dtos(dDataIni))
				
				If Empty(aRet)
					aSaldoAnt 		:= SaldoCT7Fil(cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,,,,aSelFil,,lTodasFil)
				Else
					aSaldoAnt    := { aRet[1], aRet[2], aRet[3], aRet[4], aRet[5], aRet[6], aRet[7],aRet[8]}
				EndIf
				
			Else
			
				aSaldo 	:= SaldoCT7Fil(cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,,,,aSelFil,,lTodasFil)
				aSaldoAnt	:= SaldoCT7Fil(cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,"CTBR400",,,aSelFil,,lTodasFil)
			EndIf
			
		EndIf
		
		If StaticCall(CTBR400, f180Fil, lNoMov,aSaldo,dDataIni,dDataFim) //f180Fil(lNoMov,aSaldo,dDataIni,dDataFim)
			
			dbSkip()
			
			Loop
			
		EndIf

		nSaldoAtu := aSaldoAnt[6]

		dbSelectArea("cArqTmp")
		
		cContaAnt := cArqTmp->CONTA
		
		dDataAnt := CTOD("  /  /  ")

		Do While cArqTmp->(!Eof() .And. CONTA == cContaAnt )

			If dDataAnt <> cArqTmp->DATAL

				dDataAnt := cArqTmp->DATAL
				
			EndIf

			If MV_PAR08 < 3 //Se for relatorio analitico ou resumido


			Else      // -- Se for sintetico

				dbSelectArea("cArqTmp")

				While dDataAnt == cArqTmp->DATAL .And. cContaAnt == cArqTmp->CONTA
				
					nVlrDeb	+= cArqTmp->LANCDEB
					nVlrCrd	+= cArqTmp->LANCCRD
					nTotGerDeb	+= cArqTmp->LANCDEB
					nTotGerCrd	+= cArqTmp->LANCCRD
					
					dbSkip()
					
				EndDo

				nPos := aScan(::aSintContab, {|x| x[1] + x[2] == cContaAnt + DTOS(dDataAnt)})
				
				If nPos > 0
				
					::aSintContab[nPos][3] += nVlrDeb
				
					::aSintContab[nPos][4] += nVlrCrd
					
					::aSintContab[nPos][5] += nSaldoAtu + nVlrCrd - nVlrDeb
					
				Else
				
					aAdd(::aSintContab, {cContaAnt, DTOS(dDataAnt), 0, 0, 0, .T.})
					
					nPos := Len(::aSintContab)
					
					::aSintContab[nPos][3] += nVlrDeb
					
					::aSintContab[nPos][4] += nVlrCrd			
					
					::aSintContab[nPos][5] += nSaldoAtu + nVlrCrd - nVlrDeb
					
				EndIf
		
				nSaldoAtu	:= nSaldoAtu + nVlrCrd - nVlrDeb

				nSldTransp := nSaldoAtu // Valor a Transportar

				nTotDeb	+= nVlrDeb
				nTotCrd	+= nVlrCrd
				
				nVlrDeb	:= 0
				nVlrCrd	:= 0
				
			EndIf

		EndDo

       	nSldTransp  := 0
		nSaldoAtu   := 0
		
		nTotDeb	    := 0
		nTotCrd	    := 0

	EndDo

Return()

Method PrintAnalitico() Class BIA935

	Local cSheet	:= ""
	Local cTitSheet	:= ""
	Local cSQL 		:= ""
	Local cQry 		:= ""
	Local cTab		:= ""
	Local aTotal 	:= {} 
	Local nW 		:= 0
	Local nPosCV3 	:= 0
	Local nPosX 	:= 0
		
	aAdd(aTotal, {"TOTAL CREDITO"	, 0})
	aAdd(aTotal, {"TOTAL DEBITO"	, 0})
	aAdd(aTotal, {"TOTAL ENTRADA"	, 0})
	aAdd(aTotal, {"TOTAL SAÍDA"		, 0})
		
	For nW := 1 To Len(::aConta)
		
		//cSheet := AllTrim(::aConta[nW][NPOSCONTACT]) + "_ANALITICO" 
		cSheet := AllTrim(::aConta[nW][NPOSCONTACT]) + "_ANALITICO_" + AllTrim(::aConta[nW][NPOSCONTA]) //Ticket 26904
		cTitSheet := "Extrato Bancário X Contabilização [Analitico] - Conta: " + AllTrim(::aConta[nW][NPOSCONTACT])
		
		::oFWExcel:AddWorkSheet(cSheet)
		
		::oFWExcel:AddTable(cSheet, cTitSheet)
		
		//4 - Alinhamento da coluna ( 1-Left	,2-Center,3-Right )	 
		//5 - Codigo de formatação  ( 1-General	,2-Number,3-Monetário,4-DateTime )

		::oFWExcel:AddColumn(cSheet, cTitSheet, "FILIAL"	, 1)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "DATA"		, 1)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "DC"		, 1)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "DEBITO"	, 2)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "CREDITO"	, 2)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "VALOR"		, 3, 2)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "HISTORICO"	, 1)

		::oFWExcel:AddColumn(cSheet, cTitSheet, "TAB"		, 1)

		::oFWExcel:AddColumn(cSheet, cTitSheet, "FILIAL"	, 1)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "DATA"		, 1)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "MOV"		, 1)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "TIPO"		, 1)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "VALOR"		, 3, 2)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "SALDO"		, 3, 2)
						
		::aConta[nW][NPOSADD] := .F.
	
	Next nW
	
	nPosContab := 0
	
	For nW := 1 To Len(::aSE5)
					
		nPosCV3 := aScan(::aCV3, {|x| x[NPOSV3USAD] .And. x[NPOSV3TAB] == "SE5" .And. x[NPOSV3RECO] == ::aSE5[nW][NPOSE5REC]})
		
		nPos := aScan(::aConta, {|x| x[NPOSBANCO] + x[NPOSAGENCIA] + x[NPOSCONTA] == ::aSE5[nW][NPOSE5BANC] + ::aSE5[nW][NPOSE5AGEN] + ::aSE5[nW][NPOSE5CONT]})
		
		aTotal[3][2] += If(::aSE5[nW][NPOSE5REPA] == "R", ::aSE5[nW][NPOSE5VLR], 0)
		
		aTotal[4][2] += If(::aSE5[nW][NPOSE5REPA] == "P", ::aSE5[nW][NPOSE5VLR], 0)
		
		If nPosCV3 > 0
		
			::aCV3[nPosCV3][NPOSV3USAD] := .F.
			
			nPosX := aScan(::aConta, {|x| x[NPOSCONTACT] == ::aCV3[nPosCV3][NPOSV3CRE]})
			
			If nPosX > 0
			
				aTotal[1][2] += ::aCV3[nPosCV3][NPOSV3VLR]
			
			EndIf

			nPosX := aScan(::aConta, {|x| x[NPOSCONTACT] == ::aCV3[nPosCV3][NPOSV3DEB]})
			
			If nPosX > 0
			
				aTotal[2][2] += ::aCV3[nPosCV3][NPOSV3VLR]
			
			EndIf
		
		Else // Caso seja RA / PA

			cQry := GetNextAlias()
			
			cTab := If(::aSE5[nW][NPOSE5REPA] == "P", "SE2", "SE1")
			
			cSQL := "SELECT R_E_C_N_O_ AS RECNO "
			cSQL += "FROM " + RetSqlName(cTab) + " A ( NOLOCK ) "
			cSQL += "WHERE EXISTS "
			cSQL += "( "
			cSQL += "	SELECT * "
			cSQL += "	FROM " + RetSqlName("SE5") + " SE5 "
			cSQL += "	WHERE R_E_C_N_O_   = " + ValToSql(cValToChar(::aSE5[nW][NPOSE5REC]))
			cSQL += "	AND SE5.E5_FILIAL  = " + If(cTab == "SE2", "A.E2_FILIAL" , "A.E1_FILIAL")
			cSQL += "	AND SE5.E5_NUMERO  = " + If(cTab == "SE2", "A.E2_NUM"	 , "A.E1_NUM")
			cSQL += "	AND SE5.E5_PREFIXO = " + If(cTab == "SE2", "A.E2_PREFIXO", "A.E1_PREFIXO")
			cSQL += "	AND SE5.E5_PARCELA = " + If(cTab == "SE2", "A.E2_PARCELA", "A.E1_PARCELA")
			cSQL += "	AND SE5.E5_TIPO    = " + If(cTab == "SE2", "A.E2_TIPO"	 , "A.E1_TIPO")
			cSQL += "	AND SE5.E5_CLIFOR  = " + If(cTab == "SE2", "A.E2_FORNECE", "A.E1_CLIENTE")
			cSQL += "	AND SE5.E5_LOJA    = " + If(cTab == "SE2", "A.E2_LOJA"	 , "A.E1_LOJA")
			cSQL += "	AND SE5.D_E_L_E_T_ = '' "
			cSQL += ") "
			cSQL += " AND A.D_E_L_E_T_ = '' "
		
			TcQuery cSQL New Alias (cQry)
	
			(cQry)->(DbGoTop())
			
			nRecnoSE2 := 0
			
			While !(cQry)->(Eof())
			
				nRecnoSE2 := (cQry)->RECNO
			
				(cQry)->(DBSkip())
			
			EndDo
			
			(cQry)->(DbCloseArea())
			
			nPosCV3 := 0
			
			If nRecnoSE2 > 0
			
				nPosCV3 := aScan(::aCV3, {|x| x[NPOSV3USAD] .And. x[NPOSV3TAB] $ "SE2|SE1" .And. x[NPOSV3RECO] == nRecnoSE2})
				
				If nPosCV3 > 0
		
					::aCV3[nPosCV3][NPOSV3USAD] := .F.

					nPosX := aScan(::aConta, {|x| x[NPOSCONTACT] == ::aCV3[nPosCV3][NPOSV3CRE]})
					
					If nPosX > 0
					
						aTotal[1][2] += ::aCV3[nPosCV3][NPOSV3VLR]
					
					EndIf
		
					nPosX := aScan(::aConta, {|x| x[NPOSCONTACT] == ::aCV3[nPosCV3][NPOSV3DEB]})
					
					If nPosX > 0
					
						aTotal[2][2] += ::aCV3[nPosCV3][NPOSV3VLR]
					
					EndIf
						
				EndIf
				
			Else // Caso seja a data da disponibilidade do SE5 nao estar na data informada pelo usuário
			
				Conout("Verificar: ::aSE5" + cVALTOCHAR(nW))
				
			EndIf
		
		EndIf
		
		Conout("Verificar: ::aSE5" + cVALTOCHAR(nW) + " - RECNO: " + CVALTOCHAR(::aSE5[nW][NPOSE5REC]))
		
		::oFWExcel:AddRow(cSheet, cTitSheet,;
		{;	
			If(nPosCV3 > 0, ::aCV3[nPosCV3][NPOSV3FIL]	, ""),;
			If(nPosCV3 > 0, ::aCV3[nPosCV3][NPOSV3DSEQ]	, ""),;
			If(nPosCV3 > 0, ::aCV3[nPosCV3][NPOSV3DC]	, ""),;
			If(nPosCV3 > 0, ::aCV3[nPosCV3][NPOSV3DEB]	, ""),;
			If(nPosCV3 > 0, ::aCV3[nPosCV3][NPOSV3CRE]	, ""),;
			If(nPosCV3 > 0, ::aCV3[nPosCV3][NPOSV3VLR]	, ""),;
			If(nPosCV3 > 0, ::aCV3[nPosCV3][NPOSV3HIST]	, ""),;
			If(nPosCV3 > 0, ::aCV3[nPosCV3][NPOSV3TAB]	, ""),;
			::aSE5[nW][NPOSE5FIL],;
			::aSE5[nW][NPOSE5DATA],;
			::aSE5[nW][NPOSE5REPA],;
			::aSE5[nW][NPOSE5TIPO],;
			::aSE5[nW][NPOSE5VLR],;
			::aConta[nPos][NPOSSALATU] += (::aSE5[nW][NPOSE5VLR] * If(::aSE5[nW][NPOSE5REPA] == "P", -1, 1));
		})
	
	Next nW
	
	For nW := 1 To Len(::aCV3)

		If ::aCV3[nW][NPOSV3USAD]

			nPos := aScan(::aConta, {|x| x[NPOSCONTACT] == ::aCV3[nW][NPOSV3CRE]})
			
			If nPos > 0
			
				aTotal[1][2] += ::aCV3[nW][NPOSV3VLR]
			
			EndIf

			nPos := aScan(::aConta, {|x| x[NPOSCONTACT] == ::aCV3[nW][NPOSV3DEB]})
			
			If nPos > 0
			
				aTotal[2][2] += ::aCV3[nW][NPOSV3VLR]
			
			EndIf
			
			::aCV3[nW][NPOSV3USAD] := .F.
			
			::oFWExcel:AddRow(cSheet, cTitSheet,;
			{;	
				::aCV3[nW][NPOSV3FIL]	,;
				::aCV3[nW][NPOSV3DSEQ]	,;
				::aCV3[nW][NPOSV3DC]	,;
				::aCV3[nW][NPOSV3DEB]	,;
				::aCV3[nW][NPOSV3CRE]	,;
				::aCV3[nW][NPOSV3VLR]	,;
				::aCV3[nW][NPOSV3HIST]	,;
				::aCV3[nW][NPOSV3TAB]	,;
				"",;
				"",;
				"",;
				"",;
				0,;
				0;
			})
		
		EndIf
	
	Next nW
	
	For nW := 1 To Len(aTotal)

		::oFWExcel:AddRow(cSheet, cTitSheet,;
		{;	
			""	,;
			""	,;
			""	,;
			""	,;
			aTotal[nW][1],;
			aTotal[nW][2],;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			0,;
			0;
		})
	
	Next nW
	
Return()

Method PrintSintetico() Class BIA935

	Local cSheet	:= ""
	Local cTitSheet	:= ""
	Local cSQL 		:= ""
	Local cQry 		:= ""
	Local aTotal 	:= {} 
	Local nW 		:= 0
	Local nPosCV3 	:= 0
	Local nPosX 	:= 0
		
	For nW := 1 To Len(::aConta)
		
		//cSheet := AllTrim(::aConta[nW][NPOSCONTACT]) + "_SINTETICO"
		cSheet := AllTrim(::aConta[nW][NPOSCONTACT]) + "_SINTETICO_" + AllTrim(::aConta[nW][NPOSCONTA]) //Ticket 26904
		cTitSheet := "Extrato Bancário X Contabilização [Sintetico] - Conta: " + AllTrim(::aConta[nW][NPOSCONTACT])
		
		::oFWExcel:AddWorkSheet(cSheet)
		
		::oFWExcel:AddTable(cSheet, cTitSheet)
		
		//4 - Alinhamento da coluna ( 1-Left	,2-Center,3-Right )	 
		//5 - Codigo de formatação  ( 1-General	,2-Number,3-Monetário,4-DateTime )

		::oFWExcel:AddColumn(cSheet, cTitSheet, "CONTA"		, 1)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "DATA"		, 1)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "DEBITO"	, 3, 2)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "CREDITO"	, 3, 2)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "SALDO"		, 3, 2)
		
		::oFWExcel:AddColumn(cSheet, cTitSheet, "  "		, 1)

		::oFWExcel:AddColumn(cSheet, cTitSheet, "CONTA"		, 1)
		::oFWExcel:AddColumn(cSheet, cTitSheet, If(::lDisponib, "DT DISPO", "DT BAIXA"), 1)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "ENTRADA"	, 3, 2)
		::oFWExcel:AddColumn(cSheet, cTitSheet, "SAIDA"		, 3, 2)
						
		::aConta[nW][NPOSADD] := .F.
	
	Next nW
	
	nPosContab := 0
	
	//aAdd(::aSintFinan, {::aConta[nW][NPOSCONTACT], (cQry)->E5_DTDISPO, 0, 0, 0, .F.})
	
	For nW := 1 To Len(::aSintContab)
					
		nPosContab := aScan(::aSintFinan, {|x| x[6] .And. x[1] + x[2] == ::aSintContab[nW][1] + ::aSintContab[nW][2]})
		
		If nPosContab > 0
		
			::aSintFinan[nPosContab][6] := .F.
			
		EndIf
		
		::oFWExcel:AddRow(cSheet, cTitSheet,;
		{;	
			::aSintContab[nW][1],;
			DTOC(STOD(::aSintContab[nW][2])),;
			::aSintContab[nW][3],;
			::aSintContab[nW][4],;
			::aSintContab[nW][5],;
			If(::aSintContab[nW][5] < 0, "D", "C"),;
			If(nPosContab > 0, ::aSintFinan[nPosContab][1]	, ""),;
			If(nPosContab > 0, DTOC(STOD(::aSintFinan[nPosContab][2])), ""),;
			If(nPosContab > 0, ::aSintFinan[nPosContab][3]	, ""),;
			If(nPosContab > 0, ::aSintFinan[nPosContab][4]	, "");
		})
	
	Next nW
	
	For nW := 1 To Len(::aSintFinan)

		If ::aSintFinan[nW][6]
			
			::aSintFinan[nW][6] := .F.
			
			::oFWExcel:AddRow(cSheet, cTitSheet,;
			{;	
				"",;
				"",;
				"",;
				"",;
				0,;
				"",;
				::aSintFinan[nW][1]	,;
				DTOC(STOD(::aSintFinan[nW][2])),;
				::aSintFinan[nW][3]	,;
				::aSintFinan[nW][4];
			})
		
		EndIf
	
	Next nW

Return()

Method Pergunte() Class BIA935

	Local lRet := .F.
	Local nTam := 0
	
	::bConfirm := {|| .T. }
	
	::aParam := {}
	
	::aParRet := {}
	
	aAdd(::aParam, {1, "Conta de"		, ::cContaDe	, "@!", ".T.","CT1"	,".T.",,.F.})
	aAdd(::aParam, {1, "Conta ate"		, ::cContaAte	, "@!", ".T.","CT1"	,".T.",,.F.})

	aAdd(::aParam, {1, "Data de"		, ::dDataDe		, "@!", ".T.",		,".T.",,.F.})
	aAdd(::aParam, {1, "Data ate"		, ::dDataAte	, "@!", ".T.",		,".T.",,.F.})
	
	aAdd(::aParam, {2, "Aglutina data disponib.", ::lDisponib, {"1=Sim", "2=Não"}, 60, ".T.", .F.})
		
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
		
		nTam++
		
		::cContaDe	    := ::aParRet[nTam++]
		::cContaAte     := ::aParRet[nTam++]
		::dDataDe 	    := ::aParRet[nTam++]
		::dDataAte		:= ::aParRet[nTam++]
		
		::lDisponib	:= ::aParRet[nTam++]
					
		::lDisponib := ::lDisponib == "1"
								
	EndIf
	
Return(lRet)

User Function BIA935()
	
	Local oObj := Nil
	Local lJob := !(Select("SX2") > 0)

	Private cTitulo := "Contabilizacao X Movimento bancário"
	
	If lJob
			
		RpcSetEnv("07", "01")
		
	EndIf

	oObj := BIA935():New()
	
	If oObj:Pergunte()
	
		oObj:Processa()

	EndIf
						
	If lJob
	
		RpcClearEnv()
	
	EndIf

Return()
