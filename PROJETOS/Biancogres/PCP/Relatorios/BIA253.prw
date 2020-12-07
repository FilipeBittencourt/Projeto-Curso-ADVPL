#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA253
@author Marcos Alberto Soprani
@since 13/07/11
@version 1.0
@description Relatório Plano Mestre de Produção (Programação) 
@obs ......
@type function
/*/

User Function BIA253()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Private aPergs	:=	{}
	Private aDados	:=	{}
	Private aLinhas	:=	{}

	cHInicio := Time()
	fPerg := "BIA253"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	//ValidPerg()
	If !ValidPerg()
		Return
	EndIf

	aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
	fCabec   := "Programação de Produção"

	wnPag    := 0
	nRow1    := 0

	oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
	oPrint:SetLandscape()
	oPrint:SetPaperSize(09)
	oPrint:Setup()

	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Armazenando....   Tempo: "+cTempo)

	A0001 := " SELECT C2_LINHA,
	A0001 += "        C2_PRIOR,
	A0001 += "        C2_NUM+C2_ITEM+C2_SEQUEN NUMOP,
	A0001 += "        ISNULL(ZZ6_DESC, ' ') ZZ6_DESC,
	
	//Alteração - Gabriel 2018-03-26 - a pedido de Marcos para incluir Embalagem e Pallet
	A0001 +=	"	  ISNULL((
	A0001 +=	"		SELECT TOP 1 SD4.D4_COD
	A0001 +=	"		FROM "+RetSqlName("SD4")+" SD4
	A0001 +=	"		JOIN "+RetSqlName("SB1")+" SB1EMB ON SD4.D4_COD = SB1EMB.B1_COD
	A0001 +=	"			AND SB1EMB.D_E_L_E_T_ = ''
	A0001 +=	"			AND SB1EMB.B1_GRUPO = '104A'
	A0001 +=	"		WHERE SD4.D4_FILIAL = SC2.C2_FILIAL
	A0001 +=	"			AND SD4.D4_OP = SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN
	A0001 +=	"			AND SD4.D_E_L_E_T_ = ''
	A0001 +=	"		), '') EMBALAG,
	A0001 +=	"	 ISNULL((
	A0001 +=	"		SELECT TOP 1 SD4.D4_COD
	A0001 +=	"		FROM "+RetSqlName("SD4")+" SD4
	A0001 +=	"		JOIN "+RetSqlName("SB1")+" SB1PALLET ON SD4.D4_COD = SB1PALLET.B1_COD
	A0001 +=	"			AND SB1PALLET.D_E_L_E_T_ = ''
	A0001 +=	"			AND SB1PALLET.B1_GRUPO = '104B'
	A0001 +=	"		WHERE SD4.D4_FILIAL = SC2.C2_FILIAL
	A0001 +=	"			AND SD4.D4_OP = SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN
	A0001 +=	"			AND SD4.D_E_L_E_T_ = ''
	A0001 +=	"		), '') PALLET,
	
	
	A0001 += "        C2_PRODUTO,
	A0001 += "        B1_DESC,
	A0001 += "        C2_DATPRI,
	A0001 += "        C2_DATPRF,
	A0001 += "        C2_QUANT,
	A0001 += "        C2_QUANT - C2_QUJE SALDO,
	A0001 += "        CASE
	A0001 += "          WHEN C2_YOPQREF LIKE '%OP ORIGINAL%' THEN '*'
	A0001 += "          ELSE ' '
	A0001 += "        END TROCA,
	If MV_PAR05 = "PI"
		A0001 += "        (SELECT XC2.C2_QUANT
		A0001 += "           FROM "+RetSqlName("SC2")+" XC2
		A0001 += "          WHERE XC2.C2_FILIAL = '"+xFilial("SC2")+"'
		A0001 += "            AND XC2.C2_NUM = SC2.C2_NUM
		A0001 += "            AND XC2.C2_ITEM = SC2.C2_ITEM
		A0001 += "            AND XC2.C2_SEQUEN = '001'
		A0001 += "            AND XC2.D_E_L_E_T_ = ' ')QTDPAI,
		A0001 += "        (SELECT XC2.C2_PRODUTO
		A0001 += "           FROM "+RetSqlName("SC2")+" XC2
		A0001 += "          WHERE XC2.C2_FILIAL = '"+xFilial("SC2")+"'
		A0001 += "            AND XC2.C2_NUM = SC2.C2_NUM
		A0001 += "            AND XC2.C2_ITEM = SC2.C2_ITEM
		A0001 += "            AND XC2.C2_SEQUEN = '001'
		A0001 += "            AND XC2.D_E_L_E_T_ = ' ')PRODPAI,
	EndIf
	A0001 += "        C2_OBS,
	A0001 += "        C2_EMISSAO,
	A0001 += "       (SELECT COUNT(*)
	A0001 += "          FROM "+RetSqlName("SC2")+" XC2
	A0001 += "         WHERE C2_FILIAL = '"+xFilial("SC2")+"'
	A0001 += "           AND C2_NUM = SC2.C2_NUM
	A0001 += "           AND D_E_L_E_T_ = ' ') OPFIL,
	A0001 += "        C2_YQTRTFC
	A0001 += "   FROM "+RetSqlName("SC2")+" SC2
	A0001 += "  INNER JOIN SB1010 SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	A0001 += "                       AND B1_COD = C2_PRODUTO
	A0001 += "                       AND B1_TIPO = '"+MV_PAR05+"'
	A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
	A0001 += "   LEFT JOIN "+RetSqlName("ZZ6")+" ZZ6 ON ZZ6_FILIAL = '"+xFilial("ZZ6")+"'
	A0001 += "                       AND ZZ6_COD = B1_YFORMAT
	A0001 += "                       AND ZZ6.D_E_L_E_T_ = ' '
	A0001 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"'
	A0001 += "    AND C2_DATPRI BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	A0001 += "    AND C2_LINHA BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	A0001 += "    AND C2_DATRF = '        '
	A0001 += "    AND C2_ITEM = '01'
	A0001 += "    AND SC2.D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY C2_LINHA, C2_DATPRI, C2_PRIOR, C2_NUM, C2_SEQUEN
	TCQUERY A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		fImpCabec()

		xj_Linha := A001->C2_LINHA
		While !Eof() .and. xj_Linha == A001->C2_LINHA

			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf

			If MV_PAR05 $ "PA/PS/PP"

				xf_CbNumOp := +;
				Padr(A001->TROCA                                                                       ,01)+" "+;
				Padr(Substr(A001->NUMOP,1,6)                                                           ,06)+" "+;
				Padr(A001->ZZ6_DESC                                                                    ,10)+" "+;
				Padr(A001->EMBALAG                                                                     ,10)+" "+;
				Padr(A001->PALLET                                                                      ,10)+" "+;
				Padr(A001->C2_PRODUTO                                                                  ,15)+" "+;
				Padr(A001->B1_DESC                                                                     ,40)+" "+;
				Padr(dtoc(stod(A001->C2_DATPRI))                                                       ,08)+" "+;
				Padc(Alltrim(diasemana(stod(A001->C2_DATPRI)))                                         ,10)+" "+;
				Padr(dtoc(stod(A001->C2_DATPRF))                                                       ,08)+" "+;
				Padl(Transform(A001->C2_QUANT, "@E 999,999,999.99")                                    ,14)+" "+;
				Padl(Transform(A001->SALDO,    "@E 999,999.99")                                        ,10)+" "+;
				Padl(Transform(A001->C2_YQTRTFC, "@E 999,999,999.99")                                  ,14)+" "+;
				Padl(Transform(A001->OPFIL,    "@E 999")+' '+dtoc(stod(A001->C2_EMISSAO))              ,12)+" "+;
				Padr(A001->C2_OBS                                                                      ,30)
				
				aAdd(aDados,{;
								Padr(A001->TROCA                                                                       ,01),;
								Padr(Substr(A001->NUMOP,1,6)                                                           ,06),;
								Padr(A001->ZZ6_DESC                                                                    ,10),;
								Padr(A001->EMBALAG                                                                     ,10),;
								Padr(A001->PALLET                                                                      ,10),;
								Padr(A001->C2_PRODUTO                                                                  ,15),;
								Padr(A001->B1_DESC                                                                     ,40),;
								Padr(dtoc(stod(A001->C2_DATPRI))                                                       ,08),;
								Padc(Alltrim(diasemana(stod(A001->C2_DATPRI)))                                         ,10),;
								Padr(dtoc(stod(A001->C2_DATPRF))                                                       ,08),;
								Padl(Transform(A001->C2_QUANT, "@E 999,999,999.99")                                    ,14),;
								Padl(Transform(A001->SALDO,    "@E 999,999.99")                                        ,10),;
								Padl(Transform(A001->C2_YQTRTFC, "@E 999,999,999.99")                                  ,14),;
								Padl(Transform(A001->OPFIL,    "@E 999")+' '+dtoc(stod(A001->C2_EMISSAO))              ,12) + " "+;
								Padr(A001->C2_OBS                                                                      ,30);
							})


			ElseIf MV_PAR05 == "PI"

				xf_CbNumOp := +;
				Padr(" "                                                                               ,01)+" "+;
				Padr(Substr(A001->NUMOP,1,6)                                                           ,06)+" "+;
				Padr(Posicione("SB1",1,xFilial("SB1")+A001->PRODPAI, "B1_DESC")                        ,50)+" "+;
				Padl(Transform(A001->QTDPAI, "@E 999,999,999.99")                                      ,14)+"    "+;
				Padl(Transform(A001->SALDO,    "@E 999,999.99")                                        ,10)+" "+;
				Padr(A001->C2_PRODUTO                                                                  ,15)+" "+;
				Padr(A001->B1_DESC                                                                     ,50)+" "+;
				Padr(dtoc(stod(A001->C2_DATPRI))                                                       ,08)+" "+;
				Padc(Alltrim(diasemana(stod(A001->C2_DATPRI)))                                         ,10)+" "+;
				Padl(Transform(A001->C2_QUANT, "@E 999,999,999.99")                                    ,14)+" "+;
				Padl(Transform(A001->SALDO,    "@E 999,999.99")                                        ,10)+" "+;
				Padl(Transform(A001->OPFIL,    "@E 999")+' '+dtoc(stod(A001->C2_EMISSAO))              ,12)

			EndIf
			oPrint:Say  (nRow1 ,0045 ,xf_CbNumOp                               ,oFont8)
			oPrint:Line (nRow1+35, 050, nRow1+35, 3300)
			nRow1 += 075

			dbSelectArea("A001")
			dbSkip()
		End
		aAdd(aLinhas,{xj_Linha,aDados})	
		aDados := {}

		fImpRoda()

	End

	A001->(dbCloseArea())

	oPrint:EndPage()
	oPrint:Preview()
	
	If MV_PAR05 == "PA" .And. MV_PAR07 == '1'

		fQryDados()

	EndIf
	

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05.07.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

	oPrint:StartPage()
	wnPag ++
	nRow1 := 050
	If File(aBitmap)
		oPrint:SayBitmap( nRow1+25, 050, aBitmap, 0600, 0125 )
	EndIf
	nRow1 += 025
	sw_Perid :=  "Periodo: "+ dtoc(MV_PAR01) +" até " + dtoc(MV_PAR02)
	oPrint:Say  (nRow1     ,0050 ,Padc(fCabec+"    Linha: " + A001->C2_LINHA,110)            ,oFont14)
	oPrint:Say  (nRow1+10  ,3000 ,"Página:"                                                  ,oFont7)
	oPrint:Say  (nRow1+05  ,3150 ,Transform(wnPag,"@E 99999999")                             ,oFont8)
	oPrint:Say  (nRow1+60  ,3000 ,"Emissão:"                                                 ,oFont7)
	oPrint:Say  (nRow1+65  ,3150 ,dtoc(dDataBase)                                            ,oFont8)
	oPrint:Say  (nRow1+75  ,0050 ,Padc(sw_Perid,190)                                         ,oFont10)
	oPrint:Say  (nRow1+110 ,0700 ,"Observação: " + Alltrim(MV_PAR06)                         ,oFont12)
	nRow1 += 150
	oPrint:Line (nRow1, 050, nRow1, 3300)
	nRow1 += 050

	If MV_PAR05 $ "PA/PS/PP"

		xf_CbNumOp := +;
		Padr(" "                                        ,01)+" "+;
		Padr("NumOP"                                    ,06)+" "+;
		Padr("Formato"                                  ,10)+" "+;
		Padr("Embalagem"                                ,10)+" "+;
		Padr("Pallet"                                   ,10)+" "+;
		Padr("Produto"                                  ,15)+" "+;
		Padr("Descrição"                                ,40)+" "+;
		Padr("DataIni"                                  ,08)+" "+;
		Padc("DiaSemana"                                ,10)+" "+;
		Padr("DataFim"                                  ,08)+" "+;
		Padl("Qtde_M2"                                  ,14)+" "+;
		Padl("Saldo"                                    ,10)+" "+;
		Padl("Qtd2_Retif"                               ,14)+" "+;
		Padr("Observação"                               ,30)

	ElseIf MV_PAR05 == "PI"

		xf_CbNumOp := +;
		Padr(" "                                        ,01)+" "+;
		Padr("NumOP"                                    ,06)+" "+;
		Padr("Prod_Pai"                                 ,50)+" "+;
		Padl("Qtde_M2"                                  ,14)+"    "+;
		Padl("Saldo"                                    ,10)+" "+;
		Padr("Produto"                                  ,15)+" "+;
		Padr("Descrição"                                ,50)+" "+;
		Padr("DataIni"                                  ,08)+" "+;
		Padc("DiaSemana"                                ,10)+" "+;
		Padl("Qtde_Kg"                                  ,14)

	EndIf

	oPrint:Say  (nRow1 ,0050 ,xf_CbNumOp                               ,oFont8)
	oPrint:Line (nRow1+35, 050, nRow1+35, 3300)
	nRow1 += 065

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpRoda ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05.07.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

	oPrint:Line (2300, 050, 2300, 3300)
	oPrint:Say  (2300+30 , 050,"Prog.: " + fPerg                                      ,oFont7)
	oPrint:Say  (2300+30 ,2850,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
	oPrint:EndPage()
	nRow1 := 4000

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPergold()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data              ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data             ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Linha             ?","","","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Ate Linha            ?","","","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Tipo de Produto      ?","","","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Observações Diversas ?","","","mv_ch6","C",50,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return


Static Function ValidPerg()

	local cLoad	    := "BIA253" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	local aOpcs 	:= {"1=Sim","2=Não"}
	
	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	MV_PAR03 := Space(3)
	MV_PAR04 := Space(3)
	MV_PAR05 := Space(2)
	MV_PAR06 := Space(50)
	MV_PAR07 := '2'
	MV_PAR08 := space(100)
	
	aAdd( aPergs ,{1,"Data de" 	   			,MV_PAR01 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Data Até" 	   		,MV_PAR02 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Linha De" 	   		,MV_PAR03 ,""  ,""			,''  ,'.T.',20,.F.})
	aAdd( aPergs ,{1,"Linha Ate" 	   		,MV_PAR04 ,""  ,"NAOVAZIO()",''  ,'.T.',20,.F.})
	aAdd( aPergs ,{1,"Tipo de Produto" 		,MV_PAR05 ,""  ,"NAOVAZIO()",''  ,'.T.',20,.F.})
	aAdd( aPergs ,{1,"Observações Diversas"	,MV_PAR06 ,""  ,""			,''  ,'.T.',50,.F.})
	aAdd( aPergs ,{2,"Gera Excel" 			,MV_PAR07 ,aOpcs,60,'.T.',.F.})
	aAdd( aPergs ,{6,"Pasta Destino"  		,MV_PAR08 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Programação de Produção",,,,,,,,cLoad,.T.,.T.)
	
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)
		MV_PAR06 := ParamLoad(cFileName,,6,MV_PAR06)
		MV_PAR07 := ParamLoad(cFileName,,7,MV_PAR07)		
		MV_PAR08 := ParamLoad(cFileName,,8,MV_PAR08)		
		
		if empty(MV_PAR08) 
			MV_PAR08 := AllTrim(GetTempPath()) 	
		endif
	
	EndIf
	
Return lRet


Static Function fQryDados()

	Local nTotReg	:=	0
	local nRegAtu   := 0
	Local _nI		
	Local _nJ

	local cCab1Fon	:= 'Calibri' 
	local cCab1TamF	:= 8   
	local cCab1CorF := '#FFFFFF'
	local cCab1Fun	:= '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'
	Local nConsumo	 :=	0

	local cEmpresa  := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML   := "BIA253_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))

	nTotReg := Len(aLinhas) 
	if nTotReg < 1
		MsgStop('Não existem registros para essa consulta, favor verificar os parâmetros!')
		return
	endif

	ProcRegua(nTotReg + 2)

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

	oExcel := ARSexcel():New()

	For _nj	:=	1 to Len(aLinhas)

		oExcel:AddPlanilha("Linha " + aLinhas[_nj,1],{21,32,32,48,45,34,45,190,35,45,36,43,43,42,45},7)
	
		oExcel:AddLinha(20)
		oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,13) 
		oExcel:AddLinha(15)
		oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,13) 
		oExcel:AddLinha(15)
		oExcel:AddLinha(20)
		oExcel:AddCelula("Programação de Produção    Linha: " + aLinhas[_nj,1],0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,13)  
		oExcel:AddLinha(15)
		oExcel:AddCelula("Observação: " + MV_PAR06 ,0,'L',cFonte1,10,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,13)
	
		oExcel:AddLinha(20)
		oExcel:AddLinha(12) 
		oExcel:AddCelula()
		oExcel:AddCelula("Linha"								,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("NumOP"								,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Formato"								,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Embalagem"					        ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Pallet"							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Produto"							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Descrição"							,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("DataIni"							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Dia Semana"							,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Data Fim"							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)		
		oExcel:AddCelula("Qtde M2"							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
		oExcel:AddCelula("Saldo"							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)		
		oExcel:AddCelula("Qtd2_Retif"							,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Observação"							,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
		aDados	:=	aLinhas[_nJ,2]
		For _nI	:=	1 to Len(aDados)
	
			nRegAtu++
	
			if MOD(nRegAtu,2) > 0 
				cCorFun2 := '#DCE6F1'
			else
				cCorFun2 := '#B8CCE4'
			endif
	
			oExcel:AddLinha(14) 
			oExcel:AddCelula()
	
			oExcel:AddCelula(aLinhas[_nJ,1]											,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(aDados[_nI,2]											,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(aDados[_nI,3]											,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(aDados[_nI,4]											,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(aDados[_nI,5]											,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(aDados[_nI,6]											,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(aDados[_nI,7]											,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(aDados[_nI,8]											,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(aDados[_nI,9]											,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(aDados[_nI,10]											,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(aDados[_nI,11]											,0		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(aDados[_nI,12]											,0		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(aDados[_nI,13]											,0		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(aDados[_nI,14]											,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			
			
			IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")
	
	
		Next
	Next

	fGeraParametros()
	oExcel:SaveXml(Alltrim(MV_PAR08),cArqXML,.T.) 

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")



Return

Static Function fGeraParametros()

	local nCont		 := 0 
	local cCorFundo  := ""
	local cTitulo	 := 'Parametros'

	local cFonte1    := 'Calibri' 
	local nTamFont1  := 9
	local cCorFont1  := '#FFFFFF'
	local cCorFund1  := '#4F81BD'

	local cFonte2    := 'Arial' 
	local nTamFont2  := 9
	local cCorFont2  := '#000000'

	local cCorFundo  := ''

	aPergs[1,3] := DtoC(MV_PAR01) 
	aPergs[2,3] := DtoC(MV_PAR02)  
	aPergs[3,3] := MV_PAR03     
	aPergs[4,3] := MV_PAR04     
	aPergs[5,3] := MV_PAR05    
	aPergs[6,3] := MV_PAR06     
	aPergs[7,3] := MV_PAR07     
	aPergs[8,3] := MV_PAR08     

	oExcel:AddPlanilha('Parametros',{30,80,120,270})
	oExcel:AddLinha(18)
	oExcel:AddCelula(cTitulo,0,'C','Arial',12,'#FFFFFF',,,'#4F81BD',,,,,.T.,2,2) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula( "Sequencia" ,0,'C',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( "Pergunta"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( "Conteudo"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 

	for nCont := 1 to Len(aPergs)	

		if MOD(nCont,2) > 0 
			cCorFundo := '#DCE6F1'	
		else
			cCorFundo := '#B8CCE4'	
		endif	  

		oExcel:AddLinha(16) 
		oExcel:AddCelula()
		oExcel:AddCelula( strzero(nCont,2) ,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
		oExcel:AddCelula( aPergs[nCont,2]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
		oExcel:AddCelula( aPergs[nCont,3]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.) // Conteudo 

	next aPergs

Return 