#INCLUDE "PROTHEUS.CH"                                  
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_SPOOL 2

#DEFINE VBOX      080
#DEFINE VSPACE    008
#DEFINE HSPACE    010
#DEFINE SAYVSPACE 008
#DEFINE SAYHSPACE 008
#DEFINE HMARGEM   030
#DEFINE VMARGEM   030
#DEFINE MAXITEM   010                                                // Máximo de produtos para a primeira página
#DEFINE MAXITEMP2 044                                                // Máximo de produtos para a pagina 2 (caso nao utilize a opção de impressao em verso)
#DEFINE MAXITEMP3 015                                                // Máximo de produtos para a pagina 2 (caso utilize a opção de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMP4 022                                                // Máximo de produtos para a pagina 2 (caso contenha main info cpl que suporta a primeira pagina)
#DEFINE MAXITEMC  012                                                // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN 110                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG    006                                                // Máximo de dados adicionais na primeira página
#DEFINE MAXMSG2   019                                                // Máximo de dados adicionais na segunda página
#DEFINE MAXBOXH   800                                                // Tamanho maximo do box Horizontal
#DEFINE MAXBOXV   600
#DEFINE INIBOXH   -10
#DEFINE MAXMENL   080                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXVALORC 008                                                // Máximo de caracteres por linha de valores numéricos

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA723
Empresa   := Biancogres Cerâmica S/A
Data      := 04/06/13
Uso       := Ponto Eletrônico
Aplicação := Registro de Ponto
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA723()

	Local x

	Private aArea           := GetArea()
	Private lAdjustToLegacy := .T.  // Usado para montar o Objeto Printer
	Private lDisableSetup   := .T.  // Usado para montar o Objeto Printer
	Private lzServer        := .T.
	Private lzViewPDF       := .F.

	Private zpDirServr      := "\P10\PONTO\"

	Private nHPage
	Private nVPage
	Private nLine
	Private nBaseTxt
	Private nBaseCol

	Private oPagtoRH
	Private PixelX
	Private PixelY
	Private oSetup
	Private nConsNeg      := 0.40 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
	Private nConsTex      := 0.38 // Constante para concertar o cálculo retornado pelo GetTextWidth.
	Private oBrush        := TBrush():New( , CLR_BLACK )

	Private fNmRel := "registroponto_"+Substr(TIME(),1,2)+Substr(TIME(),4,2)+Substr(TIME(),7,2)
	Private fPerg  := "BIA723"

	ConOut("HORA: "+TIME()+" - Processo BIA723 ")

	If Select("SX6") == 0                                 // Via Schedule
		*****************************************************************

		xv_Emps := U_BAGtEmpr("01_05_12_13")

		For x := 1 to Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)
			RpcSetEnv(xv_Emps[x,1], xv_Emps[x,2])

			ftDatDe  := stod(Substr(dtos(dDataBase),1,6)+"21")
			ftDatAte := stod(Substr(dtos(dDataBase+30),1,6)+"20")
			ftMatIni := "000001"
			ftMatFim := "ZZZZZZ"
			ftTurIni := "   "
			ftTurFim := "ZZZ"
			ftRegIni := "98"
			ftRegFim := "98"

			wfBIA723()

			ftDatDe  := stod(Substr(dtos(dDataBase),1,6)+"21")
			ftDatAte := stod(Substr(dtos(dDataBase+30),1,6)+"20")
			ftMatIni := "000001"
			ftMatFim := "ZZZZZZ"
			ftTurIni := "   "
			ftTurFim := "ZZZ"
			ftRegIni := "96"
			ftRegFim := "96"

			wfBIA723()

			ConOut("HORA: "+TIME()+" - Finalizando Processo BIA723 " + xv_Emps[x,1])

			//Finaliza o ambiente criado
			RpcClearEnv()

		Next

	Else                                         // Via Integração Manual
		*****************************************************************

		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		fValidPerg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		ftDatDe  := MV_PAR01
		ftDatAte := MV_PAR02
		ftMatIni := MV_PAR03
		ftMatFim := MV_PAR04
		ftTurIni := MV_PAR05
		ftTurFim := MV_PAR06
		ftRegIni := MV_PAR07
		ftRegFim := MV_PAR08

		Processa({||wfBIA723()})

	EndIf

	RestArea(aArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ wfBIA723  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 18/06/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Responsável pela execução dos Jobs                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function wfBIA723()

	RP001 := " SELECT RA_MAT, "
	RP001 += "        RA_NOME, "
	RP001 += "        RA_TNOTRAB, "
	RP001 += "        RA_REGRA, "
	RP001 += "        RA_YSEMAIL "
	RP001 += "   FROM " + RetSqlName("SRA")
	RP001 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"' "
	RP001 += "    AND RA_MAT BETWEEN '"+ftMatIni+"' AND '"+ftMatFim+"' "
	RP001 += "    AND RA_TNOTRAB BETWEEN '"+ftTurIni+"' AND '"+ftTurFim+"' "
	RP001 += "    AND RA_REGRA BETWEEN '"+ftRegIni+"' AND '"+ftRegFim+"' "
	RP001 += "    AND RA_SITFOLH <> 'D' "
	RP001 += "    AND RA_CLVL NOT IN('2115','2215') "
	RP001 += "    AND D_E_L_E_T_ = ' ' "
	RP001 += "  ORDER BY RA_YSEMAIL "
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RP001),'RP01',.T.,.T.)
	dbSelectArea("RP01")
	dbGoTop()
	
	While !Eof()

		oPagtoRH := FWMsPrinter():New(fNmRel+".rel", IMP_PDF, lAdjustToLegacy, zpDirServr, lDisableSetup, , , , lzServer, , , lzViewPDF)
		PixelX   := oPagtoRH:nLogPixelX()
		PixelY   := oPagtoRH:nLogPixelY()

		oFont20n   := TFontEx():New(oPagtoRH,"Arial",20,20,.T.,.T.,.F.)
		oFont20    := TFontEx():New(oPagtoRH,"Arial",20,20,.F.,.T.,.F.)
		oFont15n   := TFontEx():New(oPagtoRH,"Lucida Console",15,15,.T.,.T.,.F.)
		oFont15    := TFontEx():New(oPagtoRH,"Arial",15,15,.F.,.T.,.F.)
		oFont10n   := TFontEx():New(oPagtoRH,"Arial",10,10,.T.,.T.,.F.)
		oFont10    := TFontEx():New(oPagtoRH,"Arial",10,10,.F.,.T.,.F.)
		oFont12n   := TFontEx():New(oPagtoRH,"Arial",12,12,.T.,.T.,.F.)
		oFntEx12   := TFontEx():New(oPagtoRH,"Lucida Console",12,12,.T.,.T.,.F.)
		oFont09n   := TFontEx():New(oPagtoRH,"Arial",09,09,.T.,.T.,.F.)
		oFont09    := TFontEx():New(oPagtoRH,"Arial",09,09,.F.,.T.,.F.)
		oFont08n   := TFontEx():New(oPagtoRH,"Arial",08,08,.T.,.T.,.F.)
		oFont08    := TFontEx():New(oPagtoRH,"Arial",08,08,.F.,.T.,.F.)

		// Ordem obrigátoria de configuração do relatório
		oPagtoRH:SetResolution(72)
		oPagtoRH:SetPortrait()
		oPagtoRH:SetPaperSize(DMPAPER_A4)
		oPagtoRH:SetMargin(60,60,60,60)       // nEsquerda, nSuperior, nDireita, nInferior
		oPagtoRH:cPathPDF := zpDirServr       // Caso seja utilizada impressão em IMP_PDF, define diretório de gravação
		aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"

		xPrntPdf := .T.
		If Alltrim(oPagtoRH:cPrinter) <> "PDF" .or. Len(Alltrim(oPagtoRH:cPrinter)) > 3
			xPrntPdf := .F.
		EndIf

		xQdPag := 1
		xLnhOld := 0
		ftSMail := Alltrim(RP01->RA_YSEMAIL)
		While !Eof() .and. Alltrim(RP01->RA_YSEMAIL) == ftSMail

			If xQdPag == 1

				oPagtoRH:StartPage()
				nHPage := oPagtoRH:nHorzRes()
				nHPage *= (300/PixelX)
				nHPage -= HMARGEM
				nVPage := oPagtoRH:nVertRes()
				nVPage *= (300/PixelY)
				nVPage -= VBOX
				nBaseTxt := 50
				nBaseCol := 50

			EndIf

			nLine  := xLnhOld
			nLine  += IIF(xPrntPdf, 120, 120)

			// O limite da Margem é nHPage - 270
			oPagtoRH:Box(nLine+000, nBaseCol, nLine+070, nHPage - 270, "-4")
			oPagtoRH:Say(nLine+055, nBaseTxt, Padc("REGISTRO DE PONTO",122) , oFont20n:oFont)
			If File(aBitmap)
				oPagtoRH:SayBitmap( nLine+002, nBaseCol+005, aBitmap, 0300, 0060 )
			EndIf

			nLine += 150
			oPagtoRH:Say(nLine, nBaseTxt, Padc(Alltrim(SM0->M0_NOMECOM),122) , oFont20n:oFont)
			xExtEnd := Alltrim(SM0->M0_ENDENT)+", "+Alltrim(SM0->M0_BAIRENT)+", "+Alltrim(SM0->M0_CIDENT)+"-"+Alltrim(SM0->M0_ESTENT) + "         CNPJ - " + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99")
			nLine += 050
			oPagtoRH:Say(nLine, nBaseTxt, Padc(Alltrim(xExtEnd),135)         , oFont15:oFont)

			xRefFunc := "Nome: "+ Padr(Alltrim(RP01->RA_NOME), 70) + " Matr: " + Padr(Alltrim(RP01->RA_MAT), 20) + " Período: " + dtoc(ftDatDe) + " a " + dtoc(ftDatAte)
			nLine += 075
			oPagtoRH:Say(nLine, nBaseTxt, Padr(Alltrim(xRefFunc),135)         , oFont15:oFont)

			xRefTurn := "Horário: " + Posicione("SR6", 1, xFilial("SR6")+RP01->RA_TNOTRAB, "R6_DESC")
			nLine += 075
			oPagtoRH:Say(nLine, nBaseTxt, Padr(Alltrim(xRefTurn),135)         , oFont15:oFont)

			xf_Titu := +;
			Padc("Dia"                                                                      ,06)+" "+;
			Padc("Entrada"                                                                  ,09)+" "+;
			Padc("Assinatura"                                                               ,32)+" "+;
			Padc("Saída"                                                                    ,05)+" "+;
			Padc("Assinatura"                                                               ,35)
			nLine += 100
			oPagtoRH:Box(nLine-050, nBaseCol, nLine+020, nHPage - 270, "-4")
			oPagtoRH:Say(nLine, nBaseTxt, xf_Titu         , oFont15n:oFont)
			oPagtoRH:Line(nLine-050, 0180, nLine+017, 0180)
			oPagtoRH:Line(nLine-050, 0410, nLine+017, 0410)
			oPagtoRH:Line(nLine-050, 1130, nLine+017, 1130)
			oPagtoRH:Line(nLine-050, 1320, nLine+017, 1320)

			xDtRef := ftDatDe
			While xDtRef <= ftDatAte

				xgDscFeriad := ""
				dbSelectArea("Z27")
				If dbSeek(xFilial("Z27")+dtos(xDtRef))
					If Z27->Z27_EXPEDI == "N"
						xgDscFeriad := Z27->Z27_DESCRI
					EndIf
				EndIf

				// Varifica se o funcionario esta de ferias na data de referencia
				If fFerias(RP01->RA_MAT, xDtRef)

					xf_Item := +;					
					Padc(StrZero(Day(xDtRef),2)                                                     ,06)+" "+;
					Padc("-"                                                                        ,09)+" "+;
					Padc("FERIAS"                                          													,32)+" "+;
					Padc("-"                                                                        ,05)+" "+;
					Padc("FERIAS"                                          													,35)

				Else

					If Alltrim(UPPER(DiaSemana(xDtRef))) $ "SABADO" 
						If RP01->RA_REGRA <> "96"
							xf_Item := +;
							Padc(StrZero(Day(xDtRef),2)                                                     ,06)+" "+;
							Padc("-"                                                                        ,09)+" "+;
							Padc(Alltrim(UPPER(DiaSemana(xDtRef)))                                          ,32)+" "+;
							Padc("-"                                                                        ,05)+" "+;
							Padc(Alltrim(UPPER(DiaSemana(xDtRef)))                                          ,35)

						Else
							xf_Item := +;
							Padc(StrZero(Day(xDtRef),2)                                                     ,06)+" "+;
							Padc(""                                                                         ,09)+" "+;
							Padc(""                                                                         ,32)+" "+;
							Padc(""                                                                         ,05)+" "+;
							Padc(""                                                                         ,35)

						EndIf

					ElseIf Alltrim(UPPER(DiaSemana(xDtRef))) $ "DOMINGO"
						xf_Item := +;
						Padc(StrZero(Day(xDtRef),2)                                                     ,06)+" "+;
						Padc("-"                                                                        ,09)+" "+;
						Padc(Alltrim(UPPER(DiaSemana(xDtRef)))                                          ,32)+" "+;
						Padc("-"                                                                        ,05)+" "+;
						Padc(Alltrim(UPPER(DiaSemana(xDtRef)))                                          ,35)

					ElseIf !Empty(xgDscFeriad)
						xf_Item := +;
						Padc(StrZero(Day(xDtRef),2)                                                     ,06)+" "+;
						Padc("-"                                                                        ,09)+" "+;
						Padc(Alltrim(UPPER(xgDscFeriad))                                                ,32)+" "+;
						Padc("-"                                                                        ,05)+" "+;
						Padc(Alltrim(UPPER(xgDscFeriad))                                                ,35)

					Else
						xf_Item := +;
						Padc(StrZero(Day(xDtRef),2)                                                     ,06)+" "+;
						Padc(""                                                                         ,09)+" "+;
						Padc(""                                                                         ,32)+" "+;
						Padc(""                                                                         ,05)+" "+;
						Padc(""                                                                         ,35)

					EndIf

				EndIf

				nLine += 070
				oPagtoRH:Box(nLine-050, nBaseCol, nLine+020, nHPage - 270, "-4")
				oPagtoRH:Say(nLine, nBaseTxt, xf_Item         , oFont15n:oFont)
				oPagtoRH:Line(nLine-050, 0180, nLine+017, 0180)
				oPagtoRH:Line(nLine-050, 0410, nLine+017, 0410)
				oPagtoRH:Line(nLine-050, 1130, nLine+017, 1130)
				oPagtoRH:Line(nLine-050, 1320, nLine+017, 1320)

				xDtRef += 1

			End

			nLine += 150
			oPagtoRH:Line (nLine, nBaseCol, nLine, 1000)
			nLine += 050
			oPagtoRH:Say(nLine    , nBaseCol     , Padc("Supervisor Imediato",110)                                                                 , oFont12n:oFont)

			xQdPag := 1
			xLnhOld := 0
			oPagtoRH:EndPage()

			dbSelectArea("RP01")
			dbSkip()

		End

		oPagtoRH:EndPage()
		oPagtoRH:Preview()

		WF047 := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
		WF047 += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
		WF047 += ' <head> '
		WF047 += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
		WF047 += ' <title>Untitled Document</title> '
		WF047 += ' </head> '
		WF047 += ' <body> '
		WF047 += ' <p>Bom dia!</p> '
		WF047 += ' <p>Segue em anexo modelo de ponto período '+dtoc(ftDatDe)+' à '+dtoc(ftDatAte)+'.</p> '
		WF047 += ' <p><strong><u>Orientações Importantes</u></strong>:</p> '
		WF047 += ' <ul> '
		WF047 += '   <li>Verificar se o nome e matrícula estão devidamente preenchidos;</li> '
		WF047 += '   <li>Orientar que o ponto não seja preenchido de forma britânica;</li> '
		WF047 += '   <li>Orientar que seja preenchido respeitando os 15  minutos de tolerância;</li> '
		WF047 += '   <li>Sem rasuras.</li> '
		WF047 += ' </ul> '
		WF047 += ' <p>&nbsp;</p> '
		WF047 += ' <p><strong>FAVOR ENTREGAR O PONTO  MANUAL DO PERÍODO ANTERIOR O MAIS BREVE POSSÍVEL.</strong></p> '
		WF047 += ' <p>&nbsp;</p> '
		WF047 += ' <p>Atenciosamente,</p> '
		WF047 += ' <p>&nbsp;</p> '
		WF047 += ' <p>E-mail enviado automaticamente pelo sistema Protheus (by BIA723). Favor não responder ao rementente deste. Caso necessite de alguma informação adcional procurar diretamente o Departamento pessoal.</p> '
		WF047 += ' </body> '
		WF047 += ' </html> '

		//RUBENS JUNIOR - 14/03/14, NOVA FORMA DE BUSCAR DESTINATARIO DO EMAIL, VIA TABELA Z28 
		df_Dest := U_EmailWF('BIA723',cEmpAnt) + ftSMail
		//SE RETORNAR VAZIO, UTILIZA FORMA ANTIGA
		If Empty(df_Dest)
			df_Dest := "jessica.silva@biancogres.com.br;francine.araujo@biancogres.com.br;jeane.carvalho@biancogres.com.br,rh.pessoal@biancogres.com.br" + ftSMail
		EndIf

		df_Assu := "Registro de Ponto             " + ftSMail
		df_Erro := "Registro de Ponto não enviado. Favor verificar!!!"

		yrAnexo := zpDirServr+fNmRel+".pdf"

		Sleep(60000)
		
		U_BIAEnvMail(, df_Dest, df_Assu, WF047, df_Erro, yrAnexo)
				
		FreeObj(oPagtoRH)
		
		oPagtoRH := Nil

		dbSelectArea("RP01")
			
	End

	Ferase(cIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(cIndex+OrdBagExt())          //indice gerado
	RP01->(dbCloseArea())

	RestArea(aArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data               ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data              ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Matricula          ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg,"04","Ate Matricula         ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg,"05","De Turno              ?","","","mv_ch5","C",03,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SR6"})
	aAdd(aRegs,{cPerg,"06","Ate Turno             ?","","","mv_ch6","C",03,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SR6"})
	aAdd(aRegs,{cPerg,"07","De Regra              ?","","","mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SPA"})
	aAdd(aRegs,{cPerg,"08","Ate Regra             ?","","","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SPA"})
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


Static Function fFerias(cMat, dDatRef)

	Local lRet := .F.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT R8_DATAINI, R8_DATAFIM " 
	cSQL += " FROM "+ RetSQLName("SR8")
	cSQL += " WHERE R8_FILIAL = "+ ValToSQL(xFilial("SR8"))
	cSQL += " AND R8_MAT = "+ ValToSQL(cMat)
	cSQL += " AND ( R8_TIPO = 'F' OR R8_TIPOAFA = '001' ) "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof()) .And. !lRet

		If dDatRef >= sToD((cQry)->R8_DATAINI) .And. dDatRef <= sToD((cQry)->R8_DATAFIM)

			lRet := .T.

		EndIf

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(lRet)
