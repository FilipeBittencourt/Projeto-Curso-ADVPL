#include "topconn.ch"
#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include "Ap5Mail.ch"
#Include "tbiconn.ch"
#Include 'FONT.CH'
#Include 'COLORS.CH'
#Include "FOLDER.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'MATA200.CH'
#INCLUDE 'DBTREE.CH'
#INCLUDE "REPORT.CH"
#INCLUDE "JPEG.CH"
#INCLUDE "XMLXFUN.CH"
#Include "dbinfo.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "fwcommand.ch"

#DEFINE MSECONDS_WAIT 5000

Static __cCRLF    := CRLF

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIAXFUNC  ¦ Autor ¦ Marcos Albeto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Programa desenvolvido com o intuito de comportar todos os  ¦¦¦
¦¦¦          ¦fontes que geralmente repetem-se em diversos outros fontes  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Protheus                                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

/* Deste ponto em diante são listados os programas que serão chamados de di-
.  versos outros fontes do Projeto Biancogres                              */

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIAxExcel  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIAxExcel(aColunas, ahead, cArq, xAbreExcel)

	Local ny
	Local cDirDocs   := "\P10\DOCTEMP" //MsDocPath() // Alterado em 21/07/15 porque estava gerando problema com o BancoDeConhecimento
	Local aStru      := {}
	Local cArquivo   := CriaTrab(,.F.)
	Local cPath      := AllTrim(GetTempPath())
	Local oExcelApp
	Local nHandle
	Local cCrLf      := Chr(13) + Chr(10)
	Local nX
	Local xAbreExcel := IIF(xAbreExcel == NIL, .T., xAbreExcel)
	If ahead == nil
		Return
	Endif
	If cArq <> nil
		cArquivo := cArq
	Endif
	aStru := ahead
	nHandle := MsfCreate(cDirDocs+"\"+cArquivo+".csv",0)
	If nHandle > 0

		// Grava o cabecalho do arquivo
		IncProc("Aguarde! Gerando arquivo de integração com Excel...")
		aEval(aStru, {|e, nX| fWrite(nHandle, e[1] + If(nX < Len(aStru), ";", "") ) } )
		fWrite(nHandle, cCrLf ) // Pula linha
		For nX := 1 to Len(aColunas)
			IncProc("Aguarde! Gerando arquivo de integração com Excel...")
			For nY := 1 to Len(aStru)
				fWrite(nHandle, Transform(aColunas[nX,nY], "@!" ) + ";" )
			Next nY
			fWrite(nHandle, cCrLf ) // Pula linha
		Next nX

		IncProc("Aguarde! Abrindo o arquivo...")
		fClose(nHandle)
		CpyS2T( cDirDocs+"\"+cArquivo+".csv" , cPath, .T. )
		If ! ApOleClient( 'MsExcel' )
			cNewPath := "C:\Temp\"
			MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+cNewPath+cArquivo+".csv"  )
			If !lIsDir( cNewPath )
				MakeDir( cNewPath )
			EndIf
			CpyS2T(cDirDocs+"\"+cArquivo+".csv", cNewPath+cArquivo+".csv")
			Return
		EndIf

		If xAbreExcel
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cPath+cArquivo+".csv" ) // Abre uma planilha
			oExcelApp:SetVisible(.T.)
		EndIf

	Else

		MsgAlert( "Falha na criação do arquivo" )

	Endif

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIACrTMP  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIACrTMP(aStruct)

	Local cNome:= CriaTrab(,.F.)
	Do While File(cNome+GetDBExtension())
		InKey(.1)
		cNome:= CriaTrab(,.F.)
	EndDo
	DbCreate(cNome,aStruct)

Return cNome

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIAEnvMail ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIAEnvMail(xk_Orig,xk_Dest,xk_Assunt,xk_Mensag,xk_Erro,xk_Anexo,lOrigem,xk_cCopia, xk_oCopia)

	Local cServer     := GetMV("MV_RELSERV")
	Local cAccount    := GetMV("MV_RELACNT")
	Local cPassword   := GetMV("MV_RELPSW")
	Local cPorSMTP	  := GetMv("MV_PORSMTP") 	
	Local lSmtpAuth   := GetMv("MV_RELAUTH",,.F.)

	Local cMailCtaAut := cAccount
	Local cMailSenha  := cPassword
	Local lOK         := .F.
	Local lAutOk      := .F.
	Local cOrigem

	Default xk_Orig		:= ""
	Default lOrigem 	:= .F.
	Default xk_Anexo 	:= ""
	Default xk_Erro 	:= ""
	Default xk_cCopia 	:= ";"
	Default xk_oCopia   := ";"

	xk_cCopia	:= IIF(Empty(xk_cCopia), ";", xk_cCopia)
	xk_oCopia	:= IIF(Empty(xk_oCopia), ";", xk_oCopia)

	//xk_Anexo   	:= IIF(xk_Anexo == NIL, "", xk_Anexo)
	cOrigem	:= IIF(lOrigem, xk_Orig, GetMV("MV_RELFROM"))

	If !Empty(Alltrim(cValtoChar(cPorSMTP)))
		cServer := cServer+":"+Alltrim(cValtoChar(cPorSMTP))
	EndIf

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cMailCtaAut,cMailSenha)
		Else
			lAutOk := .T.
		EndIf
	EndIf
	If (lOK) .And. lAutOk
		SEND MAIL FROM Alltrim(cOrigem);
		TO 			xk_Dest;
		CC 			xk_cCopia;
		BCC 		xk_oCopia;
		SUBJECT 	xk_Assunt;
		BODY 		xk_Mensag;
		ATTACHMENT 	xk_Anexo;
		RESULT lOK
	Else
		GET MAIL ERROR xk_Erro
		SEND MAIL FROM cOrigem;
		TO 'retorno@biancogres.com.br';
		SUBJECT xk_Assunt;
		BODY 'Ocorreu erro ao enviar o e-mail...   '+xk_Erro
	EndIf
	DISCONNECT SMTP SERVER

Return lOK

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIAGetLike ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIAGetLike(xk_String)

	Local cString := Alltrim(xk_String)
	Local xLike   := "'"
	If Right(cString,1) <> ','
		cString := cString+","
	EndIf
	ProcRegua(RecCount())
	While .T.
		IncProc()
		nPos := AT(",", cString )
		If nPos > 0
			xLike   += Substr(cString,1,nPos-1)
			cString := Alltrim(Substr(cString,nPos+1,Len(cString)))
		Endif
		If Empty(cString)
			xLike += "'"
			Exit
		EndIf
		xLike += "','"
	End

Return ( xLike )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIAFimStru ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIAFimStru(cAliasEstru,cArqTrab)

	cAliasEstru:=IF(cAliasEstru == NIL,"ESTRUT",cAliasEstru)
	dbSelectArea(cAliasEstru)
	dbCloseArea()
	If File(cArqTrab+GETDBEXTENSION())
		Ferase(cArqTrab+GETDBEXTENSION())
	Endif
	If File(cArqTrab+".CDX")
		Ferase(cArqTrab+".CDX")
	Endif
	If File(cArqTrab+OrdBagExt())
		Ferase(cArqTrab+OrdBagExt())
	Endif

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIASldTit  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Função criada para atender a necessidade de gerar arquivo  ¦¦¦
¦¦¦            de remessa de cnab a receber subtraindo o valor do "AB-"   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIASldTit()

	Local yk_Saldo
	yk_Saldo := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZA,"R",SE1->E1_CLIENTE,1,SE1->E1_VENCREA,dDataBase,SE1->E1_LOJA)
	yk_Saldo := yk_Saldo - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1)
	yk_Saldo := Round(NoRound(yk_Saldo,3),2)

Return( yk_Saldo )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIAVctTit  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Função criada para atender a geração do arquivo cnab prop- ¦¦¦
¦¦¦            ciando informar da data de  vencimento negociada           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIAVctTit()

	Local yk_VenctoT

	yk_VenctoT :=  GRAVADATA( IIF(!Empty(SE1->E1_YDTCMD), SE1->E1_YDTCMD, SE1->E1_VENCTO) ,.F.)

Return( yk_VenctoT )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIAConsultPer ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Programa usado para consulta personalizada via "F3".       ¦¦¦
¦¦¦          ¦ Com ele podem ser criados filtros mais rápidos e impedi-   ¦¦¦
¦¦¦          ¦ mento para visualização de detalhes que não podem ser ob-  ¦¦¦
¦¦¦          ¦ servados por alguns usuários.                              ¦¦¦
¦¦¦          ¦ Inicialmente usado para a Tabela "SA1", mas com algumas    ¦¦¦
¦¦¦          ¦ adaptações poderá ser usado para outras.                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIAConsultPer()

	Local aArea   := GetArea()

	Private oDlgTab
	Private oGet1
	Private cGet1 := Space(45)
	Private oRadMenu1
	Private nRadMenu1 := 1
	Private Pesquisar
	Private Retornar
	Private nX
	Private aHeaderEx := {}
	Private aColsEx := {}
	Private aFieldFill := {}
	Private aFields := {"A1_COD","A1_LOJA","A1_NOME","A1_CGC"}
	Private aAlterFields := {"A1_COD","A1_LOJA","A1_NOME","A1_CGC"}
	Private oMSNewGetDados1
	Public hk_Retur1 := ""
	Public hk_Retur2 := ""

	DEFINE MSDIALOG oDlgTab TITLE "Cadastro de Clientes" FROM 000, 000  TO 540, 600 COLORS 0, 16777215 PIXEL

	fMSNewGetDados1()
	@ 216, 005 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Cod.Cliente + Loja","Nome","CNPJ / CPF" SIZE 071, 026 OF oDlgTab COLOR 0, 16777215 ON CHANGE wMudOrd() PIXEL
	@ 248, 005 MSGET oGet1 VAR cGet1 SIZE 197, 015 OF oDlgTab COLORS 0, 16777215 PIXEL
	@ 231, 208 BUTTON Pesquisar PROMPT "Pesquisar" SIZE 037, 032 OF oDlgTab ACTION( wRetCodCl() ) PIXEL
	@ 231, 255 BUTTON Retornar PROMPT "Retornar" SIZE 037, 032 OF oDlgTab ACTION( wRtCodSel() ) PIXEL
	ACTIVATE MSDIALOG oDlgTab

	n := 1
	RestArea( aArea )

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+hk_Retur1+hk_Retur2)
	cNLjCli   := SA1->A1_LOJA
	cNClient1 := SA1->A1_NOME

Return .T.

//*******************************************************
//**  SubFunction1 ref: BIAConsultPer()                **
//*******************************************************
Static Function fMSNewGetDados1()

	Local nX

	_nomeuser := cUserName
	psworder(2)                          // Pesquisa por Nome
	If  pswseek(_nomeuser,.t.)           // Nome do usuario, Pesquisa usuarios
		_daduser  := pswret(1)            // Numero do registro
		_UsuarAt  := _daduser[1,1]
	EndIf

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(dbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	A0001 := " SELECT A1_COD, A1_LOJA, A1_NOME, A1_CGC	"
	A0001 += " FROM "+RetSqlName("SA1")+"				"
	A0001 += " WHERE A1_FILIAL = '"+xFilial("SA1")+"'	"
	If !Empty(Alltrim(cRepAtu))
		A0001 += "  AND (A1_VEND     = '"+cRepAtu+"' OR A1_YVENDB2 = '"+cRepAtu+"' OR A1_YVENDB3 = '"+cRepAtu+"' OR "
		A0001 += "	     A1_YVENDI	 = '"+cRepAtu+"' OR A1_YVENDI2 = '"+cRepAtu+"' OR A1_YVENDI3 = '"+cRepAtu+"' OR "
		A0001 += "	     A1_YVENVT1  = '"+cRepAtu+"' OR A1_YVENVT2 = '"+cRepAtu+"' OR A1_YVENVT3 = '"+cRepAtu+"' OR "
		A0001 += "	     A1_YVENML1  = '"+cRepAtu+"' OR A1_YVENML2 = '"+cRepAtu+"' OR A1_YVENML3 = '"+cRepAtu+"' OR "
		A0001 += "	     A1_YVENBE1  = '"+cRepAtu+"' OR A1_YVENBE2 = '"+cRepAtu+"' OR A1_YVENBE3 = '"+cRepAtu+"' OR "
		A0001 += "	     A1_YVENPEG = '"+cRepAtu+"' OR A1_YVENVI1 = '"+cRepAtu+"')    "
	EndIf
	A0001 += "    AND D_E_L_E_T_ = ' '
	A0001 += " ORDER BY A1_COD, A1_LOJA
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		Aadd(aFieldFill, {A001->A1_COD, A001->A1_LOJA , A001->A1_NOME, A001->A1_CGC, .F. })
		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())

	If Len(aFieldFill) == 0
		For nX := 1 to Len(aFields)
			If dbSeek(aFields[nX])
				Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
			Endif
		Next nX
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
	Else
		aColsEx := aFieldFill
	EndIf

	oMSNewGetDados1 := MsNewGetDados():New( 005, 005, 213, 294, , , , , , , 999, , , , oDlgTab, aHeaderEx, aColsEx)

Return

//*******************************************************
//**  SubFunction2 ref: BIAConsultPer()                **
//*******************************************************
Static Function wRetCodCl()

	jk_Tam := Len(Alltrim(cGet1))
	nPos   := 0
	If Len(aColsEx) > 1
		If nRadMenu1 == 1
			nPos := aScan(aColsEx,{|x| Substr(x[1], 1, jk_Tam) == Substr(cGet1, 1, jk_Tam) })
		ElseIf nRadMenu1 == 2
			nPos := aScan(aColsEx,{|x| Substr(x[3], 1, jk_Tam) == Substr(cGet1, 1, jk_Tam) })
		ElseIf nRadMenu1 == 3
			nPos := aScan(aColsEx,{|x| Substr(x[4], 1, jk_Tam) == Substr(cGet1, 1, jk_Tam) })
		EndIf
		If nPos <> 0
			n:=nPos
			oMSNewGetDados1:oBrowse:nAt:=nPos
			oMSNewGetDados1:oBrowse:Refresh()
			oMSNewGetDados1:oBrowse:SetFocus()
		EndIf
	EndIf

Return

//*******************************************************
//**  SubFunction3 ref: BIAConsultPer()                **
//*******************************************************
Static Function wMudOrd()

	If Len(aColsEx) > 1
		If nRadMenu1 == 1
			aColsEx := aSort(aColsEx,,,{|x,y| x[1] < y[1] })
		ElseIf nRadMenu1 == 2
			aColsEx := aSort(aColsEx,,,{|x,y| x[3] < y[3] })
		ElseIf nRadMenu1 == 3
			aColsEx := aSort(aColsEx,,,{|x,y| x[4] < y[4] })
		EndIf
		oMSNewGetDados1:ACOLS := aColsEx
		oMSNewGetDados1:oBrowse:Refresh()
		oMSNewGetDados1:oBrowse:SetFocus()
	EndIf

Return

//*******************************************************
//**  SubFunction3 ref: wRtCodSel()                    **
//*******************************************************
Static Function wRtCodSel()

	hk_Retur1 := oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][1]
	hk_Retur2 := oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][2]
	oDlgTab:End()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIAImpPLS002  ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 07/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Programa usado para tratar os campos do arquivo txt para   ¦¦¦
¦¦¦          ¦ importação dos Valores ref uso do Plano de Saude           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIAImpPLS002(xf_Posic)

	Local xf_NumPlan := Substr(TXT,17,3)+Substr(TXT,22,4)+Substr(TXT,33,6)+Substr(TXT,40,2)
	Local xf_Tipo    := Substr(TXT,14,2)
	Local xf_Cpf     := Substr(TXT,472,14)
	Local xf_DtLanc  := dtos(Ultimodia(dDataBase)) //dtos(ctod(Substr(TXT,251,2)+"/"+Substr(TXT,253,2)+"/"+Substr(TXT,255,2)))
	Local xf_Valor   := StrTran( Substr(TXT,384,15) ,",",".")

	Public rt_Matr := Space(6)
	Public rt_CCus := Space(4)
	Public rt_Verb := Space(3)
	Public rt_Valo := 0
	Public rt_DtLa := stod(xf_DtLanc)

	If xf_Tipo == "TN"

		A0001 := " SELECT (SELECT RA_MAT
		A0001 += "           FROM " + RetSqlName("SRA")
		A0001 += "          WHERE RA_FILIAL = '"+xFilial("SRA")+"'
		A0001 += "            AND RA_CIC = '"+Alltrim(xf_Cpf)+"'
		A0001 += "            AND ((RA_DEMISSA = '        ') OR ('"+xf_DtLanc+"' <= RA_DEMISSA))
		A0001 += "            AND '"+xf_DtLanc+"' >= RA_ADMISSA
		A0001 += "            AND D_E_L_E_T_ = ' ') MATRIC,
		A0001 += "        (SELECT RA_CC
		A0001 += "           FROM " + RetSqlName("SRA")
		A0001 += "          WHERE RA_FILIAL = '"+xFilial("SRA")+"'
		A0001 += "            AND RA_CIC = '"+Alltrim(xf_Cpf)+"'
		A0001 += "            AND ((RA_DEMISSA = '        ') OR ('"+xf_DtLanc+"' <= RA_DEMISSA))
		A0001 += "            AND '"+xf_DtLanc+"' >= RA_ADMISSA
		A0001 += "            AND D_E_L_E_T_ = ' ') CCUSTO,
		A0001 += "        (SELECT RB_YVBCOOP
		A0001 += "           FROM " + RetSqlName("SRB")
		A0001 += "          WHERE RB_FILIAL = '"+xFilial("SRB")+"'
		A0001 += "            AND RB_MAT IN(SELECT RA_MAT
		A0001 += "                            FROM " + RetSqlName("SRA")
		A0001 += "                           WHERE RA_FILIAL = '"+xFilial("SRA")+"'
		A0001 += "                             AND RA_CIC = '"+Alltrim(xf_Cpf)+"'
		A0001 += "                             AND ((RA_DEMISSA = '        ') OR ('"+xf_DtLanc+"' <= RA_DEMISSA))
		A0001 += "                             AND '"+xf_DtLanc+"' >= RA_ADMISSA
		A0001 += "                             AND D_E_L_E_T_ = ' ')
		A0001 += "            AND SUBSTRING(RB_YCODPLS,1,3)+SUBSTRING(RB_YCODPLS,5,3)+
		A0001 += "                SUBSTRING(RB_YCODPLS,9,6)+SUBSTRING(RB_YCODPLS,16,2)+
		A0001 += "                SUBSTRING(RB_YCODPLS,19,1) = '"+xf_NumPlan+"'
		A0001 += "            AND D_E_L_E_T_ = ' ') VB_DEP
		TcQuery A0001 ALIAS "A001" NEW
		dbSelectArea("A001")
		dbGoTop()

		rt_Matr := A001->MATRIC
		rt_CCus := A001->CCUSTO
		If Empty(A001->VB_DEP)
			If cEmpAnt == "01"
				rt_Verb := "533"
			ElseIf cEmpAnt == "05"
				rt_Verb := "533"
			EndIf
		Else
			rt_Verb := A001->VB_DEP
		EndIf
		rt_Valo := Val(Alltrim(xf_Valor))

		dbCloseArea("A001")

	EndIf

Return(xFilial("SRA"))

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIAGrQtdEstr  ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 22/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Programa usado para tratar preenchimento do campo G1_QUANT ¦¦¦
¦¦¦          ¦ a partir dos campos G1_YMISTUR e  G1_YUNIDRF na rotina de  ¦¦¦
¦¦¦          ¦ estrutura de produto. Chamado a partir de gatilhos coloca- ¦¦¦
¦¦¦          ¦ dos nos respectivos campos                                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIAGrQtdEstr()

	Local kw_QtdEstr := 0
	Local sfArea := GetArea()

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+cProduto))
	xc_UmPai := SB1->B1_UM
	If SB1->B1_GRUPO $ "PI02/PI03/PI04/PI05/PI06"
		//  Esmaltes - Regra Geral: sempre tem-se as quantidades em parte que pode varias para mais ou para menos que base 100.
		// A formula vem para corrigir para a base 100% de 1Kg.
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+M->G1_COMP))
		If SB1->B1_UM == xc_UmPai .and. SB1->B1_UM == M->G1_YUNIDRF
			If SB1->B1_UM == "KG"
				kw_QtdEstr := M->G1_YMISTUR / M->G1_YQTDREF
			EndIf
		Else
			MsgSTOP("A unidade de medida do componente é diferente da do produto Pai. Favor verificar!!!")
		EndIf

	ElseIf SB1->B1_GRUPO $ "PI01"
		//  Massa - Regra Geral: sempre tem-se os percentuais para formar na base 100% em Kg. É necessário corrigir esta referência para
		// Tonelada, M3 e seus fatores de conversão.
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+M->G1_COMP))
		If SB1->B1_UM == xc_UmPai .and. SB1->B1_UM == M->G1_YUNIDRF
			If SB1->B1_UM == "KG"
				kw_QtdEstr := M->G1_YMISTUR / M->G1_YQTDREF
			EndIf
		Else
			If SB1->B1_UM == xc_UmPai .and. SB1->B1_UM == "T "
				kw_QtdEstr := M->G1_YMISTUR / M->G1_YQTDREF
			ElseIf SB1->B1_UM == "M3"
				kw_QtdEstr := M->G1_YMISTUR / M->G1_YQTDREF / SB1->B1_CONV
			Else
				MsgSTOP("Problema com UNIDADE DE MEDIDA. Favor verificar")
			End
		EndIf
	EndIf

	RestArea(sfArea)

Return ( kw_QtdEstr )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIAGrSqBa     ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 03/11/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Programa usado para gerar sequencia de remessa do banestik ¦¦¦
¦¦¦          ¦ Importante salientar que a expressão:                      ¦¦¦
¦¦¦          ¦                                 AND ZS_MESANO >= '201110'  ¦¦¦
¦¦¦          ¦ porque somente a partir de mes 10 de 2011 que efetivamente ¦¦¦
¦¦¦          ¦ esta rotina foi usada para enviar ao banco Banestes        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIAGrSqBa()

	Local qw_SeqBa := Space(6)

	A0001 := " SELECT MAX(ZS_SEQ) SEQUENC
	A0001 += "   FROM " + RetSqlName("SZS")
	A0001 += "  WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
	A0001 += "    AND ZS_MESANO >= '201110'
	A0001 += "    AND ZS_SEQ <> '      '
	A0001 += "    AND D_E_L_E_T_ = ' '
	TcQuery A0001 ALIAS "A001" NEW
	dbSelectArea("A001")
	dbGoTop()
	qw_SeqBa := Soma1(A001->SEQUENC)
	A001->(dbCloseArea())

Return ( qw_SeqBa )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BWfPDevL      ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 25/11/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Rotina para envio de e-mail automaticamente durante a evo- ¦¦¦
¦¦¦          ¦ lução do processo de Devolução.                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BWfPDevL(xf_NmPrc, xf_AcAtu, xf_DcPar, xf_Actn)

	Local kjfArea := GetArea()
	Local r

	dbSelectArea("Z25")
	dbSetOrder(1)
	If dbSeek(xFilial("Z25")+xf_NmPrc)

		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+Z25->Z25_CODCLI+Z25->Z25_LOJCLI))
		xf_RetMc := IIF(Z25->Z25_RETMRC == "S", "SIM", "NÃO")

		E0001 := ' <html xmlns="http://www.w3.org/1999/xhtml"> '
		E0001 += ' <head> '
		//	E0001 += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		E0001 += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
		E0001 += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> '
		E0001 += ' <title>Untitled Document</title> '
		E0001 += ' <style type="text/css"> '
		E0001 += ' <!-- '
		E0001 += ' .style1 {font-family: Georgia, "Times New Roman", Times, serif } '
		E0001 += ' .style2 {color: #0000FF;font-weight: bold;} '
		E0001 += ' .style7 {font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; } '
		E0001 += ' .style11 {font-family: "Times New Roman", Times, serif; font-size: 16px; } '
		E0001 += ' .style12 {color: #FFFFFF} '
		E0001 += ' --> '
		E0001 += ' </style> '
		E0001 += ' </head> '
		E0001 += ' <body> '
		E0001 += ' <p class="style1">&nbsp;</p> '
		E0001 += ' <p class="style1"><span class="style2">'+Alltrim(SM0->M0_NOMECOM)+'</span></p> '
		E0001 += ' <p class="style1"><span class="style2">Ação Atual:</span> '+xf_AcAtu+'</p> '
		E0001 += ' <p class="style1">&nbsp;</p> '
		E0001 += ' <p class="style1"><span class="style2">Número do Processo:</span> '+Z25->Z25_NUM+'</p> '
		E0001 += ' <p class="style1"><span class="style2">Cliente/Loja:</span> '+Alltrim(SA1->A1_NOME)+'</p> '
		E0001 += ' <p class="style1"><span class="style2">Motivo:</span> '+Alltrim(Z25->Z25_MOTIVO)+'</p> '
		E0001 += ' <p class="style1"><span class="style2">Retorna Mercadoria?</span> '+xf_RetMc+'</p> '
		E0001 += ' <p class="style1"><span class="style2">Orientações:</span> '+Alltrim(Z25->Z25_ORIENT)+'</p> '
		If xf_Actn == 1                                      // Parecer Fiscal
			E0001 += ' <p class="style1"><span class="style2">Parecer Fiscal:</span> '+Alltrim(Z25->Z25_PFISCA)+'</p> '
		EndIf
		E0001 += ' <p class="style1">&nbsp;</p> '

		// Incluído em 20/07/12 em atendimento à OS Effettivo 1343-12
		dbSelectArea("Z26")
		dbSetOrder(1)
		If dbSeek(xFilial("Z26")+xf_NmPrc)
			E0001 += ' <table width="235" border="1" cellspacing="0" bordercolor="#000000"> '
			E0001 += '   <tr> '
			E0001 += '     <th width="76" bordercolor="#000000" bgcolor="#0000FF" scope="col"><div align="center" class="style12"><span class="style7">Serie</span></div></th> '
			E0001 += '     <th width="149" bordercolor="#000000" bgcolor="#0000FF" scope="col"><div align="center" class="style12"><span class="style7">Nota</span></div></th> '
			E0001 += '   </tr> '
			While !Eof() .and. Z26->Z26_FILIAL == xFilial("Z26") .and. Z26->Z26_NUMPRC == xf_NmPrc
				If Z26->Z26_ITEMNF $ "XX/  "
					E0001 += '   <tr> '
					E0001 += '     <td><div align="center" class="style11">'+Alltrim(Z26->Z26_SERIE)+'</div></td> '
					E0001 += '     <td><div align="center" class="style11">'+Alltrim(Z26->Z26_NFISC)+'</div></td> '
					E0001 += '   </tr> '
				EndIf
				dbSelectArea("Z26")
				dbSkip()
			End
			E0001 += ' </table> '
			E0001 += ' <p>&nbsp;</p> '
		EndIf

		If xf_Actn == 0
			E0001 += ' <p class="style1">'+xf_DcPar+'</p> '
		Else
			E0001 += ' <p class="style1">Ao receber este e-mail, favor inserir e/ou verificar o parecer '+xf_DcPar+' a respeito desta estapa do processo.</p> '
		EndIf
		E0001 += ' <p class="style1">&nbsp;</p> '
		E0001 += ' <p class="style1">Fonte/Função: BIAXFUN/BWfPDevL </p> '
		E0001 += ' <p class="style1">&nbsp;</p> '
		E0001 += ' <p class="style1">&nbsp;</p> '
		E0001 += ' </body> '
		E0001 += ' </html> '

		cString := ""
		xLike   := {}

		If xf_Actn == 0                                      // Inclusão de Processo pelo Atendimento envia Financeiro
			cString := Substr(Alltrim(GetMV("MV_YUSDFIN")), 2, Len(Alltrim(GetMV("MV_YUSDFIN")))-2 )

		ElseIf xf_Actn == 1                                      // Parecer Comercial envia para Fiscal
			cString := Substr(Alltrim(GetMV("MV_YUSDFIS")), 2, Len(Alltrim(GetMV("MV_YUSDFIS")))-2 )

		ElseIf xf_Actn == 2                                  // Parecer Fiscal envia para Comercial
			cString := Substr(Alltrim(GetMV("MV_YUSDADM")), 2, Len(Alltrim(GetMV("MV_YUSDADM")))-2 )

		ElseIf xf_Actn == 3                                  // Nota Fiscal de Entrada envia para Expedição e Financeiro
			cString := Substr(Alltrim(GetMV("MV_YUSDEXP")), 2, Len(Alltrim(GetMV("MV_YUSDEXP")))-2 )
			If Right(cString,1) <> '/'
				cString += cString+"/"
			EndIf
			cString += Substr(Alltrim(GetMV("MV_YUSDFIN")), 2, Len(Alltrim(GetMV("MV_YUSDFIN")))-2 )

		ElseIf xf_Actn == 4 .or. xf_Actn == 5                // Parecer da Expedição e/ou Financeiro para Comercial (finalizando)
			cString := Substr(Alltrim(GetMV("MV_YUSDADM")), 2, Len(Alltrim(GetMV("MV_YUSDADM")))-2 )

		End

		If Right(cString,1) <> '/'
			cString := cString+"/"
		EndIf
		While .T.
			nPos := AT("/", cString )
			If nPos > 0
				AADD(xLike, {Substr(cString,1,nPos-1)} )
				cString := Alltrim(Substr(cString,nPos+1,Len(cString)))
			Endif
			If Empty(cString)
				Exit
			EndIf
		End
		xf_DestU := ""
		For r := 1 TO Len(xLike)
			xf_DestU += Alltrim( UsrRetmail(xLike[r][1]) )+";"
		Next r

		df_Dest := xf_DestU
		df_Assu := "Aviso de Ação associada ao Processo de Devolução: "+xf_NmPrc
		df_Erro := "Ocorreu erro durante o envio da mensagem do Processo de Devolução: "+xf_NmPrc
		U_BIAEnvMail(, df_Dest, df_Assu, E0001, df_Erro)

	EndIf

	RestArea(kjfArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BNextSA4      ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 19/12/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Gera novo sequancial para a inclusão de um registro na ta- ¦¦¦
¦¦¦          ¦ bela de Cadastro de Transportadora.                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BNextSA4()

	Local jk_NewA4 := "000001"
	Local kjfArea := GetArea()

	SA4->(dbSetOrder(1))
	If SA4->(dbSeek(xFilial("SA4")+ jk_NewA4))
		While !Eof() .and. SA4->A4_COD == jk_NewA4
			jk_NewA4 := Soma1(jk_NewA4)
			dbSkip()
		End
	EndIf

	RestArea(kjfArea)

Return(jk_NewA4)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIAImpTCV003   ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 30/01/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Programa usado para tratar os campos do arquivo txt para   ¦¦¦
¦¦¦          ¦ importação dos Valores ref uso da Telefonia Celular        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BaTCV003()

	Local qf_Cpf     := Substr(TXT,1,14)
	Local qf_DtLanc  := dtos(Ultimodia(dDataBase))
	Local qf_Valor   := Substr(TXT,15,11)
	Local A0002

	Public qt_Matr := Space(6)
	Public qt_CCus := Space(4)
	Public qt_Verb := Space(3)
	Public qt_Valo := 0
	Public qt_DtLa := stod(qf_DtLanc)

	dbSelectArea("SRA")
	dbSetOrder(5)
	dbSeek(xFilial("SRA") + Alltrim(qf_Cpf) )
	While !Eof() .and. xFilial("SRA") == SRA->RA_FILIAL .and. Alltrim(qf_Cpf) == SRA->RA_CIC
		If Empty(SRA->RA_DEMISSA)
			qt_Matr := SRA->RA_MAT
			qt_CCus := SRA->RA_CC
			qt_Verb := "446"
			qt_Valo := Val(Alltrim(qf_Valor))/100
		EndIf
		dbSelectArea("SRA")
		dbSkip()
	End

Return ( xFilial("SRA") )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIAPesqPD     ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 02/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Rotina para implementação da tela de perquisa padrão para  ¦¦¦
¦¦¦          ¦ retornar um determinado arquivo para consulta padrão       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIAPesqPD(xtExten, xtGrpPer, xtOrdPer, xtVarPer)

	//  Parametros
	// 1 - Extensão de Arquivo
	// 2 - Grupo do Pergunte
	// 2 - Ordem do Pergunte
	// 3 - Variável do Pergunte

	Local cSvAlias		:= Alias()
	Local lAchou		:= .F.
	Local cTipo			:= "Tipo de Documentos(*."+xtExten+")  |*."+xtExten+" | "         //STR0006
	Local cNewPathArq	:= cGetFile( cTipo , "Selecione o arquivo *."+xtExten )           //STR0007

	If !Empty( cNewPathArq )
		If UPPER( Subst( AllTrim( cNewPathArq), - 3 ) ) == Upper( AllTrim( xtExten ) )    //STR0008
			Aviso( "Arquivo Selecionado" , cNewPathArq , { "OK" } )                       //STR0009 --- STR0010
		Else
			MsgAlert( "Arquivo Invalido" )                                                //STR0011
			Return
		EndIf
	Else
		Aviso("Cancelada a Selecao!" ,{ "OK" } )                                          //STR0012 --- STR0010
		Return
	EndIF

	//Limpa o Parametro para a Carga do novo conteúdo
	dbSelectArea("SX1")
	If lAchou := ( SX1->( dbSeek( xtGrpPer + xtOrdPer , .T. ) ) )
		RecLock("SX1",.F.,.T.)
		SX1->X1_CNT01 := Space( Len( SX1->X1_CNT01 ) )
		&xtVarPer := cNewPathArq
		MsUnLock()
	EndIf
	dbSelectArea( cSvAlias )

Return( .T. )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIABxEmp      ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 20/04/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦  Personalização para a Baixa de Empenho das Ordens de Pro- ¦¦¦
¦¦¦          ¦ dução em substituição a rotina padrão que necessita de pe- ¦¦¦
¦¦¦          ¦ lo menos um apontamento de produção para a baixa, além de  ¦¦¦
¦¦¦          ¦ ser necessário entrar na rotina de apontamento (Produção)  ¦¦¦
¦¦¦          ¦ para efetuar o encerramento.                               ¦¦¦
¦¦¦          ¦  Com esta nova rotina, de qualquer ponto do sistema, tendo ¦¦¦
¦¦¦          ¦ ou não apontamento, o Ordem de Produção poderá ser encerra-¦¦¦
¦¦¦          ¦ da. O encerramento de uma OP no padrão é feito pela rotina ¦¦¦
¦¦¦          ¦ MATA250.                                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIABxEmp(kj_NumOP, jkTipoX)

	Local rt

	aVtNOp := {}
	xfBxEmp := .F.

	Q0001 := " SELECT D4_OP,
	Q0001 += "        D4_COD,
	Q0001 += "        D4_LOCAL,
	Q0001 += "        D4_QUANT,
	Q0001 += "        D4_QTSEGUM,
	Q0001 += "        D4_OPORIG,
	Q0001 += "        R_E_C_N_O_ REGSD4
	Q0001 += "   FROM " + RetSqlName("SD4")
	Q0001 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"'
	If jkTipoX == "PA"
		Q0001 += "    AND ( SUBSTRING(D4_OP,1,6) = '"+kj_NumOP+"'
	Else
		Q0001 += "    AND ( D4_OP = '"+kj_NumOP+"'
	EndIf
	Q0001 += "          OR D4_OP IN(SELECT D4_OPORIG
	Q0001 += "                        FROM " + RetSqlName("SD4")
	Q0001 += "                       WHERE D4_FILIAL = '"+xFilial("SD4")+"'
	If jkTipoX == "PA"
		Q0001 += "                         AND SUBSTRING(D4_OP,1,6) = '"+kj_NumOP+"'
	Else
		Q0001 += "                         AND D4_OP = '"+kj_NumOP+"'
	EndIf
	Q0001 += "                         AND D4_OPORIG <> ' '
	Q0001 += "                         AND D_E_L_E_T_ = ' ') )
	//Q0001 += "    AND D4_QUANT <> 0
	Q0001 += "    AND D_E_L_E_T_ = ' '
	Q0001 += "  ORDER BY D4_OP, R_E_C_N_O_
	TcQuery Q0001 ALIAS "Q001" NEW
	dbSelectArea("Q001")
	dbGoTop()
	While !Eof()

		If !aScan(aVtNOp, {|x| x[1] == Q001->D4_OP }) > 0
			Aadd(aVtNOp, { Q001->D4_OP })
		EndIf

		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2") + Q001->D4_COD + Q001->D4_LOCAL)
			RecLock("SB2",.F.)
			SB2->B2_QEMP   -= Q001->D4_QUANT
			SB2->B2_QEMP2  -= Q001->D4_QTSEGUM
			If !Empty(Q001->D4_OPORIG)
				SB2->B2_SALPEDI -= Q001->D4_QUANT
			EndIf
			MsUnLock()
		EndIf

		dbSelectArea("SD4")
		dbGoTo(Q001->REGSD4)
		RecLock("SD4",.F.)
		SD4->D4_QUANT   := 0
		SD4->D4_QTSEGUM := 0
		MsUnLock()

		xfBxEmp := .T.

		dbSelectArea("Q001")
		dbSkip()
	End
	Q001->(dbCloseArea())

	If Len(aVtNOp) == 0
		dbSelectArea("SC2")
		dbSetOrder(1)
		If dbSeek(xFilial("SC2") + kj_NumOP)
			RecLock("SC2",.F.)
			SC2->C2_DATRF = dDataBase
			MsUnLock()
			xfBxEmp := .T.
		EndIf
	Else
		For rt := 1 To Len(aVtNOp)
			dbSelectArea("SC2")
			dbSetOrder(1)
			If dbSeek(xFilial("SC2") + aVtNOp[rt][1])
				RecLock("SC2",.F.)
				SC2->C2_DATRF = dDataBase
				MsUnLock()
			EndIf
		Next rt
	EndIf

Return ( xfBxEmp )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BAGtEmpr      ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 23/04/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦  Monta Vetor para as empresas que irão fazer parte de de-  ¦¦¦
¦¦¦          ¦ terminado processamento do Workflow                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BAGtEmpr(kj_Empr)

	Local akEmp := {}
	Local gbAreAtu := GetArea()
	Local _aSm0	:=	{}
	Local _nI

	If ( select("SM0") == 0 )
		OpenSM0()
	EndIf

	_aSm0	:=	FWLoadSM0()

	For _nI	:=	1 to Len(_aSM0)

		If !Empty(_aSM0[_nI,SM0_EMPRESA])
			If _aSM0[_nI,SM0_EMPRESA] $ kj_Empr
				If _aSM0[_nI,SM0_FILIAL] == '01' .or. _aSM0[_nI,SM0_EMPRESA] == '06'
					aadd(akEmp ,{ _aSM0[_nI,SM0_EMPRESA], _aSM0[_nI,SM0_FILIAL] })
				EndIf
			EndIf
		Else
			If _aSM0[_nI,SM0_GRPEMP] $ kj_Empr
				If _aSM0[_nI,SM0_FILIAL] == '01' .or. _aSM0[_nI,SM0_GRPEMP] == '06'
					aadd(akEmp ,{ _aSM0[_nI,SM0_GRPEMP], _aSM0[_nI,SM0_FILIAL] })
				EndIf
			EndIf
		EndIf
	Next

	SM0->(DBCLOSEAREA())
	RestArea( gbAreAtu )

Return akEmp

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BGtRJFUN      ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 10/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦  Gatilho para alertar ao digitador que a função nova que se¦¦¦
¦¦¦          ¦ está cadastrando deve ser informada às contabilidade.      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BGtRJFUN()

	MsgALERT("Verifique se a FUNÇÃO criada é do ADMINISTRATIVO, caso POSITIVO informe à CONTABILIDADE para atualização do RATEIO da FOLHA!!!","Atenção. (BIAXFUN)")

Return ( M->RJ_FUNCAO )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BGtCvtQt      ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 26/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦  Gatilho para verificar se a quantidade digitada é menor   ¦¦¦
¦¦¦          ¦ que a quantidade do fator de conversão. Isto passou a ser  ¦¦¦
¦¦¦          ¦ necessário a partir do momento que colocamos a baixa de    ¦¦¦
¦¦¦          ¦ EMBALAGEM automática. Como as quantidades eram muito baixas¦¦¦
¦¦¦          ¦ fazia-se necessário um quantidade minima para explosão do  ¦¦¦
¦¦¦          ¦ empenho                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BGtCvtQt()

	Local hQuant := M->C2_QUANT

	If SB1->B1_TIPO == "PA"
		If hQuant < SB1->B1_CONV
			Help(" ",1,"Atenção (BGtCvtQt)",, "Quantidade Original na 1a. Unidade: "+str(M->C2_QUANT,10,2)+", alterada para "+str(SB1->B1_CONV,10,2),1,0)
			hQuant := SB1->B1_CONV
		EndIf
	EndIf

Return ( hQuant )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIAEstNeg     ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 30/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦  A partir da função padrão M-Messeger que verifica se o es-¦¦¦
¦¦¦          ¦ toque ficará negativo, será retornada uma varíavel dizendo ¦¦¦
¦¦¦          ¦ que o estoque ficará negativo e que a rotina de importação ¦¦¦
¦¦¦          ¦ será interrompida                                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIAEstNeg()

	dDescrAdc := ""

	If Alltrim(FunName()) == "BIA292" .and. 1 = 2

		//lVerifEstNg := .T.
		//dDescrAdc := "O documento que deixou o estoque negativo foi: "+SD3->D3_DOC+" e o produto: " + Alltrim(SD3->D3_COD) + " . Será necessário excluir o apontamento, em seguida acertar o estoque do produto que apresentou o saldo negativo e colocar a rotina de importação novamente." + CHR(13) + CHR(13)
		//dDescrAdc += "Verificar também, produto:" + Alltrim(SB2->B2_COD) + ", quant1: " + Alltrim(Str(SB2->B2_QATU)) + ", quant2: " + Alltrim(Str(SB2->B2_QTSEGUM))
		//If !(SB2->B2_QATU < 0 .or. SB2->B2_QTSEGUM < 0)
		//	lVerifEstNg := .F.
		//	dDescrAdc   := "Apenas um ALERTA: " + dDescrAdc
		//EndIf

		dDescrAdc := ""
		aSaldo    := CalcEst( SB2->B2_COD, SB2->B2_LOCAL, xDataPSaldo )
		nSaldo    := aSaldo[1]
		If nSaldo < 0
			dDescrAdc += "O produto "+ Alltrim(SB2->B2_COD) + " local " + Alltrim(SB2->B2_LOCAL) + ", apresentou saldo negativo ("+Alltrim(Str(nSaldo))+") na passagem do dia " + dtoc(xDataPSaldo-1) + " para o dia " +dtoc(xDataPSaldo) + ". Gere o kardex do dia " + dtoc(xDataPSaldo-1) + " e verifique como corrigir o saldo para dar seguimento na importação da produção."
			lVerifEstNg := .F.
		EndIf

		If SB2->B2_QATU < 0 .or. SB2->B2_QTSEGUM < 0
			dDescrAdc += "O produto "+ Alltrim(SB2->B2_COD) + " local " + Alltrim(SB2->B2_LOCAL) + ", apresentou saldo negativo nesta data."
			lVerifEstNg := .F.
		EndIf

	EndIf

Return ( dDescrAdc )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BX7ITCTA      ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 26/12/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦  Gatilho para preenchimento do campo D1_ITEMCTA a partir   ¦¦¦
¦¦¦          ¦ do campo D1_COD para atender ao projeto de contabilização  ¦¦¦
¦¦¦          ¦ PROVISÃO DA COMISSÃO                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function Bx7ItCta()

	Local x7ItemCt := Gdfieldget("D1_ITEMCTA",n)

	If Alltrim(SB1->B1_YCTRADM) == "21106003"
		TR001 := " SELECT TOP 1 A3_COD
		TR001 += "   FROM " + RetSqlName("SA3")
		TR001 += "  WHERE A3_FILIAL = '"+xFilial("SA3")+"'
		TR001 += "    AND A3_FORNECE = '"+cA100For+"'
		TR001 += "    AND A3_LOJA = '"+cLoja+"'
		TR001 += "    AND A3_YATIVO = 'S'
		TR001 += "    AND D_E_L_E_T_ = ' '
		TcQuery TR001 New Alias "TR01"
		dbSelectArea("TR01")
		dbGoTop()
		x7ItemCt := "COM"+TR01->A3_COD
		TR01->(dbCloseArea())
	EndIf

Return ( x7ItemCt )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BCt5ClVl      ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 27/12/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦  Gatilho para preenchimento da Classe de Valor para o lan- ¦¦¦
¦¦¦          ¦ çamento contábil 610-021,022,023,024,025                   ¦¦¦
¦¦¦          ¦ PROVISÃO DA COMISSÃO                                       ¦¦¦
¦¦¦          ¦ A partir de 30/01/13 a rotina BIA497 passou a usar a mesma ¦¦¦
¦¦¦          ¦ condição que a definida aqui. Porém tive que reescrevê-la. ¦¦¦
¦¦¦          ¦ Ajustes futuros deverão ser feitos nas duas rotinas        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BCt5ClVl()

	Local xcCLVL := ""
	Local xcLpad := Paramixb

	If cEmpAnt == "01"

		//xcCLVL := "2100"

		If SF2->F2_SERIE == "1  "
			xcCLVL := "2105"
		ElseIf SF2->F2_SERIE == "2  "
			xcCLVL := "2200"
		ElseIf SF2->F2_SERIE == "4  "
			xcCLVL := "2106"
		EndIf


		/* Conforme discução entre Claudeir / Robert / Marcos Alberto Soprani. Implementado em 09/01/13 */
		If &("SF2->F2_VEND"+xcLpad) == "200005"
			xcCLVL := "2113"
		EndIf

	ElseIf cEmpAnt == "05"

		If SF2->F2_SERIE == "1  "
			xcCLVL := "2200"
		ElseIf SF2->F2_SERIE == "2  "
			xcCLVL := "2210"
		EndIf

	ElseIf cEmpAnt == "07"

		//(Thiago Dantas - 25/02/15) -> OS 0866-15
		
		If AllTrim(SF2->F2_SERIE) == "1"
			xcCLVL := "2150"
			
			//Ticket 26656 - Solicitação Jean: Venda na empresa LM filial 05 será lançada na CV 2302
			if(cFilAnt == "05")
				xcCLVL := "2302"
			endif
			
			// Por Marcos Alberto Soprani - OS 2708-15 em 18/08/15
		ElseIf AllTrim(SF2->F2_SERIE) $ "2_4"
			xcCLVL := "2250"
		ElseIf AllTrim(SF2->F2_SERIE) == "3"
			xcCLVL := "2251"
		ElseIf AllTrim(SF2->F2_SERIE) == "6"
			xcCLVL := "2170"
		ElseIf AllTrim(SF2->F2_SERIE) == "7"
			xcCLVL := "2302"	
		EndIf

	ElseIf cEmpAnt == "13"

		If AllTrim(SF2->F2_SERIE) == "2"
			xcCLVL := "2301"
		EndIf

	ElseIf cEmpAnt == "14"

		xcCLVL := "2500"

	EndIf

Return ( xcCLVL )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BDevNfCOM     ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 27/12/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦  Função para recuperação do Valor e Item Contábil durante  ¦¦¦
¦¦¦          ¦ a contabilização do estorno de uma nota fiscal de entrada  ¦¦¦
¦¦¦          ¦ em devolução de vendas.                                    ¦¦¦
¦¦¦          ¦ PROVISÃO DA COMISSÃO                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BDevNfCOM()

	Local    gpAreaAtu := GetArea()
	Local    xcLpad    := Paramixb
	Private  gpVlrComs := 0
	Public   gpCodItem := Space(9)
	Public   gpCodCLVL := Space(9)

	If SD1->D1_TIPO = "D" .and. dtos(SF1->F1_DTDIGIT) >= "20130101"

		dbSelectArea("SF2")
		dbSetOrder(1)
		If dbSeek(xFilial("SF2")+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA)

			gpCodCLVL := ExecBlock("BCt5ClVl",.F.,.F.,xcLpad)
			// Foi necessário retirar esta condição e incluida a condição acima (dtos(SF1->F1_DTDIGIT) >= "20130101") por entender que o estorno da comissão deve existir a qualquer tempo, pois em 31/12/12
			// existia uma provisão em aberto
			If /*dtos(SF2->F2_EMISSAO) >= "20130101" .and.*/ !Empty(&("SF2->F2_VEND"+xcLpad)) .and. &("SF2->F2_VEND"+xcLpad) <> "999999"

				gpCodItem := "COM"+&("SF2->F2_VEND"+xcLpad)
				dbSelectArea("SD2")
				dbSetOrder(3)
				If dbSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD+SD1->D1_ITEMORI)

					If !SD2->D2_TIPO $ "B/D"

						SF4->(dbSetOrder(1))
						SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
						If SF4->F4_DUPLIC == "S"
							gpVlrComs := SD1->D1_TOTAL * &("SD2->D2_COMIS"+xcLpad) / 100
						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(gpAreaAtu)

Return ( gpVlrComs )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BValComFat    ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 19/04/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦  Função para calcular o valor da provisão da comissão para ¦¦¦
¦¦¦          ¦ contabilização. Foi necessário implementar esta função para¦¦¦
¦¦¦          ¦ tratamento via TES que gera ou não duplicata               ¦¦¦
¦¦¦          ¦ PROVISÃO DA COMISSÃO                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BValComFat()

	Local    gpAreaAtu := GetArea()
	Local    xcLpad    := Paramixb
	Private  gpVlrComs := 0

	If !SD2->D2_TIPO $ "B/D" .and. dtos(SF2->F2_EMISSAO) >= "20130101" .and. !Empty(&("SF2->F2_VEND"+xcLpad)) .and. &("SF2->F2_VEND"+xcLpad) <> "999999"

		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
		If SF4->F4_DUPLIC == "S"
			gpVlrComs := SD2->D2_TOTAL * &("SD2->D2_COMIS"+xcLpad) / 100
		EndIf

	EndIf

	RestArea(gpAreaAtu)

Return ( gpVlrComs )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BiaCtbAV      ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 30/01/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦  Rotina desenvolvida para contabilizações avulsas diversas ¦¦¦
¦¦¦          ¦ Ela recebe um vetor contendo as informações necessárias    ¦¦¦
¦¦¦          ¦ para a montagem do lançamento, como por exemplo conta deb. ¦¦¦
¦¦¦          ¦ conta cred., valor, centro de custo, histórico, etc.       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BiaCtbAV()

	Local nreg
	Local hj

	Private hj
	Private LCABECALHO, CPADRAO, LPADRAO, NTOTAL, CLOTE, LDIGITA
	Private LAGLUT, CARQUIVO, AROTINA, NHDLPRV, aFlagCTB
	Private cdeb, ccred, chis, nval, cult

	Public aArrayCt

	Public msVthj01
	Public msVthj02
	Public msVthj03
	Public msVthj04
	Public msVthj05
	Public msVthj06
	Public msVthj07
	Public msVthj08
	Public msVthj09
	Public msVthj10
	Public msVthj11
	Public msVthj12
	Public msVthj13

	lCabecalho := .F.
	cPadrao    := fgLanPad
	lPadrao    := .F.
	nTotal     := 0
	clote      := fgLotCtb
	lDigita    := fgPermDg
	lAglut     := .F.
	carquivo   := ""
	aRotina    := {}
	aArrayCt   := fgVetCtb
	aFlagCTB   := {}

	c_contad   := 0
	For hj := 1 to Len(aArrayCt)

		c_contad ++
		lPadrao := VerPadrao( cPadrao )

		If lPadrao

			If !lCabecalho
				a370Cabecalho(@nHdlPrv,@cArquivo)
			Endif

			msVthj01 := aArrayCt[hj][1]
			msVthj02 := aArrayCt[hj][2]
			msVthj03 := aArrayCt[hj][3]
			msVthj04 := aArrayCt[hj][4]
			msVthj05 := aArrayCt[hj][5]
			msVthj06 := aArrayCt[hj][6]
			msVthj07 := aArrayCt[hj][7]
			msVthj08 := aArrayCt[hj][8]
			msVthj09 := aArrayCt[hj][9]
			msVthj10 := aArrayCt[hj][10]
			msVthj11 := aArrayCt[hj][11]
			msVthj12 := IIF( Len(aArrayCt[hj]) >= 12, aArrayCt[hj][12], "")
			msVthj13 := IIF( Len(aArrayCt[hj]) >= 13, aArrayCt[hj][13], "")

			nTotal  := nTotal + DetProva(nHdlPrv, cPadrao, "BiaCtbAV", cLote )
			cult := .F.

		EndIf

		If c_contad == 997

			c_contad := 0
			c := 2
			//Exit

			**********************************************************
			If lCabecalho
				RodaProva(nHdlPrv,nTotal)
			Endif

			If lPadrao
				cA100Incl(cArquivo ,nHdlPrv ,3,cLote ,lDigita , lAglut  )
			End

			If cult == .F.
				fbCont()
			EndIf

		EndIf

	Next hj

	If lCabecalho
		RodaProva(nHdlPrv,nTotal)
	Endif

	If lPadrao
		cA100Incl(cArquivo ,nHdlPrv ,3,cLote ,lDigita , lAglut  )
	End

	If cult == .F.
		fbCont()
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fbCont        ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 30/01/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fbCont()

	If lCabecalho
		RodaProva(nHdlPrv,nTotal)
	Endif
	If lPadrao
		cA100Incl(cArquivo ,nHdlPrv ,3,cLote ,lDigita , lAglut  )
	End

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ xConvLog ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17.04.12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Converter log de Erro em texto simples                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xCon1Log(aAutoErro)

	Local cRet := ""
	Local nX   := 1

	For nX := 1 to Len(aAutoErro)
		cRet += aAutoErro[nX] + CHR(13)+CHR(13)
	Next nX

Return cRet

USER FUNCTION XCONVELOG(aAutoErro)
	LOCAL cRet := ""
	LOCAL nX := 1

	FOR nX := 1 to Len(aAutoErro)
		cRet += aAutoErro[nX]+CRLF
	NEXT nX
RETURN cRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BACERTB9 ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 04.01.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Rotina para acertar CUSTO DE VIRADA DE ESTOQUE ERRADOS     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BACERTB9()

	dtRfIni := ctod("01/12/12")
	dtRfFim := ctod("31/12/12")

	A0001 := " SELECT D3_COD, D3_LOCAL
	A0001 += "   FROM SD3010
	A0001 += "  WHERE D3_FILIAL = '01'
	A0001 += "    AND D3_EMISSAO BETWEEN '"+dtos(dtRfIni)+"' AND '"+dtos(dtRfFim)+"'
	A0001 += "    AND D3_CF IN('DE4','RE4')
	A0001 += "    AND D3_COD BETWEEN '1' AND 'A'

	A0001 += "      AND D3_COD IN('2050158        ','2170034        ','2061868        ','2130002        ','2061067        ','2171494        ','2170092        ','2110016        ')
	A0001 += "      AND D3_LOCAL = '6B'

	A0001 += "    AND D_E_L_E_T_ = ' '
	A0001 += "  GROUP BY D3_COD, D3_LOCAL
	TCQUERY A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGotop()
	ProcRegua(RecCount())
	t_Contad := 0
	While !Eof()
		t_Contad ++
		IncProc("Processando.... "+Alltrim(Str(t_Contad)))

		dbSelectArea("SB9")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SB9")+A001->D3_COD+A001->D3_LOCAL+dtos(dtRfFim))
			RecLock("SB9",.F.)
			Delete
			MsUnLock()
		EndIf

		aSaldos := CalcEst(A001->D3_COD,A001->D3_LOCAL,dtRfFim+1)
		nQuant  := aSaldos[1]
		nCusto  := aSaldos[2]

		dbSelectArea("SB9")
		dbSetOrder(1)
		If !dbSeek(xFilial("SB9")+A001->D3_COD+A001->D3_LOCAL+dtos(dtRfFim))
			RecLock("SB9",.T.)
			SB9->B9_FILIAL  := xFilial("SB9")
			SB9->B9_COD     := A001->D3_COD
			SB9->B9_LOCAL   := A001->D3_LOCAL
			SB9->B9_DATA    := dtRfFim
			SB9->B9_QINI    := nQuant
			SB9->B9_VINI1   := nCusto
			MsUnLock()
		EndIf

		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+A001->D3_COD+A001->D3_LOCAL)
			RecLock("SB2",.F.)
			SB2->B2_VFIM1 := nCusto
			MsUnLock()
		EndIf

		dbSelectArea("A001")
		dbSkip()
	End

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BCustPAB9 ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 14.01.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Rotina para acertar CUSTO DE VIRADA DE PA 31/12/12         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BCustPAB9()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	dtRfFim := ctod("31/12/12")

	// A partir do Mes de Junho de 2012, ler a tabela SB9
	xcTab := "\bkp_Marcos\"+cEmpAnt+"_DEZ12"
	dbUseArea(.T.,,xcTab+".DBF","SB9PA",.F.)
	dbCreateIndex(xcTab+".NTX","B9_COD",{|| B9_COD })
	dbSelectArea("SB9PA")
	dbGoTop()
	ProcRegua(RecCount())
	t_Contad := 0
	While !Eof()
		t_Contad ++
		IncProc("Processando.... "+Alltrim(Str(t_Contad)))

		dbSelectArea("SB9")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SB9")+SB9PA->B9_COD+SB9PA->B9_LOCAL+dtos(dtRfFim))
			RecLock("SB9",.F.)
			Delete
			MsUnLock()
		EndIf

		aSaldos := CalcEst(SB9PA->B9_COD, SB9PA->B9_LOCAL, dtRfFim+1)
		nQuant  := aSaldos[1]
		nCusto  := aSaldos[2]

		nCustoNv := SB9PA->N_B9_VINI1 //nQuant * SB9PA->N_B9_CM1
		nDifCust := nCustoNv - nCusto

		If nDifCust <> 0

			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+SB9PA->B9_COD)

			dbSelectArea("SD3")
			RecLock("SD3",.T.)
			SD3->D3_FILIAL  := xFilial("SD3")
			SD3->D3_TM      := IIF(nDifCust > 0, "014", "514")
			SD3->D3_COD     := SB1->B1_COD
			SD3->D3_UM      := SB1->B1_UM
			SD3->D3_QUANT   := 0
			SD3->D3_QTSEGUM := 0
			SD3->D3_CF      := IIF(nDifCust > 0, "DE6", "RE6")
			SD3->D3_LOCAL   := SB9PA->B9_LOCAL
			SD3->D3_DOC     := "AJT201212"
			SD3->D3_NUMSEQ  := ProxNum()
			SD3->D3_EMISSAO := dtRfFim
			SD3->D3_GRUPO   := SB1->B1_GRUPO
			SD3->D3_TIPO    := SB1->B1_TIPO
			SD3->D3_CHAVE   := "E0"
			SD3->D3_USUARIO := cUserName
			SD3->D3_SEGUM   := SB1->B1_SEGUM
			SD3->D3_CUSTO1  := ABS(nDifCust)
			SD3->D3_YROM    := "N"
			SD3->D3_YCHAVE  := ''
			SD3->D3_CONTA   := SB1->B1_YCTRIND
			SD3->D3_CC      := "3000"
			SD3->D3_CLVL    := IIF(cEmpAnt == "05", "3200", "3100")
			MsUnLock()
			DbCommitAll()

		EndIf

		aSaldos := CalcEst(SB9PA->B9_COD,SB9PA->B9_LOCAL,dtRfFim+1)
		nQuant  := aSaldos[1]
		nCusto  := aSaldos[2]

		dbSelectArea("SB9")
		dbSetOrder(1)
		If !dbSeek(xFilial("SB9")+SB9PA->B9_COD+SB9PA->B9_LOCAL+dtos(dtRfFim))
			RecLock("SB9",.T.)
			SB9->B9_FILIAL  := xFilial("SB9")
			SB9->B9_COD     := SB9PA->B9_COD
			SB9->B9_LOCAL   := SB9PA->B9_LOCAL
			SB9->B9_DATA    := dtRfFim
			SB9->B9_QINI    := nQuant
			SB9->B9_QISEGUM := ConvUm(SB9PA->B9_COD, nQuant, 0, 2)
			SB9->B9_VINI1   := nCusto
			SB9->B9_CM1     := nCusto / nQuant
			SB9->B9_MCUSTD  := "1"
			MsUnLock()
		EndIf

		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+SB9PA->B9_COD+SB9PA->B9_LOCAL)
			RecLock("SB2",.F.)
			SB2->B2_VFIM1 := nCusto
			MsUnLock()
		EndIf

		dbSelectArea("SB9PA")
		dbSkip()

	End
	SB9PA->(dbCloseArea())

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ VERLOGFL  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 18.01.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Log de Cálculo Personalizado da Folha                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function VERLOGFL()

	Local xVerLog
	Local xGetDdList
	Local cGetDdList := "Resultado do processamento da Folha quanto ao Líquido ZERADO:" + CRLF + CRLF

	//If Upper(Alltrim(FunName())) == "GPEM690"
	Return
	//EndIf

	RF007 := " SELECT RA_MAT,
	RF007 += "        RA_CC,
	RF007 += "        RA_NOME,
	RF007 += "        RA_SITFOLH,
	RF007 += "        (SELECT COUNT(*)
	RF007 += "           FROM "+RetSqlName("SRC")
	RF007 += "          WHERE RC_FILIAL = RA_FILIAL
	RF007 += "            AND RC_MAT = RA_MAT
	RF007 += "            AND RC_PD = '799'
	RF007 += "            AND D_E_L_E_T_ = ' ') CONTAD
	RF007 += "   FROM "+RetSqlName("SRA")+" SRA
	RF007 += "  WHERE RA_FILIAL BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"'
	RF007 += "    AND RA_CC BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
	RF007 += "    AND RA_MAT BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'
	RF007 += "    AND RA_SITFOLH <> 'D'
	RF007 += "    AND RA_CATFUNC <> 'A'
	RF007 += "    AND SRA.D_E_L_E_T_ = ' '
	TCQUERY RF007 New Alias "RF07"
	dbSelectArea("RF07")
	dbGotop()
	ProcRegua(RecCount())
	xfContad := 0
	While !Eof()
		IncProc("Processando Log.... ")

		If RF07->CONTAD == 0
			cGetDdList += RF07->RA_MAT + " - " + RF07->RA_NOME + " C.Custo: "+ Alltrim(RF07->RA_CC) + " SitFolh: "+ RF07->RA_SITFOLH + CRLF
			xfContad ++
		EndIf

		dbSelectArea("RF07")
		dbSkip()
	End
	RF07->(dbCloseArea())

	If xfContad == 0
		cGetDdList += "Nenhum funcionário está com o LIQUIDO zerado!!!"
	EndIf
	cGetDdList += CRLF + CRLF + "Tecle < Esc > para sair"

	DEFINE MSDIALOG xVerLog TITLE "Log de Processamento da Folha" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

	@ 015, 005 GET xGetDdList VAR cGetDdList OF xVerLog MULTILINE SIZE 243, 220 COLORS 0, 16777215 HSCROLL PIXEL

	ACTIVATE MSDIALOG xVerLog

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BGER0MOD  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 28.01.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BGER0MOD()

	prFiltTM := "710"
	fTMMod   := "499"
	fCFMod   := "DE1"

	A0001 := " SELECT *
	A0001 += "   FROM SD3010 SD3
	A0001 += "  WHERE D3_FILIAL = '01'
	A0001 += "    AND D3_EMISSAO BETWEEN '20130101' AND '20130131'
	A0001 += "    AND D3_TIPO = 'PA'
	A0001 += "    AND D3_TM IN('"+prFiltTM+"')
	A0001 += "    AND (SELECT COUNT(*)
	A0001 += "           FROM SD3010 XD3
	A0001 += "          WHERE D3_FILIAL = '01'
	A0001 += "            AND D3_NUMSEQ = SD3.D3_NUMSEQ
	A0001 += "            AND D3_COD IN('MODAPRPRM2     ')
	A0001 += "            AND D_E_L_E_T_ = ' ') = 0
	A0001 += "    AND D_E_L_E_T_ = ' '
	TCQUERY A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGotop()
	While !Eof()

		SC2->(dbSetOrder(1))
		SC2->(dbSeek(xFilial("SC2")+A001->D3_OP))
		az_clvl := IIF(cEmpAnt == "01", "3100", IIF(cEmpAnt == "05", "3200", ""))
		az_NmDoc := A001->D3_DOC
		az_NmSeq := A001->D3_NUMSEQ
		az_QtdPd := A001->D3_QUANT           // Variável para o Ponto de Entrada A250ETRAN
		az_Prodt := A001->D3_COD             // Variável para o Ponto de Entrada A250ETRAN
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+az_Prodt))
		az_TipPr := SB1->B1_TIPO             // Variável para o Ponto de Entrada A250ETRAN
		az_Pesol := SB1->B1_PESO             // Variável para o Ponto de Entrada A250ETRAN
		az_DtEms := stod(A001->D3_EMISSAO)   // Variável para o Ponto de Entrada A250ETRAN
		az_GrpPr := SB1->B1_GRUPO            // Variável para o Ponto de Entrada A250ETRAN
		az_Ident := A001->D3_IDENT           // Variável para o Ponto de Entrada A250ETRAN
		az_TM    := fTMMod                   // Variável para o Ponto de Entrada A250ETRAN - incluida em 28/01/13
		az_CF    := fCFMod                   // Variável para o Ponto de Entrada A250ETRAN - incluida em 28/01/13
		U_A250ETRAN()                        // Ponto de entrada padrão do sistema que foi aproveitado para não gerar um outro código fonte exigindo manutenção em códigos diferentes.

		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BAjtVrPI  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 07.02.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Rotina para ZERAR saldo de PI em 31/12/12 e gerar movimen- ¦¦¦
¦¦¦          ¦ tação referente ao saldo de virada no primeiro dia de 2013 ¦¦¦
¦¦¦          ¦ pois somente a partir de 01/01/13 é que o PI passa a ser   ¦¦¦
¦¦¦          ¦ controlado como produto contabilizável                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BAjtVrPI()

	Processa({|| RptZDetail()})

Return

Static Function RptZDetail()

	dtRfFim := ctod("  /  /  ")

	HV004 := " SELECT B9_COD,
	HV004 += "        B9_LOCAL,
	HV004 += "        B9_QINI,
	HV004 += "        B9_QISEGUM,
	HV004 += "        B9_VINI1
	HV004 += "   FROM "+RetSqlName("SB9")+" SB9
	HV004 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '  '
	HV004 += "                       AND B1_COD = B9_COD
	HV004 += "                       AND B1_TIPO = 'PI'
	HV004 += "                       AND SB1.D_E_L_E_T_ = ' '
	HV004 += "  WHERE B9_FILIAL = '01'
	HV004 += "    AND B9_DATA = '"+dtos(dtRfFim)+"'
	HV004 += "    AND ( B9_QINI <> 0 OR B9_VINI1 <> 0 )
	HV004 += "    AND SB9.D_E_L_E_T_  = ' '
	TCQUERY HV004 New Alias "HV04"
	dbSelectArea("HV04")
	dbGoTop()
	ProcRegua(RecCount())
	t_Contad := 0
	While !Eof()
		t_Contad ++
		IncProc("Processando.... "+Alltrim(Str(t_Contad)))

		// Apaga virada de estoque
		dbSelectArea("SB9")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SB9")+HV04->B9_COD+HV04->B9_LOCAL+dtos(dtRfFim))
			RecLock("SB9",.F.)
			Delete
			MsUnLock()
		EndIf

		// Gera registro no Kardex para justificar o zeramento do estoque na virada. Se for maior, deve-se requisitar, se menor, devolver.
		// Apura novo saldo (qtd e valor) para MOVIMENTO
		aSaldos := CalcEst(HV04->B9_COD,HV04->B9_LOCAL,dtRfFim+1)
		nQuant1  := aSaldos[1]
		nCusto1  := aSaldos[2]
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+HV04->B9_COD)
		***********************************
		dbSelectArea("SD3")
		RecLock("SD3",.T.)
		SD3->D3_FILIAL  := xFilial("SD3")
		SD3->D3_TM      := IIF(nQuant1 < 0, "120", "720")
		SD3->D3_COD     := SB1->B1_COD
		SD3->D3_UM      := SB1->B1_UM
		SD3->D3_QUANT   := ABS(nQuant1)
		SD3->D3_QTSEGUM := ABS(nQuant1)
		SD3->D3_CUSTO1  := IIF(nQuant1 < 0 .and. nCusto1 < 0, ABS(nCusto1), nCusto1)
		SD3->D3_CF      := IIF(nQuant1 < 0, "DE0", "RE0")
		SD3->D3_LOCAL   := HV04->B9_LOCAL
		SD3->D3_DOC     := "ZERPI3112"
		SD3->D3_NUMSEQ  := ProxNum()
		SD3->D3_EMISSAO := dtRfFim
		SD3->D3_GRUPO   := SB1->B1_GRUPO
		SD3->D3_TIPO    := SB1->B1_TIPO
		SD3->D3_CHAVE   := "E0"
		SD3->D3_USUARIO := cUserName
		SD3->D3_SEGUM   := SB1->B1_SEGUM
		SD3->D3_YROM    := "N"
		SD3->D3_YCHAVE  := ''
		SD3->D3_CONTA   := SB1->B1_YCTRIND
		SD3->D3_CC      := "3000"
		SD3->D3_CLVL    := IIF(cEmpAnt == "05", "3200", "3100")
		MsUnLock()
		DbCommitAll()

		// Apura novo saldo (qtd e valor) para nova virada
		aSaldos := CalcEst(HV04->B9_COD,HV04->B9_LOCAL,dtRfFim+1)
		nQuant  := aSaldos[1]
		nCusto  := aSaldos[2]
		*********************
		dbSelectArea("SB9")
		dbSetOrder(1)
		If !dbSeek(xFilial("SB9")+HV04->B9_COD+HV04->B9_LOCAL+dtos(dtRfFim))
			RecLock("SB9",.T.)
			SB9->B9_FILIAL  := xFilial("SB9")
			SB9->B9_COD     := HV04->B9_COD
			SB9->B9_LOCAL   := HV04->B9_LOCAL
			SB9->B9_DATA    := dtRfFim
			SB9->B9_QINI    := nQuant
			SB9->B9_QISEGUM := ConvUm(HV04->B9_COD, nQuant, 0, 2)
			SB9->B9_VINI1   := nCusto
			SB9->B9_CM1     := nCusto / nQuant
			SB9->B9_MCUSTD  := "1"
			MsUnLock()
		EndIf

		// Gera movimento no dia seguinte à virada, invertendo os movimento.
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+HV04->B9_COD)
		***********************************
		dbSelectArea("SD3")
		RecLock("SD3",.T.)
		SD3->D3_FILIAL  := xFilial("SD3")
		SD3->D3_TM      := IIF(nQuant1 > 0, "120", "720")
		SD3->D3_COD     := SB1->B1_COD
		SD3->D3_UM      := SB1->B1_UM
		SD3->D3_QUANT   := ABS(nQuant1)
		SD3->D3_QTSEGUM := ABS(nQuant1)
		SD3->D3_CUSTO1  := ABS(nCusto1)
		SD3->D3_CF      := IIF(nQuant1 > 0, "DE0", "RE0")
		SD3->D3_LOCAL   := HV04->B9_LOCAL
		SD3->D3_DOC     := "VIRPI3112"
		SD3->D3_NUMSEQ  := ProxNum()
		SD3->D3_EMISSAO := dtRfFim+1
		SD3->D3_GRUPO   := SB1->B1_GRUPO
		SD3->D3_TIPO    := SB1->B1_TIPO
		SD3->D3_CHAVE   := "E0"
		SD3->D3_USUARIO := cUserName
		SD3->D3_SEGUM   := SB1->B1_SEGUM
		SD3->D3_YROM    := "N"
		SD3->D3_YCHAVE  := ''
		SD3->D3_CONTA   := SB1->B1_YCTRIND
		SD3->D3_CC      := "3000"
		SD3->D3_CLVL    := IIF(cEmpAnt == "05", "3200", "3100")
		MsUnLock()
		DbCommitAll()

		dbSelectArea("HV04")
		dbSkip()

	End
	HV04->(dbCloseArea())

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BValid01Fer ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 28.05.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Valida intervalo para digitação da Programação de Férias   ¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BValid01Fer()

	QR006 := " SELECT Convert(VarChar(10), DATEADD(MONTH, 1, Convert(datetime, RF_DATABAS)-1-1) , 112) DTLIM_DE,
	QR006 += "        Convert(VarChar(10), DATEADD(YEAR , 2, Convert(datetime, RF_DATABAS)-45-1), 112) DTLIM_AT
	QR006 += "   FROM "+RetSqlName("SRF")+" SRF
	QR006 += "  WHERE RF_FILIAL = '"+xFilial("SRF")+"'
	QR006 += "    AND SRF.RF_MAT = '"+M->RF_MAT+"'
	QR006 += "    AND SRF.D_E_L_E_T_ = ' '
	QrIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR006),'QR06',.T.,.T.)
	dbSelectArea("QR06")
	dbGoTop()
	If dtos(M->RF_DATAINI) < QR06->DTLIM_DE .or. dtos(M->RF_DATAINI) > QR06->DTLIM_AT
		Aviso('BValid01Fer', 'A data digitada como programação de férias está fora do limite previsto para se realizar. Necessário verificar!!!',{'Ok'})
	EndIf

	QR06->(dbCloseArea())
	Ferase(QrIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(QrIndex+OrdBagExt())          //indice gerado

Return(M->RF_DATAINI)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BProvFjt   ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 07.05.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Ajusta provisão de férias para a desoneração ref mes de    ¦¦¦
¦¦¦          ¦ abril de 2013                                              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BProvFjt()

	Processa({|| RptXDetl()})

Return

Static Function RptXDetl()

	If !MsgYESNO("Certifique-se de que esteja na empresa certa e ainda não executou nenhum processamento. CONTINUAR?")
		Return
	EndIf

	QU004 := " SELECT CASE
	QU004 += "          WHEN FER_VENC = 0 AND VEN_FER_ANT = 0 AND VEN_FER_ATU = 0 AND FER_NO_MES = 0 AND NO_MES_803 = 0 THEN 1
	QU004 += "          WHEN FER_VENC = 0 AND VEN_FER_ANT > 0 AND VEN_FER_ATU = 0 AND FER_NO_MES < 0 AND NO_MES_803 = 0 THEN 2
	QU004 += "          WHEN FER_VENC >= 30 AND VEN_FER_ANT > 0 AND VEN_FER_ATU > 0 AND FER_NO_MES < 0 AND NO_MES_803 > 0 THEN 3
	QU004 += "          WHEN FER_VENC >= 30 AND VEN_FER_ANT = 0 AND VEN_FER_ATU > 0 AND FER_NO_MES > 0 AND NO_MES_803 > 0 THEN 4
	QU004 += "          ELSE 9
	QU004 += "        END TIPO,
	QU004 += "        *
	QU004 += "   FROM (
	QU004 += " SELECT RA_MAT,
	QU004 += "        RA_NOME,
	QU004 += "        RA_PERCSAT,
	QU004 += "        ISNULL((SELECT SUM(RT_DFERVEN)
	QU004 += "                  FROM "+RetSqlName("SRT")+" SRT
	QU004 += "                 WHERE RT_FILIAL = '01'
	QU004 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	QU004 += "                   AND RT_MAT = RA_MAT
	QU004 += "                   AND RT_VERBA IN('800')
	QU004 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) FER_VENC,
	QU004 += "        ISNULL((SELECT R_E_C_N_O_
	QU004 += "                  FROM "+RetSqlName("SRT")+" SRT
	QU004 += "                 WHERE RT_FILIAL = '01'
	QU004 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	QU004 += "                   AND RT_MAT = RA_MAT
	QU004 += "                   AND RT_VERBA IN('803')
	QU004 += "                   AND RT_TIPPROV IN('1')
	QU004 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) REG_803,
	QU004 += "        ISNULL((SELECT SUM(RT_VALOR)
	QU004 += "                  FROM "+RetSqlName("SRT")+" SRT
	QU004 += "                 WHERE RT_FILIAL = '01'
	QU004 += "                   AND RT_DATACAL BETWEEN '20130301' AND '20130331'
	QU004 += "                   AND RT_MAT = RA_MAT
	QU004 += "                   AND RT_VERBA IN('800','801','802')
	QU004 += "                   AND RT_TIPPROV IN('1')
	QU004 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) VEN_FER_ANT,
	QU004 += "        ISNULL((SELECT SUM(RT_VALOR)
	QU004 += "                  FROM "+RetSqlName("SRT")+" SRT
	QU004 += "                 WHERE RT_FILIAL = '01'
	QU004 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	QU004 += "                   AND RT_MAT = RA_MAT
	QU004 += "                   AND RT_VERBA IN('800','801','802')
	QU004 += "                   AND RT_TIPPROV IN('1')
	QU004 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) VEN_FER_ATU,
	QU004 += "        ISNULL((SELECT SUM(RT_VALOR)
	QU004 += "                  FROM "+RetSqlName("SRT")+" SRT
	QU004 += "                 WHERE RT_FILIAL = '01'
	QU004 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	QU004 += "                   AND RT_MAT = RA_MAT
	QU004 += "                   AND RT_VERBA IN('803')
	QU004 += "                   AND RT_TIPPROV IN('1')
	QU004 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) - ISNULL((SELECT SUM(RT_VALOR)
	QU004 += "                                                             FROM "+RetSqlName("SRT")+" SRT
	QU004 += "                                                            WHERE RT_FILIAL = '01'
	QU004 += "                                                              AND RT_DATACAL BETWEEN '20130301' AND '20130331'
	QU004 += "                                                              AND RT_MAT = RA_MAT
	QU004 += "                                                              AND RT_VERBA IN('803')
	QU004 += "                                                              AND RT_TIPPROV IN('1')
	QU004 += "                                                              AND SRT.D_E_L_E_T_ = ' '), 0) FER_NO_MES,
	QU004 += "        ISNULL((SELECT SUM(RT_VALOR)
	QU004 += "                  FROM "+RetSqlName("SRT")+" SRT
	QU004 += "                 WHERE RT_FILIAL = '01'
	QU004 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	QU004 += "                   AND RT_MAT = RA_MAT
	QU004 += "                   AND RT_VERBA IN('803')
	QU004 += "                   AND RT_TIPPROV IN('1')
	QU004 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) NO_MES_803,
	QU004 += "        ISNULL((SELECT SUM(RT_DFERPRO)
	QU004 += "                  FROM "+RetSqlName("SRT")+" SRT
	QU004 += "                 WHERE RT_FILIAL = '01'
	QU004 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	QU004 += "                   AND RT_MAT = RA_MAT
	QU004 += "                   AND RT_VERBA IN('800')
	QU004 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) FER_PROP
	QU004 += "   FROM "+RetSqlName("SRA")
	QU004 += "  WHERE RA_FILIAL = '01'
	QU004 += "    AND RA_MAT BETWEEN '000001' AND '199999'
	QU004 += "    AND RA_ADMISSA <= '20130331'
	QU004 += "    AND RA_MAT IN(SELECT RT_MAT
	QU004 += "                    FROM "+RetSqlName("SRT")+" SRT
	QU004 += "                   WHERE RT_FILIAL = '01'
	QU004 += "                     AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	QU004 += "                     AND RT_MAT BETWEEN '000001' AND '199999'
	QU004 += "                     AND SRT.D_E_L_E_T_ = ' ')
	QU004 += "    AND D_E_L_E_T_ = ' ') AS TAB
	QU004 := ChangeQuery(QU004)
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QU004),'QU04',.T.,.T.)
	dbSelectArea("QU04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		IncProc("Proc Vencidas..")

		If QU04->TIPO == 3
			dbSelectArea("SRT")
			dbGoTo(QU04->REG_803)
			RecLock("SRT",.F.)
			SRT->RT_VALOR := SRT->RT_VALOR + ABS(QU04->FER_NO_MES)
			SRT->RT_ITEM  := Alltrim(Str(QU04->TIPO))
			MsUnLock()
		EndIf

		dbSelectArea("QU04")
		dbSkip()
	End
	QU04->(dbCloseArea())
	Ferase(cIndex+OrdBagExt())

	WT007 := " SELECT CASE
	WT007 += "          WHEN FER_PROP = 0 AND AVE_FER_ANT = 0 AND AVE_FER_ATU = 0 AND SALARIO_MES = 0 AND FER_NO_MES_a_VENCAR = 0 THEN 0
	WT007 += "          WHEN FER_VENC = 0 AND FER_PROP = 0 AND AVE_FER_ANT > 0 AND AVE_FER_ATU = 0 AND SALARIO_MES < 0 AND FER_NO_MES_a_VENCAR < 0 THEN 1
	WT007 += "          WHEN FER_PROP > 0 AND AVE_FER_ANT = 0 AND AVE_FER_ATU > 0 AND SALARIO_MES > 0 AND FER_NO_MES_a_VENCAR > 0 THEN 2
	WT007 += "          WHEN FER_PROP > 0 AND AVE_FER_ANT > 0 AND AVE_FER_ATU > 0 AND SALARIO_MES = 0 AND FER_NO_MES_a_VENCAR < 0 THEN 3
	WT007 += "          WHEN FER_PROP > 0 AND AVE_FER_ANT > 0 AND AVE_FER_ATU > 0 AND SALARIO_MES > 0 AND FER_NO_MES_a_VENCAR < 0 THEN 4
	WT007 += "          WHEN FER_VENC >= 30 AND FER_PROP = 0 AND AVE_FER_ANT > 0 AND AVE_FER_ATU = 0 AND SALARIO_MES < 0 AND FER_NO_MES_a_VENCAR < 0 THEN 5
	WT007 += "          WHEN FER_PROP = 0 AND AVE_FER_ANT > 0 AND AVE_FER_ATU > 0 AND SALARIO_MES > 0 AND FER_NO_MES_a_VENCAR < 0 THEN 6
	WT007 += "          WHEN FER_PROP > 0 AND AVE_FER_ANT > 0 AND AVE_FER_ATU > 0 AND SALARIO_MES = 0 AND FER_NO_MES_a_VENCAR = 0 THEN 7
	WT007 += "          WHEN FER_PROP = 0 AND AVE_FER_ANT = 0 AND AVE_FER_ATU > 0 AND SALARIO_MES > 0 AND FER_NO_MES_a_VENCAR > 0 THEN 8
	WT007 += "          WHEN FER_PROP > 0 AND AVE_FER_ANT > 0 AND AVE_FER_ATU > 0 AND SALARIO_MES > 0 AND FER_NO_MES_a_VENCAR > 0 THEN 9
	WT007 += "          ELSE 10
	WT007 += "        END TIPO,
	WT007 += "        *
	WT007 += "   FROM (
	WT007 += " SELECT RA_MAT,
	WT007 += "        RA_NOME,
	WT007 += "        RA_PERCSAT,
	WT007 += "        ISNULL((SELECT SUM(RT_DFERVEN)
	WT007 += "                  FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                 WHERE RT_FILIAL = '01'
	WT007 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	WT007 += "                   AND RT_MAT = RA_MAT
	WT007 += "                   AND RT_VERBA IN('800')
	WT007 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) FER_VENC,
	WT007 += "        ISNULL((SELECT R_E_C_N_O_
	WT007 += "                  FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                 WHERE RT_FILIAL = '01'
	WT007 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	WT007 += "                   AND RT_MAT = RA_MAT
	WT007 += "                   AND RT_VERBA IN('803')
	WT007 += "                   AND RT_TIPPROV IN('1')
	WT007 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) REG_803_1,
	WT007 += "        ISNULL((SELECT R_E_C_N_O_
	WT007 += "                  FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                 WHERE RT_FILIAL = '01'
	WT007 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	WT007 += "                   AND RT_MAT = RA_MAT
	WT007 += "                   AND RT_VERBA IN('803')
	WT007 += "                   AND RT_TIPPROV IN('2')
	WT007 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) REG_803_2,
	WT007 += "        ISNULL((SELECT SUM(RT_DFERPRO)
	WT007 += "                  FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                 WHERE RT_FILIAL = '01'
	WT007 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	WT007 += "                   AND RT_MAT = RA_MAT
	WT007 += "                   AND RT_VERBA IN('800')
	WT007 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) FER_PROP,
	WT007 += "        ISNULL((SELECT SUM(RT_VALOR)
	WT007 += "                  FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                 WHERE RT_FILIAL = '01'
	WT007 += "                   AND RT_DATACAL BETWEEN '20130301' AND '20130331'
	WT007 += "                   AND RT_MAT = RA_MAT
	WT007 += "                   AND RT_VERBA IN('800','801','802')
	WT007 += "                   AND RT_TIPPROV IN('2')
	WT007 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) AVE_FER_ANT,
	WT007 += "        ISNULL((SELECT SUM(RT_VALOR)
	WT007 += "                  FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                 WHERE RT_FILIAL = '01'
	WT007 += "                   AND RT_DATACAL BETWEEN '20130301' AND '20130331'
	WT007 += "                   AND RT_MAT = RA_MAT
	WT007 += "                   AND RT_VERBA IN('800','801','802')
	WT007 += "                   AND RT_TIPPROV IN('2')
	WT007 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) * 20 / 100 Estono_Mes,
	WT007 += "        ISNULL((SELECT SUM(RT_VALOR)
	WT007 += "                  FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                 WHERE RT_FILIAL = '01'
	WT007 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	WT007 += "                   AND RT_MAT = RA_MAT
	WT007 += "                   AND RT_VERBA IN('800','801','802')
	WT007 += "                   AND RT_TIPPROV IN('2')
	WT007 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) AVE_FER_ATU,
	WT007 += "        ISNULL((SELECT SUM(RT_VALOR)
	WT007 += "                  FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                 WHERE RT_FILIAL = '01'
	WT007 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	WT007 += "                   AND RT_MAT = RA_MAT
	WT007 += "                   AND RT_VERBA IN('800','801','802')
	WT007 += "                   AND RT_TIPPROV IN('2')
	WT007 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) - ISNULL((SELECT SUM(RT_VALOR)
	WT007 += "                                                             FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                                                            WHERE RT_FILIAL = '01'
	WT007 += "                                                              AND RT_DATACAL BETWEEN '20130301' AND '20130331'
	WT007 += "                                                              AND RT_MAT = RA_MAT
	WT007 += "                                                              AND RT_VERBA IN('800','801','802')
	WT007 += "                                                              AND RT_TIPPROV IN('2')
	WT007 += "                                                              AND SRT.D_E_L_E_T_ = ' '), 0) SALARIO_MES,
	WT007 += "        ISNULL((SELECT SUM(RT_VALOR)
	WT007 += "                  FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                 WHERE RT_FILIAL = '01'
	WT007 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	WT007 += "                   AND RT_MAT = RA_MAT
	WT007 += "                   AND RT_VERBA IN('803')
	WT007 += "                   AND RT_TIPPROV IN('2')
	WT007 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) - ISNULL((SELECT SUM(RT_VALOR)
	WT007 += "                                                             FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                                                            WHERE RT_FILIAL = '01'
	WT007 += "                                                              AND RT_DATACAL BETWEEN '20130301' AND '20130331'
	WT007 += "                                                              AND RT_MAT = RA_MAT
	WT007 += "                                                              AND RT_VERBA IN('803')
	WT007 += "                                                              AND RT_TIPPROV IN('2')
	WT007 += "                                                              AND SRT.D_E_L_E_T_ = ' '), 0) FER_NO_MES_a_VENCAR,
	WT007 += "        (ISNULL((SELECT SUM(RT_VALOR)
	WT007 += "                  FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                 WHERE RT_FILIAL = '01'
	WT007 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	WT007 += "                   AND RT_MAT = RA_MAT
	WT007 += "                   AND RT_VERBA IN('800','801','802')
	WT007 += "                   AND RT_TIPPROV IN('2')
	WT007 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) - ISNULL((SELECT SUM(RT_VALOR)
	WT007 += "                                                             FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                                                            WHERE RT_FILIAL = '01'
	WT007 += "                                                              AND RT_DATACAL BETWEEN '20130301' AND '20130331'
	WT007 += "                                                              AND RT_MAT = RA_MAT
	WT007 += "                                                              AND RT_VERBA IN('800','801','802')
	WT007 += "                                                              AND RT_TIPPROV IN('2')
	WT007 += "                                                              AND SRT.D_E_L_E_T_ = ' '), 0)) * 7.8891 / 100 NO_MES,
	WT007 += "        (ISNULL((SELECT SUM(RT_VALOR)
	WT007 += "                  FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                 WHERE RT_FILIAL = '01'
	WT007 += "                   AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	WT007 += "                   AND RT_MAT = RA_MAT
	WT007 += "                   AND RT_VERBA IN('800','801','802')
	WT007 += "                   AND RT_TIPPROV IN('2')
	WT007 += "                   AND SRT.D_E_L_E_T_ = ' '), 0) - ISNULL((SELECT SUM(RT_VALOR)
	WT007 += "                                                             FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                                                            WHERE RT_FILIAL = '01'
	WT007 += "                                                              AND RT_DATACAL BETWEEN '20130301' AND '20130331'
	WT007 += "                                                              AND RT_MAT = RA_MAT
	WT007 += "                                                              AND RT_VERBA IN('800','801','802')
	WT007 += "                                                              AND RT_TIPPROV IN('2')
	WT007 += "                                                              AND SRT.D_E_L_E_T_ = ' '), 0)) * (5.8+RA_PERCSAT) / 100 NO_MES_FUN
	WT007 += "   FROM "+RetSqlName("SRA")
	WT007 += "  WHERE RA_FILIAL = '01'
	WT007 += "    AND RA_MAT BETWEEN '000001' AND '199999'
	WT007 += "    AND RA_ADMISSA <= '20130331'
	WT007 += "    AND RA_MAT IN(SELECT RT_MAT
	WT007 += "                    FROM "+RetSqlName("SRT")+" SRT
	WT007 += "                   WHERE RT_FILIAL = '01'
	WT007 += "                     AND RT_DATACAL BETWEEN '20130401' AND '20130430'
	WT007 += "                     AND RT_MAT BETWEEN '000001' AND '199999'
	WT007 += "                     AND SRT.D_E_L_E_T_ = ' ')
	WT007 += "    AND D_E_L_E_T_ = ' ') AS TAB2
	WT007 += "  ORDER BY TIPO
	WT007 := ChangeQuery(WT007)
	WTIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,WT007),'WT07',.T.,.T.)
	dbSelectArea("WT07")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		IncProc("Proc A Vencer..")

		If WT07->TIPO == 3
			dbSelectArea("SRT")
			dbGoTo(WT07->REG_803_2)
			RecLock("SRT",.F.)
			SRT->RT_VALOR := SRT->RT_VALOR + ABS(WT07->Estono_Mes)
			SRT->RT_ITEM  := Alltrim(Str(WT07->TIPO))
			MsUnLock()
		EndIf

		If WT07->TIPO == 4 .or. WT07->TIPO == 6
			dbSelectArea("SRT")
			dbGoTo(WT07->REG_803_2)
			RecLock("SRT",.F.)
			SRT->RT_VALOR := SRT->RT_VALOR + ABS(WT07->Estono_Mes) //+ IIF( WT07->RA_PERCSAT > 0, ABS(WT07->NO_MES_FUN), ABS(WT07->NO_MES) )
			SRT->RT_ITEM  := Alltrim(Str(WT07->TIPO))
			MsUnLock()
		EndIf

		If WT07->TIPO == 5
			dbSelectArea("SRT")
			dbGoTo(WT07->REG_803_1)
			RecLock("SRT",.F.)
			SRT->RT_VALOR := SRT->RT_VALOR + ABS(WT07->Estono_Mes)
			SRT->RT_ITEM  := Alltrim(Str(WT07->TIPO))
			MsUnLock()
		EndIf

		If WT07->TIPO == 10
			dbSelectArea("SRT")
			dbGoTo(WT07->REG_803_2)
			RecLock("SRT",.F.)
			SRT->RT_VALOR := SRT->RT_VALOR + ABS(WT07->Estono_Mes)
			SRT->RT_ITEM  := Alltrim(Str(WT07->TIPO))
			MsUnLock()
		EndIf

		dbSelectArea("WT07")
		dbSkip()
	End

	WT07->(dbCloseArea())
	Ferase(WTIndex+OrdBagExt())

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BConsultUSR  ¦ Autor ¦ Marcos Alberto S  ¦ Data ¦ 02.07.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Consulta cadastro de usuários do Protheus                  ¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BConsultUSR()

	Private ykoDlgUsr
	Private ykoFont1 := TFont():New("Arial Narrow",,020,,.T.,,,,,.F.,.F.)
	Private ykoGet1
	Private ykcGet1 := Space(6)
	Private ykoSay1

	DEFINE MSDIALOG ykoDlgUsr TITLE "Consulta Usuários" FROM 000, 000  TO 065, 470 COLORS 0, 16777215 PIXEL

	@ 012, 010 SAY ykoSay1 PROMPT "Consulta ao Cadastro de Usuários do Sistema:" SIZE 148, 011 OF ykoDlgUsr FONT ykoFont1 COLORS 0, 16777215 PIXEL
	@ 011, 162 MSGET ykoGet1 VAR ykcGet1 SIZE 060, 010 OF ykoDlgUsr COLORS 0, 16777215 F3 "USR" PIXEL
	ACTIVATE MSDIALOG ykoDlgUsr CENTERED

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIACtDepSa   ¦ Autor ¦ Marcos Alberto S  ¦ Data ¦ 02.09.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Valida digitação da conta bancária do cadastro de funcioná-¦¦¦
¦¦¦          ¦rio                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIACtDepSa()

	Local rtCtDepSa := M->RA_CTDEPSA

	If Len(Alltrim(rtCtDepSa)) < 12
		Aviso('Conta bancária', 'Conta bancária informada incorretamente. Favor verificar', {'Ok'})
		rtCtDepSa := ""
	EndIf

Return( rtCtDepSa )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BCtbPIAjt    ¦ Autor ¦ Marcos Alberto S  ¦ Data ¦ 07.08.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Lançamento contábil referente ajustes de custo do PI pelo  ¦¦¦
¦¦¦          ¦ custo padrão                                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BCtbPIAjt()

	fgLanPad := "D01"
	fgLotCtb := "0088400"
	fgVetCtb := {}
	fgPermDg := .T.

	ZT005 := " SELECT D3_CONTA DEBITO,
	ZT005 += "        B1_CONTA CREDIT,
	ZT005 += "        D3_CLVL CLVL_D,
	ZT005 += "        D3_CLVL CLVL_C,
	ZT005 += "        D3_ITEMCTA ITCTA_D,
	ZT005 += "        D3_ITEMCTA ITCTA_C,
	ZT005 += "        D3_CUSTO1 CUSTO,
	ZT005 += "        'REQ. AJUSTE CUSTO PADRAO N/ MES' HIST,
	ZT005 += "        D3_CC CC_D,
	ZT005 += "        D3_CC CC_C,
	ZT005 += "        SD3.R_E_C_N_O_ ORIGEM
	ZT005 += "   FROM "+RetSqlName("SD3")+" SD3
	ZT005 += "  INNER JOIN SB1010 SB1 ON B1_FILIAL = '  '
	ZT005 += "                       AND B1_COD = D3_COD
	ZT005 += "                       AND SB1.D_E_L_E_T_ = ' '
	ZT005 += "  WHERE D3_FILIAL = '01'
	ZT005 += "    AND D3_EMISSAO = '20130731'
	ZT005 += "    AND D3_DOC = 'AJT201307'
	ZT005 += "    AND D3_TM >= '500'
	ZT005 += "    AND SD3.D_E_L_E_T_ = ' '
	ZT005 += "  UNION ALL
	ZT005 += " SELECT B1_CONTA DEBITO,
	ZT005 += "        D3_CONTA CREDIT,
	ZT005 += "        D3_CLVL CLVL_D,
	ZT005 += "        D3_CLVL CLVL_C,
	ZT005 += "        D3_ITEMCTA ITCTA_D,
	ZT005 += "        D3_ITEMCTA ITCTA_C,
	ZT005 += "        D3_CUSTO1 CUSTO,
	ZT005 += "        'DEV. AJUSTE CUSTO PADRAO N/ MES' HIST,
	ZT005 += "        D3_CC CC_D,
	ZT005 += "        D3_CC CC_C,
	ZT005 += "        SD3.R_E_C_N_O_ ORIGEM
	ZT005 += "   FROM "+RetSqlName("SD3")+"  SD3
	ZT005 += "  INNER JOIN SB1010 SB1 ON B1_FILIAL = '  '
	ZT005 += "                       AND B1_COD = D3_COD
	ZT005 += "                       AND SB1.D_E_L_E_T_ = ' '
	ZT005 += "  WHERE D3_FILIAL = '01'
	ZT005 += "    AND D3_EMISSAO = '20130731'
	ZT005 += "    AND D3_DOC = 'AJT201307'
	ZT005 += "    AND D3_TM < '500'
	ZT005 += "    AND SD3.D_E_L_E_T_ = ' '
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZT005),'ZT05',.T.,.T.)
	aStru1 := ("ZT05")->(dbStruct())
	dbSelectArea("ZT05")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		// Vetor ==>>          Debito,      Credito,       ClVl_D,       ClVl_C, Item_Contab_D, Item_Contab_C,       Valor,  Histórico,   CCUSTO_D,   CCUSTO_C,                                           ORIGEM
		Aadd(fgVetCtb, { ZT05->DEBITO, ZT05->CREDIT, ZT05->CLVL_D, ZT05->CLVL_C, ZT05->ITCTA_D, ZT05->ITCTA_C, ZT05->CUSTO, ZT05->HIST, ZT05->CC_D, ZT05->CC_C, Space(13) + Space(15) + Alltrim(Str(ZT05->ORIGEM)) })

		dbSelectArea("ZT05")
		dbSkip()
	End
	ZT05->(dbCloseArea())

	U_BiaCtbAV(fgLanPad, fgLotCtb, fgVetCtb, fgPermDg)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIAD401    ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 07.05.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Ajusta provisão de férias para a desoneração ref mes de    ¦¦¦
¦¦¦          ¦ abril de 2013                                              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIAD401()

	Private L380
	Private L381

	AxCadastro("SD4","Acerta Empenho...")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BEstruIn   ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 08.11.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Busca Estrutura reversa - Onde é Usado - a partir de um de-¦¦¦
¦¦¦          ¦ terminado componente                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B761EstruIn(cCodProd)

	LOCAL wnrel   := "MATR400"
	LOCAL Tamanho := "P"
	LOCAL titulo  := "Onde e' Usado"
	LOCAL cDesc1  := "Emite uma rela‡„o informando onde determinados materiais selecionados"
	LOCAL cDesc2  := "s„o utilizados na composi‡„o da estrutura."
	LOCAL cDesc3  := ""
	LOCAL CABEC1  := ""
	LOCAL CABEC2  := ""

	Local nTipo      := 0
	Private cProdUsd := ""
	Private cCodProd := IIF( cCodProd == NIL, "", cCodProd)

	dbSelectArea("SG1")
	dbSetOrder(2)

	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+cCodProd)

		cProdUsd := "'"
		nRecComp   := RecNo()
		cCodComp   := B1_COD

		dbSelectArea("SG1")
		dbSeek(xFilial()+cCodComp)
		lImprime := .T.

		While !Eof() .And. G1_FILIAL+G1_COMP == xFilial()+cCodComp

			SB1->(dbSeek(xFilial()+SG1->G1_COD))

			If (dDataBase >= SG1->G1_INI .And. dDataBase <= SG1->G1_FIM)

				dbSelectArea("SB1")
				dbSeek(xFilial()+SG1->G1_COD)

				BIA761Estr(SG1->G1_COD,titulo,cabec1,cabec2,wnrel,tamanho,nTipo)

			EndIf

			SG1->(DbSkip())

		EndDo

		cProdUsd += "'"

		dbSelectArea("SB1")
		Go nRecComp

	EndIf

	dbSelectArea("SB1")
	Set Filter To
	dbSetOrder(1)
	dbSelectArea("SG1")
	dbSetOrder(1)

Return ( cProdUsd )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Bia761Estr ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 08.11.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Explode os niveis da Estrutura de Baixo para Cima          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
STATIC Function BIA761Estr(cProduto,titulo,cabec1,cabec2,wnrel,tamanho,nTipo,nOpc)
	LOCAL nReg := 0
	LOCAL aAreaSG1 := SG1->(GetArea())
	LOCAL aAreaSB1 := SB1->(GetArea())
	Local cProd    := ""
	DEFAULT nOpc   := 1

	dbSelectArea("SG1")
	dbSeek(xFilial()+cProduto)

	While !Eof() .And. G1_FILIAL+G1_COMP == xFilial()+cProduto
		nReg := Recno()

		If (dDataBase >= G1_INI .And. dDataBase <= G1_FIM)

			dbSelectArea("SB1")
			dbSeek(xFilial()+SG1->G1_COD)

			If nOpc == 1
				If SB1->B1_TIPO == "PA"
					weQtdProd := 1
					If weQtdProd > 0
						cProdUsd += Alltrim(B1_COD)+"','
					EndIf
				EndIf
			ElseIf nOpc == 2
				cProd := B1_COD
				If SB1->B1_TIPO == "PA"
					weQtdProd := 1
					If weQtdProd > 0
						cProdUsd += Alltrim(B1_COD)+"','
					EndIf
				EndIf
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe sub-estrutura                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SG1")
		dbSeek(xFilial()+G1_COMP+G1_COD)
		IF Found()
			BIA761Estr(G1_COD,titulo,cabec1,cabec2,wnrel,Tamanho,nTipo,nOpc)
		EndIf
		dbGoto(nReg)
		dbSkip()
	EndDo

	RestArea(aAreaSB1)
	RestArea(aAreaSG1)

Return IIF(nOpc==2,cProd,Nil)

//===================================================
//                                                  =
//===================================================
User Function QQQQCCCC()

	Processa({||xfEstProd()})

Static Function xfEstProd()

	ZP005 := " SELECT D3_DOC, D3_OP, D3_NUMSEQ, D3_COD, D3_LOTECTL, D3_EMISSAO, D3_QUANT
	ZP005 += "   FROM SD3010
	ZP005 += "  WHERE D3_FILIAL = '01'
	ZP005 += "    AND D3_EMISSAO BETWEEN '20130920' AND '20130930'
	//ZP005 += "    AND D3_COD BETWEEN 'BD' AND 'BFZ'
	//ZP005 += "    AND D3_ESTORNO = ' '
	//ZP005 += "    AND D3_LOTECTL = 'PRODUCAO'
	ZP005 += "    AND D3_NUMSEQ IN('ACRVIR','ACRVIT','ACRVK0','ACRVKC','ACRVKE','ACRVKG','ACRVKO','ACRVKQ','ACRVKS','ACRVKU','ACRVL0','ACRVL2','ACRVL4','ACRVL6','ACRVL8','ACRVND','ACRVPG','ACRVPI','ACRVPL','ACRVQR','ACRVSA','ACRVSC','ACRVTX','ACRVTZ','ACRVUE','ACRVUG','ACRVUI','ACRVUK')

	ZP005 += "    AND 1 = 2

	ZP005 += "    AND D_E_L_E_T_ = ' '
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP005),'ZP05',.T.,.T.)
	dbSelectArea("ZP05")
	dbGoTop()
	ProcRegua(RecCount())
	xdContad := 0
	While !Eof()

		xdContad ++
		IncProc("Processando " + Alltrim(Str(xdContad)))

		klSegEmFrent := .T.

		aCabSDA    := {}
		aItSDB     := {}
		_aItensSDB := {}
		// ************ Cabeçalho com a informação do item e NumSeq que sera endereçado ************
		aCabSDA := {{"DA_PRODUTO" ,ZP05->D3_COD             ,Nil},;
		{            "DA_NUMSEQ"  ,ZP05->D3_NUMSEQ          ,Nil} }
		// **************************** Dados do item que será endereçado **************************
		aItSDB := {{"DB_ITEM"	  ,"0001"                   ,Nil},;
		{           "DB_ESTORNO"  ,"S"	                    ,Nil},;
		{           "DB_LOCALIZ"  ,"ZZZZ"                   ,Nil},;
		{           "DB_DATA"	  ,stod(ZP05->D3_EMISSAO)   ,Nil},;
		{           "DB_QUANT"    ,ZP05->D3_QUANT           ,Nil} }
		aadd(_aItensSDB,aitSDB)
		lMsErroAuto := .f.
		MATA265( aCabSDA, _aItensSDB, 4)
		If lMsErroAuto
			//klSegEmFrent := .F.
		EndIf

		If klSegEmFrent                                                        // Estorno do Apontamento
			********************************************************************************************

			lMSHelpAuto := .T.
			lMSErroAuto := .F.

			cFiltro := " D3_DOC = '"+ZP05->D3_DOC+"' .AND. D3_OP = '"+ZP05->D3_OP+"' .AND. D3_NUMSEQ = '"+ZP05->D3_NUMSEQ+"'  "

			dbSelectArea("SD3")
			Set Softseek On

			dbSetOrder(5)
			DbSetFilter({|| &cFiltro},cFiltro)
			dbSetOrder(5)
			dbGoTop()

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + ZP05->D3_COD))
			dbSelectArea("SD3")
			dbSetOrder(5)
			qs_VetM250 :={ {  "D3_TM"       , "010"                   ,NIL},;
			{                 "D3_COD"      , ZP05->D3_COD            ,NIL},;
			{                 "D3_OP"       , ZP05->D3_OP             ,NIL},;
			{                 "D3_DOC"      , ZP05->D3_DOC            ,NIL} }
			lMsHelpAuto := .T.
			lMsErroAuto := .F.
			msExecAuto({|x,Y| Mata250(x,Y)}, qs_VetM250, 5)

			If lMsErroAuto
				klSegEmFrent := .F.
			EndIf
			SD3->(DbClearFilter())
			Set Softseek Off

		EndIf

		dbSelectArea("ZP05")
		dbSkip()
	End

	ZP05->(dbCloseArea())
	Ferase(cIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(cIndex+OrdBagExt())          //indice gerado

Return

//***********************************************************************************************************************************************************************
//**                                                                                                                                                                   **
//***********************************************************************************************************************************************************************
//**                                                                                                                                                                   **
//***********************************************************************************************************************************************************************

User Function MyXXXReport()

	Local oReport

	If TRepInUse()
		Pergunte("MTR530",.F.)
		oReport := xReportDef()
		oReport:PrintDialog()
	EndIf

Return

Static Function xReportDef()

	Local oReport
	Local oSection1
	Local oSection2

	oReport := TReport():New("MYREPORT","Relatorio de Visitas","MTR530",{|oReport| xPrintReport(oReport)},"Relatorio de visitas de vendedores nos clientes")

	oSection1 := TRSection():New(oReport,"Vendedores","SA3")
	TRCell():New(oSection1,"A3_COD","SA3","Vendedor")
	TRCell():New(oSection1,"A3_NOME","SA3")
	TRFunction():New(oSection1:Cell("A3_COD"),NIL,"COUNT",NIL,NIL,NIL,NIL,.F.)

	oSection2 := TRSection():New(oSection1,"Clientes","SA1")
	TRCell():New(oSection2,"A1_COD","SA1","Cliente")
	TRCell():New(oSection2,"A1_LOJA","SA1")
	TRCell():New(oSection2,"A1_NOME","SA1")
	TRCell():New(oSection2,"A1_ULTVIS","SA1")
	TRCell():New(oSection2,"A1_TEMVIS","SA1")
	TRCell():New(oSection2,"A1_CONTATO","SA1")
	TRCell():New(oSection2,"A1_TEL","SA1")
	TRFunction():New(oSection2:Cell("A1_COD"),NIL,"COUNT")
	TRFunction():New(oSection2:Cell("A1_TEMVIS"),NIL,"SUM")

Return oReport

Static Function xPrintReport(oReport)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(1):Section(1)
	Local cFiltro   := ""

	#IFDEF TOP
	oSection1:BeginQuery()
	If ( mv_par03 == 1 )
		cPart := "%AND (" + Dtos(dDataBase) + " - A1_ULTVIS) > A1_TEMVIS%"
	Else
		cPart := "%%"
	EndIf

	BeginSql alias "QRYSA3"
		SELECT A1_COD,A1_LOJA,A1_NOME,A1_VEND,A1_ULTVIS,A1_TEMVIS,A1_TEL,A1_CONTATO,A3_NOME,A3_COD
		FROM %table:SA1% SA1,%table:SA3% SA3
		WHERE A1_VEND = A3_COD AND A1_FILIAL = %xfilial:SA1% AND SA1.%notDel%
		ORDER BY A1_VEND
	EndSql
	/*	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 	pela funcao MakeSqlExpr para serem adicionados a query	*/
	oSection1:EndQuery("A1_VEND BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' ")
	oSection2:SetParentQuery()
	oSection2:SetParentFilter({|cParam| QRYSA3->A1_VEND >= cParam .and. QRYSA3->A1_VEND <= cParam},{|| QRYSA3->A3_COD})
	#ELSE
	cFiltro := " A1_TEMVIS > 0 "
	If ( mv_par03 == 1 )
		cFiltro += ' .AND. ('+DtoC(dDataBase)+'-A1_ULTVIS) > A1_TEMVIS'
	EndIf
	oSection2:SetFilter(cFiltro,"A1_VEND")
	oSection2:SetRelation({|| SA3->A3_COD})
	oSection2:SetParentFilter({|cParam| SA1->A1_VEND >= cParam .and. SA1->A1_VEND <= cParam},{|| SA3->A3_COD})
	#ENDIF
	oSection1:Print()

Return

//***********************************************************************************************************************************************************************
//**                                                                                                                                                                   **
//***********************                       ACERTA PODER DE TERCEIROS DA VITCER       --     05/11/13               *************************************************
//**                                                                                                                                                                   **
//***********************************************************************************************************************************************************************

User Function BACVT001()

	If cEmpAnt <> '14'
		MsgINFO("Empresa Errada")
		Return
	EndIf

	RT005 := " SELECT B6_DOC,
	RT005 += "        B6_SERIE,
	RT005 += "        B6_CLIFOR,
	RT005 += "        B6_LOJA,
	RT005 += "        'S' FORMUL,
	RT005 += "        'N' TIPONF,
	RT005 += "        B6_EMISSAO,
	RT005 += "        B6_PRODUTO,
	RT005 += "        B6_PRUNIT,
	RT005 += "        B6_QUANT,
	RT005 += "        B6_LOCAL,
	RT005 += "        B6_IDENT,
	RT005 += "        B6_TES,
	RT005 += "        (SELECT COUNT(*)
	RT005 += "           FROM SD2140
	RT005 += "          WHERE D2_FILIAL = '01'
	RT005 += "            AND D2_DOC = B6_DOC
	RT005 += "            AND D2_COD = B6_PRODUTO
	RT005 += "            AND D2_QUANT = B6_QUANT
	RT005 += "            AND D2_IDENTB6 = B6_IDENT
	RT005 += "            AND D_E_L_E_T_ = ' ') SD2,
	RT005 += "        (SELECT DISTINCT D1_LOTECTL
	RT005 += "           FROM SD1140
	RT005 += "          WHERE D1_FILIAL = '01'
	RT005 += "            AND D1_COD = B6_PRODUTO
	RT005 += "            AND D1_IDENTB6 = B6_IDENT
	RT005 += "            AND D_E_L_E_T_ = ' ') LOTE,
	RT005 += "        (SELECT DISTINCT D1_DOC
	RT005 += "           FROM SD1140
	RT005 += "          WHERE D1_FILIAL = '01'
	RT005 += "            AND D1_COD = B6_PRODUTO
	RT005 += "            AND D1_IDENTB6 = B6_IDENT
	RT005 += "            AND D_E_L_E_T_ = ' ') NFORI,
	RT005 += "        (SELECT DISTINCT D1_ITEM
	RT005 += "           FROM SD1140
	RT005 += "          WHERE D1_FILIAL = '01'
	RT005 += "            AND D1_COD = B6_PRODUTO
	RT005 += "            AND D1_IDENTB6 = B6_IDENT
	RT005 += "            AND D_E_L_E_T_ = ' ') ITORI,
	RT005 += "        (SELECT DISTINCT D1_SERIE
	RT005 += "           FROM SD1140
	RT005 += "          WHERE D1_FILIAL = '01'
	RT005 += "            AND D1_COD = B6_PRODUTO
	RT005 += "            AND D1_IDENTB6 = B6_IDENT
	RT005 += "            AND D_E_L_E_T_ = ' ') SERORI
	RT005 += "   FROM SB6140
	RT005 += "  WHERE B6_FILIAL = '01'
	RT005 += "    AND B6_TES >= '500'
	RT005 += "    AND (SELECT COUNT(*)
	RT005 += "           FROM SD2140
	RT005 += "          WHERE D2_FILIAL = '01'
	RT005 += "            AND D2_DOC = B6_DOC
	RT005 += "            AND D2_COD = B6_PRODUTO
	RT005 += "            AND D2_QUANT = B6_QUANT
	RT005 += "            AND D2_IDENTB6 = B6_IDENT
	RT005 += "            AND D_E_L_E_T_ = ' ') = 0
	RT005 += "    AND D_E_L_E_T_ = ' '
	RT005 += "  ORDER BY B6_DOC, R_E_C_N_O_
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT005),'RT05',.T.,.T.)
	dbSelectArea("RT05")
	dbGoTop()
	ProcRegua(RecCount())
	xdContad := 0
	While !Eof()

		xNf := RT05->B6_DOC
		xSr := RT05->B6_SERIE
		xFn := RT05->B6_CLIFOR
		xLj := RT05->B6_LOJA

		dbSelectArea("SF2")
		dbSetOrder(1)
		If !dbseek(xFilial("SF2") + xNf + xSr + xFn + xLj)
			RecLock("SF2",.T.)
			SF2->F2_FILIAL  := xFilial("SF2")
			SF2->F2_DOC     := xNf
			SF2->F2_SERIE   := xSr
			SF2->F2_CLIENTE := xFn
			SF2->F2_LOJA    := xLj
			SF2->F2_FORMUL  := RT05->FORMUL
			SF2->F2_TIPO    := RT05->TIPONF
			SF2->F2_EMISSAO := stod(RT05->B6_EMISSAO)
			SF2->F2_DTDIGIT := stod(RT05->B6_EMISSAO)
			MsUnLock()
		EndIf

		dbSelectarea("RT05")
		While !Eof() .and. RT05->B6_DOC == xNf .and. RT05->B6_SERIE == xSr .and. RT05->B6_CLIFOR == xFn .and. RT05->B6_LOJA == xLj

			RF003 := " SELECT COUNT(*) CONTAD
			RF003 += "   FROM SD2140
			RF003 += "  WHERE D2_FILIAL = '01'
			RF003 += "    AND D2_DOC = '"+xNf+"'
			RF003 += "    AND D2_SERIE = '"+xSr+"'
			RF003 += "    AND D2_CLIENTE = '"+xFn+"'
			RF003 += "    AND D2_LOJA = '"+xLj+"'
			RF003 += "    AND D_E_L_E_T_ = ' '
			RFcIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,RF003),'RF03',.T.,.T.)
			dbSelectArea("RF03")
			dbGoTop()
			xfItem := Soma1(Strzero(RF03->CONTAD,2))
			RF03->(dbCloseArea())
			Ferase(RFcIndex+GetDBExtension())     //arquivo de trabalho
			Ferase(RFcIndex+OrdBagExt())          //indice gerado

			dbSelectArea("SD2")
			RecLock("SD2",.T.)
			SD2->D2_FILIAL   := xFilial("SD2")
			SD2->D2_COD      := RT05->B6_PRODUTO
			SD2->D2_QUANT    := RT05->B6_QUANT
			SD2->D2_PRCVEN   := RT05->B6_PRUNIT
			SD2->D2_TOTAL    := RT05->B6_QUANT * RT05->B6_PRUNIT
			SD2->D2_TES      := RT05->B6_TES
			SD2->D2_CLIENTE  := RT05->B6_CLIFOR
			SD2->D2_LOJA     := RT05->B6_LOJA
			SD2->D2_DOC      := RT05->B6_DOC
			SD2->D2_EMISSAO  := stod(RT05->B6_EMISSAO)
			SD2->D2_LOCAL    := RT05->B6_LOCAL
			SD2->D2_SERIE    := RT05->B6_SERIE
			SD2->D2_TIPO     := "N"
			SD2->D2_NFORI    := RT05->NFORI
			SD2->D2_SERIORI  := RT05->SERORI
			SD2->D2_ORIGLAN  := "LF"
			SD2->D2_IDENTB6  := RT05->B6_IDENT
			SD2->D2_LOTECTL  := RT05->LOTE
			SD2->D2_ITEMORI  := RT05->ITORI
			SD2->D2_ITEM     := xfItem
			SD2->D2_ESTOQUE  := 'S'
			MsUnLock()

			dbSelectarea("RT05")
			dbSkip()

		End

	End

	RT05->(dbCloseArea())
	Ferase(cIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(cIndex+OrdBagExt())          //indice gerado

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BIAxVb792  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 06/01/14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIAxVb792()

	Local aAreaAnt := GetArea()

	Private cQry    := ""
	Private cVb792	:= "792"

	IF UPPER(ALLTRIM(FUNNAME())) <> "GPEM020" .AND. UPPER(ALLTRIM(FUNNAME())) <> "GPEM040"
		RETURN
	END IF

	cQry := " SELECT SUM(RC_VALOR) VALOR
	cQry += "   FROM " + RetSqlName("SRC")
	cQry += "  WHERE RC_FILIAL = '"+xFilial("SRC")+"'
	cQry += "    AND RC_MAT IN('"+SRA->RA_MAT+"')
	cQry += "    AND RC_PD IN('721','722','723','724','825')
	cQry += "    AND D_E_L_E_T_= ' '
	TcQuery cQry New Alias T001

	IF T001->VALOR > 0

		fGeraVerba(cVb792, T001->VALOR * 0.2,,,,,,,,,)

	EndIf

	//Fecha a Query
	dbCloseArea("T001")

	RestArea(aAreaAnt)

RETURN

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BiaCyTabl  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 15/05/14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Manupula Arquivos de Sistema para copia entre as empresa   ¦¦¦
¦¦¦          ¦            Manupulação de Tabelas à QUENTE                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BiaCyTabl()

	Local lRet := .F.

	StartJob( "U_BiaGrvSX", GetEnvServer(),.T.)

	xdTabls  := "Tabelas: " + CHR(13)+CHR(10)
	xdPastas := "Pastas: " + CHR(13)+CHR(10)
	xdIndcs  := "Indices: " + CHR(13)+CHR(10)
	xdCampos := "Campos: " + CHR(13)+CHR(10)
	xdGatilh := "Gatilhos: " + CHR(13)+CHR(10)
	xdParame := "Parametros: " + CHR(13)+CHR(10)
	xdConsul := "Consultas: " + CHR(13)+CHR(10)

	If File("\cfglog\sx2x3101.dtc")                                            // SX2
		*****************************************************************************

		xdTabls := "Tabelas Criadas e/ou Atualizadas: " + CHR(13)+CHR(10)
		dbUseArea(.T., 'CTREECDX', "\cfglog\sx2x3101.dtc", "SX2COPY", .T., .F.)
		dbSelectArea("SX2COPY")
		dbGoTop()
		While !Eof()
			xdTabls += SX2COPY->X2_CHAVE + CHR(13)+CHR(10)
			dbSelectArea("SX2COPY")
			dbSkip()
		End
		dbSelectArea("SX2COPY")
		dbCloseArea()
		Ferase("\cfglog\sx2x3101.dtc")

	EndIf

	If File("\cfglog\sxax3101.dtc")                                            // SXA
		*****************************************************************************

		xdPastas := "Criando Pastas: " + CHR(13)+CHR(10)
		dbUseArea(.T., 'CTREECDX', "\cfglog\sxax3101.dtc", "SXACOPY", .T., .F.)
		dbSelectArea("SXACOPY")
		dbGoTop()
		While !Eof()
			xdPastas += SXACOPY->XA_ALIAS + SXACOPY->XA_ORDEM + CHR(13)+CHR(10)
			dbSelectArea("SXACOPY")
			dbSkip()
		End
		dbSelectArea("SXACOPY")
		dbCloseArea()
		Ferase("\cfglog\sxax3101.dtc")

	EndIf
	If File("\cfglog\sixx3101.dtc")                                            // SIX
		*****************************************************************************

		xdIndcs := "Indices Criados: " + CHR(13)+CHR(10)
		dbUseArea(.T., 'CTREECDX', "\cfglog\sixx3101.dtc", "SIXCOPY", .T., .F.)
		dbSelectArea("SIXCOPY")
		dbGoTop()
		While !Eof()
			xdIndcs += SIXCOPY->INDICE + " - " + SIXCOPY->ORDEM + " - " + SIXCOPY->CHAVE + CHR(13)+CHR(10)
			dbSelectArea("SIXCOPY")
			dbSkip()
		End
		dbSelectArea("SIXCOPY")
		dbCloseArea()
		Ferase("\cfglog\sixx3101.dtc")

	EndIf

	If File("\cfglog\sx3x3101.dtc")                                            // SX3
		*****************************************************************************

		xdCampos := "Campos Criados: " + CHR(13)+CHR(10)
		dbUseArea(.T., 'CTREECDX', "\cfglog\sx3x3101.dtc", "SX3COPY", .T., .F.)
		dbSelectArea("SX3COPY")
		dbGoTop()
		While !Eof()
			xdCampos += SX3COPY->X3_CAMPO + CHR(13)+CHR(10)
			dbSelectArea("SX3COPY")
			dbSkip()
		End
		dbSelectArea("SX3COPY")
		dbCloseArea()
		Ferase("\cfglog\sx3x3101.dtc")

	EndIf

	If File("\cfglog\sx6x3101.dtc")                                            // SX6
		*****************************************************************************

		xdParame := "Parâmetros Criados: " + CHR(13)+CHR(10)
		dbUseArea(.T., 'CTREECDX', "\cfglog\sx6x3101.dtc", "SX6COPY", .T., .F.)
		dbSelectArea("SX6COPY")
		dbGoTop()
		While !Eof()
			xdParame += SX6COPY->X6_VAR + CHR(13)+CHR(10)
			dbSelectArea("SX6COPY")
			dbSkip()
		End
		dbSelectArea("SX6COPY")
		dbCloseArea()
		Ferase("\cfglog\sx6x3101.dtc")

	EndIf

	If File("\cfglog\sx7x3101.dtc")                                            // SX7
		*****************************************************************************

		xdGatilh := "Gatilhos Criados: " + CHR(13)+CHR(10)
		dbUseArea(.T., 'CTREECDX', "\cfglog\sx7x3101.dtc", "SX7COPY", .T., .F.)
		dbSelectArea("SX7COPY")
		dbGoTop()
		While !Eof()
			xdGatilh += SX7COPY->X7_CAMPO + SX7COPY->X7_SEQUENC + CHR(13)+CHR(10)
			dbSelectArea("SX7COPY")
			dbSkip()
		End
		dbSelectArea("SX7COPY")
		dbCloseArea()
		Ferase("\cfglog\sx7x3101.dtc")

	EndIf

	If File("\cfglog\sxbx3101.dtc")                                            // SXB
		*****************************************************************************

		xdConsul := "Consultas Criadas: " + CHR(13)+CHR(10)
		dbUseArea(.T., 'CTREECDX', "\cfglog\sxbx3101.dtc", "SXBCOPY", .T., .F.)
		dbSelectArea("SXBCOPY")
		dbGoTop()
		While !Eof()
			xdConsul += SXBCOPY->XB_ALIAS + SXBCOPY->XB_TIPO + SXBCOPY->XB_SEQ + CHR(13)+CHR(10)
			dbSelectArea("SXBCOPY")
			dbSkip()
		End
		dbSelectArea("SXBCOPY")
		dbCloseArea()
		Ferase("\cfglog\sxbx3101.dtc")

	EndIf

	If File("\cfglog\sxqx3101.dtc")                                            // SXQ
		*****************************************************************************

		xdConsul := "Filtros: " + CHR(13)+CHR(10)
		dbUseArea(.T., 'CTREECDX', "\cfglog\sxqx3101.dtc", "SXQCOPY", .T., .F.)
		dbSelectArea("SXQCOPY")
		dbGoTop()
		While !Eof()
			xdConsul += SXQCOPY->XQ_ALIAS + SXQCOPY->XQ_SEQ + CHR(13)+CHR(10)
			dbSelectArea("SXQCOPY")
			dbSkip()
		End
		dbSelectArea("SXQCOPY")
		dbCloseArea()
		Ferase("\cfglog\sxqx3101.dtc")

	EndIf

	Aviso('Atualização do sistema', xdTabls + CHR(13)+CHR(10) + xdPastas + CHR(13)+CHR(10) + xdIndcs + CHR(13)+CHR(10) + xdCampos + CHR(13)+CHR(10) + xdGatilh + CHR(13)+CHR(10) + xdParame + CHR(13)+CHR(10) + xdConsul + CHR(13)+CHR(10) + CHR(13)+CHR(10) + CHR(13)+CHR(10), {'Ok'}, 3 )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BiaGrvSX   ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 15/05/14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BiaGrvSX()

	Local xt

	xv_Emps    := U_BAGtEmpr("01_03_04_05_06_07_08_09_10_11_12_13_14_15_16_17_90_91")

	For xt := 1 To Len(xv_Emps)

		RPCSetType(3)
		RPCSetEnv(xv_Emps[xt,1], xv_Emps[xt,2])

		// Apenas para Filial 01
		If xv_Emps[xt,2] == "01"

			If File("\cfglog\sx2x3101.dtc")                                        // SX2
				*************************************************************************
				dbUseArea(.T., 'CTREECDX', "\cfglog\sx2x3101.dtc", "SX2COPY", .T., .F.)
				dbSelectArea("SX2COPY")
				dbGotop()
				While !Eof()

					dbSelectArea("SX2")
					If !dbSeek(SX2COPY->X2_CHAVE)
						RecLock("SX2",.T.)
						SX2->X2_ARQUIVO	:= Substr(SX2COPY->X2_ARQUIVO,1,3) + xv_Emps[xt,1] + "0"
					Else
						RecLock("SX2",.F.)
					EndIf
					SX2->X2_CHAVE	:= SX2COPY->X2_CHAVE
					SX2->X2_PATH	:= SX2COPY->X2_PATH
					//SX2->X2_ARQUIVO	:= SX2COPY->X2_ARQUIVO
					SX2->X2_NOME	:= SX2COPY->X2_NOME
					SX2->X2_NOMESPA	:= SX2COPY->X2_NOMESPA
					SX2->X2_NOMEENG	:= SX2COPY->X2_NOMEENG
					SX2->X2_ROTINA	:= SX2COPY->X2_ROTINA
					SX2->X2_MODO	:= SX2COPY->X2_MODO
					SX2->X2_MODOUN	:= SX2COPY->X2_MODOUN
					SX2->X2_MODOEMP	:= SX2COPY->X2_MODOEMP
					SX2->X2_DELET	:= SX2COPY->X2_DELET
					SX2->X2_TTS	    := SX2COPY->X2_TTS
					SX2->X2_UNICO	:= SX2COPY->X2_UNICO
					SX2->X2_PYME	:= SX2COPY->X2_PYME
					SX2->X2_MODULO	:= SX2COPY->X2_MODULO
					SX2->X2_DISPLAY	:= SX2COPY->X2_DISPLAY
					SX2->X2_SYSOBJ	:= SX2COPY->X2_SYSOBJ
					SX2->X2_USROBJ  := SX2COPY->X2_USROBJ
					MsUnlock()

					dbSelectArea("SX2COPY")
					dbSkip()
				End

				dbSelectArea("SX2COPY")
				dbCloseArea()
			EndIf

			If File("\cfglog\sixx3101.dtc")                                        // SIX
				*************************************************************************
				dbUseArea(.T., 'CTREECDX', "\cfglog\sixx3101.dtc", "SIXCOPY", .T., .F.)
				dbSelectArea("SIXCOPY")
				dbSelectArea("SIX")
				APPEND FROM ("SIXCOPY")

				dbSelectArea("SIXCOPY")
				dbCloseArea()
			EndIf

			If File("\cfglog\sxax3101.dtc")                                        // SXA
				*************************************************************************
				dbUseArea(.T., 'CTREECDX', "\cfglog\sxax3101.dtc", "SXACOPY", .T., .F.)
				dbSelectArea("SXACOPY")

				dbGotop()
				While !Eof()

					dbSelectArea("SXA")
					If !dbSeek(SXACOPY->XA_ALIAS+SXACOPY->XA_ORDEM)
						RecLock("SXA",.T.)
					Else
						RecLock("SXA",.F.)
					EndIf
					SXA->XA_ALIAS   := SXACOPY->XA_ALIAS  
					SXA->XA_ORDEM   := SXACOPY->XA_ORDEM  
					SXA->XA_DESCRIC := SXACOPY->XA_DESCRIC
					SXA->XA_DESCSPA := SXACOPY->XA_DESCSPA
					SXA->XA_DESCENG := SXACOPY->XA_DESCENG
					SXA->XA_PROPRI  := SXACOPY->XA_PROPRI 
					SXA->XA_AGRUP   := SXACOPY->XA_AGRUP  
					SXA->XA_TIPO    := SXACOPY->XA_TIPO   
					MsUnlock()

					dbSelectArea("SXACOPY")
					dbSkip()

				End

				dbSelectArea("SXACOPY")
				dbCloseArea()
			EndIf

			If File("\cfglog\sx3x3101.dtc")                                        // SX3
				*************************************************************************
				dbUseArea(.T., 'CTREECDX', "\cfglog\sx3x3101.dtc", "SX3COPY", .T., .F.)

				If 1 == 2

					dbSelectArea("SX3COPY")
					dbSelectArea("SX3")
					APPEND FROM ("SX3COPY")

				Else                         // Necessário testar - 12/06/14
					********************************************************
					dbSelectArea("SX3COPY")
					dbGotop()
					While !Eof()

						dbSelectArea("SX3")
						dbSetOrder(2)
						If !dbSeek(SX3COPY->X3_CAMPO)
							RecLock("SX3",.T.)
						Else
							RecLock("SX3",.F.)
						EndIf
						SX3->X3_ARQUIVO	:= SX3COPY->X3_ARQUIVO
						SX3->X3_ORDEM	:= SX3COPY->X3_ORDEM
						SX3->X3_CAMPO	:= SX3COPY->X3_CAMPO
						SX3->X3_TIPO	:= SX3COPY->X3_TIPO
						SX3->X3_TAMANHO	:= SX3COPY->X3_TAMANHO
						SX3->X3_DECIMAL	:= SX3COPY->X3_DECIMAL
						SX3->X3_TITULO	:= SX3COPY->X3_TITULO
						SX3->X3_TITSPA	:= SX3COPY->X3_TITSPA
						SX3->X3_TITENG	:= SX3COPY->X3_TITENG
						SX3->X3_DESCRIC	:= SX3COPY->X3_DESCRIC
						SX3->X3_DESCSPA	:= SX3COPY->X3_DESCSPA
						SX3->X3_DESCENG	:= SX3COPY->X3_DESCENG
						SX3->X3_PICTURE	:= SX3COPY->X3_PICTURE
						SX3->X3_VALID	:= SX3COPY->X3_VALID
						SX3->X3_USADO	:= SX3COPY->X3_USADO
						SX3->X3_RELACAO	:= SX3COPY->X3_RELACAO
						SX3->X3_F3		:= SX3COPY->X3_F3
						SX3->X3_NIVEL	:= SX3COPY->X3_NIVEL
						SX3->X3_RESERV	:= SX3COPY->X3_RESERV
						SX3->X3_CHECK	:= SX3COPY->X3_CHECK
						SX3->X3_TRIGGER	:= SX3COPY->X3_TRIGGER
						SX3->X3_PROPRI	:= SX3COPY->X3_PROPRI
						SX3->X3_BROWSE	:= SX3COPY->X3_BROWSE
						SX3->X3_VISUAL	:= SX3COPY->X3_VISUAL
						SX3->X3_CONTEXT	:= SX3COPY->X3_CONTEXT
						SX3->X3_OBRIGAT	:= SX3COPY->X3_OBRIGAT
						SX3->X3_VLDUSER	:= SX3COPY->X3_VLDUSER
						SX3->X3_CBOX	:= SX3COPY->X3_CBOX
						SX3->X3_CBOXSPA	:= SX3COPY->X3_CBOXSPA
						SX3->X3_CBOXENG	:= SX3COPY->X3_CBOXENG
						SX3->X3_PICTVAR	:= SX3COPY->X3_PICTVAR
						SX3->X3_WHEN	:= SX3COPY->X3_WHEN
						SX3->X3_INIBRW	:= SX3COPY->X3_INIBRW
						SX3->X3_GRPSXG	:= SX3COPY->X3_GRPSXG
						SX3->X3_FOLDER	:= SX3COPY->X3_FOLDER
						SX3->X3_PYME	:= SX3COPY->X3_PYME
						SX3->X3_CONDSQL	:= SX3COPY->X3_CONDSQL
						SX3->X3_CHKSQL	:= SX3COPY->X3_CHKSQL
						SX3->X3_IDXSRV	:= SX3COPY->X3_IDXSRV
						SX3->X3_ORTOGRA	:= SX3COPY->X3_ORTOGRA
						SX3->X3_IDXFLD	:= SX3COPY->X3_IDXFLD
						SX3->X3_TELA	:= SX3COPY->X3_TELA
						SX3->X3_AGRUP	:= SX3COPY->X3_AGRUP
						MsUnlock()

						dbSelectArea("SX3COPY")
						dbSkip()
					End

				EndIf

				dbSelectArea("SX3COPY")
				dbGoTop()
				While !Eof()

					xdTabela := SX3COPY->X3_ARQUIVO

					__SetX31Mode(.F.)

					If Select(xdTabela) > 0
						xdTabela->(dbCloseArea())
					EndIf
					X31UpdTable(xdTabela)

					dbSelectArea("SX3COPY")
					While !Eof() .and. SX3COPY->X3_ARQUIVO == xdTabela
						dbSkip()
					End

				End

				dbSelectArea("SX3COPY")
				dbCloseArea()

			EndIf

			If File("\cfglog\sx6x3101.dtc") .and. xv_Emps[xt,1] <> "01"            // SX6
				*************************************************************************
				dbUseArea(.T., 'CTREECDX', "\cfglog\sx6x3101.dtc", "SX6COPY", .T., .F.)
				dbSelectArea("SX6COPY")
				dbGotop()
				While !Eof()

					dbSelectArea("SX6")
					If !dbSeek(SX6COPY->X6_FIL+SX6COPY->X6_VAR)
						RecLock("SX6",.T.)
					Else
						RecLock("SX6",.F.)
					EndIf
					SX6->X6_FIL     = SX6COPY->X6_FIL
					SX6->X6_VAR     = SX6COPY->X6_VAR
					SX6->X6_TIPO    = SX6COPY->X6_TIPO
					SX6->X6_DESCRIC = SX6COPY->X6_DESCRIC
					SX6->X6_DSCSPA  = SX6COPY->X6_DSCSPA
					SX6->X6_DSCENG  = SX6COPY->X6_DSCENG
					SX6->X6_DESC1   = SX6COPY->X6_DESC1
					SX6->X6_DSCSPA1 = SX6COPY->X6_DSCSPA1
					SX6->X6_DSCENG1 = SX6COPY->X6_DSCENG1
					SX6->X6_DESC2   = SX6COPY->X6_DESC2
					SX6->X6_DSCSPA2 = SX6COPY->X6_DSCSPA2
					SX6->X6_DSCENG2 = SX6COPY->X6_DSCENG2
					SX6->X6_CONTEUD = SX6COPY->X6_CONTEUD
					SX6->X6_CONTSPA = SX6COPY->X6_CONTSPA
					SX6->X6_CONTENG = SX6COPY->X6_CONTENG
					SX6->X6_PROPRI  = SX6COPY->X6_PROPRI
					SX6->X6_PYME    = SX6COPY->X6_PYME
					SX6->X6_VALID   = SX6COPY->X6_VALID
					SX6->X6_INIT    = SX6COPY->X6_INIT
					SX6->X6_DEFPOR  = SX6COPY->X6_DEFPOR
					SX6->X6_DEFSPA  = SX6COPY->X6_DEFSPA
					SX6->X6_DEFENG  = SX6COPY->X6_DEFENG
					MsUnlock()

					dbSelectArea("SX6COPY")
					dbSkip()
				End

				dbSelectArea("SX6COPY")
				dbCloseArea()
			EndIf

			If File("\cfglog\sx7x3101.dtc") .and. xv_Emps[xt,1] <> "01"            // SX7
				*************************************************************************
				dbUseArea(.T., 'CTREECDX', "\cfglog\sx7x3101.dtc", "SX7COPY", .T., .F.)
				dbSelectArea("SX7COPY")
				dbGotop()
				While !Eof()

					dbSelectArea("SX7")
					If !dbSeek(SX7COPY->X7_CAMPO+SX7COPY->X7_SEQUENC)
						RecLock("SX7",.T.)
					Else
						RecLock("SX7",.F.)
					EndIf
					SX7->X7_CAMPO    := SX7COPY->X7_CAMPO
					SX7->X7_SEQUENC  := SX7COPY->X7_SEQUENC
					SX7->X7_REGRA    := SX7COPY->X7_REGRA
					SX7->X7_CDOMIN   := SX7COPY->X7_CDOMIN
					SX7->X7_TIPO     := SX7COPY->X7_TIPO
					SX7->X7_SEEK     := SX7COPY->X7_SEEK
					SX7->X7_ALIAS    := SX7COPY->X7_ALIAS
					SX7->X7_ORDEM    := SX7COPY->X7_ORDEM
					SX7->X7_CHAVE    := SX7COPY->X7_CHAVE
					SX7->X7_CONDIC   := SX7COPY->X7_CONDIC
					SX7->X7_PROPRI   := SX7COPY->X7_PROPRI
					MsUnlock()

					dbSelectArea("SX7COPY")
					dbSkip()
				End

				dbSelectArea("SX7COPY")
				dbCloseArea()
			EndIf

			If File("\cfglog\sxbx3101.dtc") .and. xv_Emps[xt,1] <> "01"            // SXB
				*************************************************************************
				dbUseArea(.T., 'CTREECDX', "\cfglog\sxbx3101.dtc", "SXBCOPY", .T., .F.)
				dbSelectArea("SXBCOPY")
				dbGotop()
				While !Eof()

					dbSelectArea("SXB")
					If !dbSeek(SXBCOPY->XB_ALIAS+SXBCOPY->XB_TIPO+SXBCOPY->XB_SEQ+SXBCOPY->XB_COLUNA)
						RecLock("SXB",.T.)
					Else
						RecLock("SXB",.F.)
					EndIf
					SXB->XB_ALIAS    := SXBCOPY->XB_ALIAS
					SXB->XB_TIPO     := SXBCOPY->XB_TIPO
					SXB->XB_SEQ      := SXBCOPY->XB_SEQ
					SXB->XB_COLUNA   := SXBCOPY->XB_COLUNA
					SXB->XB_DESCRI   := SXBCOPY->XB_DESCRI
					SXB->XB_DESCSPA  := SXBCOPY->XB_DESCSPA
					SXB->XB_DESCENG  := SXBCOPY->XB_DESCENG
					SXB->XB_CONTEM   := SXBCOPY->XB_CONTEM
					SXB->XB_WCONTEM  := SXBCOPY->XB_WCONTEM
					MsUnlock()

					dbSelectArea("SXBCOPY")
					dbSkip()
				End

				dbSelectArea("SXBCOPY")
				dbCloseArea()
			EndIf

			If File("\cfglog\sxqx3101.dtc") .and. xv_Emps[xt,1] <> "01"            // SXQ
				*************************************************************************
				dbUseArea(.T., 'CTREECDX', "\cfglog\sxqx3101.dtc", "SXQCOPY", .T., .F.)
				dbSelectArea("SXQCOPY")
				dbGotop()
				While !Eof()

					dbSelectArea("SXQ")
					If !dbSeek(SXQCOPY->XQ_ALIAS+SXQCOPY->XQ_SEQ)
						RecLock("SXQ",.T.)
					Else
						RecLock("SXQ",.F.)
					EndIf
					SXQ->XQ_ALIAS    := SXQCOPY->XQ_ALIAS
					SXQ->XQ_SEQ      := SXQCOPY->XQ_SEQ
					SXQ->XQ_PROPRI	 := SXQCOPY->XQ_PROPRI
					SXQ->XQ_REGRA    := SXQCOPY->XQ_REGRA
					MsUnlock()

					dbSelectArea("SXQCOPY")
					dbSkip()
				End

				dbSelectArea("SXQCOPY")
				dbCloseArea()
			EndIf

		EndIf

		RpcClearEnv()

	Next

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BiaOPxFirme ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 21.01.14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Valida OP Firme quando apontamento via MATA250 - primeira- ¦¦¦
¦¦¦          ¦ mente para a empresa VITCER - 14                           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BiaOPxFirme()

	Local xtRetFull := .T.

	Local yAreaAnt := GetArea()

	SC2->(dbSetOrder(1))
	SC2->(dbSeek(xFilial("SC2")+M->D3_OP))

	If Empty(SC2->C2_YDTFIRM)
		Aviso('OP Firme','A OP selecionada ainda não foi FIRMADA. Favor verificar!!!',{'Ok'})
		xtRetFull := .F.
	EndIf

	RestArea(yAreaAnt)

Return ( xtRetFull )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ TESTE DE PE ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 21.01.14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦                                                            ¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function A250ENDE()

	Local nRegSD4 := ParamIXB
	//-- Numero do Registro da tabela SD4 que esta sendo atualizada
	Local cEnd := 'PAP'
	//-- Customizações do Cliente
Return cEnd  //-- Retorna um endereço valida para verificação de saldos

//*****************************************************************************
User Function A250CHEN()

	Local aSD4 := ParamIXB[1]
	//-- Informações do Empenho SD4
	Local nItem := ParamIXB[2]
	//-- Posição do Registro processado
	Local nCampo := ParamIXB[3]
	//-- Posição do Item Processado
	Local cEnd := 'PAP'
	//-- Customizações do Cliente
Return cEnd
//-- Retorna um endereço valida para verificação de saldo

//*****************************************************************************

//Comentado por Gabriel Mafioletti - Ticket 6193 - 09/07/2018
/*
User Function MT250SAL()

Local zpt
Local aSaldos := ParamIxb[1]

If GetMV('MV_RASTRO') == "S"

For zpt := 1 To Len(aSaldos)

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+aSaldos[zpt][1]))
If SB1->B1_RASTRO == "L"
If aSaldos[zpt][4] < 0
If aSaldos[zpt][3] > 0
aSaldos[zpt][4] := ABS(aSaldos[zpt][4])
EndIf
EndIf
EndIf
// Tratamento implementado em 19/01/15 por Marcos Alberto Soprani para resolver problema de arredondamento durante apontamento de produção de PA com consumo de PP
If SB1->B1_TIPO == "PP"
aSaldos[zpt][3]  := Round(aSaldos[zpt][3],2)
EndIf

Next zpt

EndIf

Return(aSaldos)
*/
/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BiaCtRepo01
Empresa   := Biancogres Cerâmica S/A
Data      := 18/06/14
Uso       := Custos
Aplicação := Custo Padrão pela estrutura
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BiaCtRepo01(zPrdBusca)

	Private lNegEstr := GETMV("MV_NEGESTR")
	Private aDadoX   := {}
	Private xSomaRet := .F.
	Private xQtdRetn := 0
	Private ql_PrdRefR := Space(15)
	Private gtVlrRet   := .F.

	aDados2   := {}
	aDadosRet := {}

	// Temporário para evitar buscas sucessivas para um mesmo componente
	xAyCt := {}
	AADD(xAyCt,{ "CODCOMP"    ,"C",15,0 } )
	AADD(xAyCt,{ "CUSTO"      ,"N",18,8 } )
	AADD(xAyCt,{ "ULTCOM"     ,"D",08,0 } )
	AADD(xAyCt,{ "EMPR"       ,"C",02,0 } )
	AADD(xAyCt,{ "REFER"      ,"C",02,0 } )
	T002 := CriaTrab(xAyCt)
	dbUseArea( .T.,, T002, "T002", .F., .F. )
	dbCreateInd(T002, "CODCOMP" ,{ || Indices })

	// Monta referência para diluir o retorno da Massa na formulação da massa. Usado apenas para PI MASSA
	AK007 := " SELECT G1_COD, G1_TRT, SUM(G1_YMISTUR) PERC
	AK007 += "   FROM "+RetSqlName("SG1")+" SG1
	AK007 += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	AK007 += "                      AND B1_COD = G1_COD
	AK007 += "                      AND B1_GRUPO = 'PI01'
	AK007 += "                      AND SB1.D_E_L_E_T_ = ' '
	AK007 += " INNER JOIN " + RetSqlName("SBZ") + " SBZ ON BZ_FILIAL = '" + xFilial("SBZ") + "'
	AK007 += "                      AND BZ_COD = G1_COD
	AK007 += "                      AND SBZ.D_E_L_E_T_ = ' '
	AK007 += "  WHERE G1_FILIAL = '"+xFilial("SG1")+"'
	AK007 += "    AND G1_REVINI >= B1_REVATU
	AK007 += "    AND G1_REVFIM <= B1_REVATU
	AK007 += "    AND SG1.D_E_L_E_T_ = ' '
	AK007 += "  GROUP BY G1_COD, G1_TRT
	AK007 := ChangeQuery(AK007)
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,AK007),'AK07',.T.,.T.)
	aStruX := ("AK07")->(dbStruct())
	/*----- Exporta os dados do resultado de uma Query para um arquivo temporário normal -----*/
	gh_IndX := "G1_COD"
	If !chkfile("AK08")
		AK08 := U_BIACrTMP(aStruX)
		dbUseArea( .T.,, AK08, "AK08", .F., .F. )
		dbCreateInd(AK08, gh_IndX,{ || gh_IndX })
	EndIf
	dbSelectArea("AK08")
	APPEND FROM ("AK07")
	If Select("AK07") > 0
		AK07->(dbCloseArea())
	Endif

	fxCodRef := zPrdBusca

	dbSelectArea("SB1")
	dbSeek(xFilial("SB1")+fxCodRef)

	dbSelectArea("SBZ")
	dbSeek(xFilial("SBZ") + fxCodRef)

	nEstru     := 0
	wProduto   := fxCodRef
	wQtd       := IIF(SB1->B1_QB == 0, 1, SB1->B1_QB)
	wpRevAtu   := SB1->B1_REVATU
	wpNiv      := 1
	cArqTmp    := ""
	cAliasTRB  := cArqTRB := "Estrut"

	xQtdRetn   := 0

	cNome      := Processa({|| StrutCRPBia(wProduto, wQtd, cAliasTRB, cArqTRB, .F., wpRevAtu, wpNiv) })
	cArqTRB    := cArqTmp
	ESTRUT->(dbGoTop())
	ProcRegua(RecCount())
	While ESTRUT->(!Eof())

		gtVlrRet  := .F.
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Componente: "+ESTRUT->COMP+"  Tempo: "+cTempo)

		xk_UltCom := ctod("  /  /  ")
		wk_RefVl  := ""
		xk_EmpOri := Space(2)

		dbSelectArea("T002")
		If !dbSeek(ESTRUT->COMP)
			SBZ->(dbSetOrder(1))
			SBZ->(dbSeek(xFilial("SBZ")+ESTRUT->COMP))
			// A regra a seguir se fez necessária em virtude da inclusão do custo do Produto Retificado nesta rotina. Possivelmente, no futuro (qualquer coisa após a data de 23/11/11)
			// poderemos mudar esta configuração, colocando algum produto na estrutura do Produto Acabado Retificado.
			cs_VdRetif := .F.
			If Posicione("SB1", 1, xFilial("SB1")+ ESTRUT->COMP,"B1_TIPO") == "PA"
				SBZ->(dbSetOrder(1))
				SBZ->(dbSeek(xFilial("SBZ")+wProduto))
				cs_VdRetif := .T.
			EndIf
			xk_Custo := 0
			If SBZ->BZ_YCTREF == 0
				A0001 := " SELECT ISNULL((SELECT SUM(SD1.D1_CUSTO) / SUM(SD1.D1_QUANT)
				A0001 += "                  FROM "+RetSqlName("SD1")+" SD1
				A0001 += "                 INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
				A0001 += "                                      AND F4_CODIGO = D1_TES
				A0001 += "                                      AND F4_ESTOQUE = 'S'
				A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '
				A0001 += "                 INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = D1_FILIAL
				A0001 += "                                      AND F1_DOC = D1_DOC
				A0001 += "                                      AND F1_SERIE = D1_SERIE
				A0001 += "                                      AND F1_FORNECE = D1_FORNECE	
				A0001 += "                                      AND F1_LOJA = D1_LOJA
				A0001 += "                                      AND F1_EMISSAO = D1_EMISSAO
				A0001 += "                                      AND F1_STATUS <> 'B'
				A0001 += "                                      AND SF1.D_E_L_E_T_ = ' '
				A0001 += "                 WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'
				A0001 += "                   AND SD1.D1_COD = '"+ESTRUT->COMP+"'
				A0001 += "                   AND SD1.D1_DTDIGIT <= '"+dtos(dDataBase)+"'
				A0001 += "                   AND SD1.D1_LOCAL = '01'
				A0001 += "                   AND SD1.D1_TES NOT IN('397','3I7')
				A0001 += "                   AND SD1.D1_DTDIGIT IN(SELECT MAX(XD1.D1_DTDIGIT)
				A0001 += "                                           FROM "+RetSqlName("SD1")+" XD1
				A0001 += "                                          INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
				A0001 += "                                                               AND F4_CODIGO = D1_TES
				A0001 += "                                                               AND F4_ESTOQUE = 'S'
				A0001 += "                                                               AND SF4.D_E_L_E_T_ = ' '
				A0001 += "                                          INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = XD1.D1_FILIAL
				A0001 += "                                                               AND F1_DOC = XD1.D1_DOC
				A0001 += "                                                               AND F1_SERIE = XD1.D1_SERIE
				A0001 += "                                                               AND F1_FORNECE = XD1.D1_FORNECE	
				A0001 += "                                                               AND F1_LOJA = XD1.D1_LOJA
				A0001 += "                                                               AND F1_EMISSAO = XD1.D1_EMISSAO
				A0001 += "                                                               AND F1_STATUS <> 'B'
				A0001 += "                                                               AND SF1.D_E_L_E_T_ = ' '
				A0001 += "                                          WHERE XD1.D1_FILIAL = '"+xFilial("SD1")+"'
				A0001 += "                                            AND XD1.D1_COD = '"+ESTRUT->COMP+"'
				A0001 += "                                            AND XD1.D1_LOCAL = '01'
				A0001 += "                                            AND XD1.D1_DTDIGIT <= '"+dtos(dDataBase)+"'
				A0001 += "                                            AND XD1.D1_TIPO = 'N'
				A0001 += "                                            AND XD1.D1_QUANT <> 0
				A0001 += "                                            AND XD1.D_E_L_E_T_ = ' ')
				A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) EMP_ATU,
				A0001 += "         ISNULL((SELECT MAX(XD1.D1_DTDIGIT)
				A0001 += "                   FROM "+RetSqlName("SD1")+" XD1
				A0001 += "                  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
				A0001 += "                                       AND F4_CODIGO = D1_TES
				A0001 += "                                       AND F4_ESTOQUE = 'S'
				A0001 += "                                       AND SF4.D_E_L_E_T_ = ' '
				A0001 += "                  INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = XD1.D1_FILIAL
				A0001 += "                                       AND F1_DOC = XD1.D1_DOC
				A0001 += "                                       AND F1_SERIE = XD1.D1_SERIE
				A0001 += "                                       AND F1_FORNECE = XD1.D1_FORNECE	
				A0001 += "                                       AND F1_LOJA = XD1.D1_LOJA
				A0001 += "                                       AND F1_EMISSAO = XD1.D1_EMISSAO
				A0001 += "                                       AND F1_STATUS <> 'B'
				A0001 += "                                       AND SF1.D_E_L_E_T_ = ' '
				A0001 += "                  WHERE XD1.D1_FILIAL = '"+xFilial("SD1")+"'
				A0001 += "                    AND XD1.D1_COD = '"+ESTRUT->COMP+"'
				A0001 += "                    AND XD1.D1_DTDIGIT <= '"+dtos(dDataBase)+"'
				A0001 += "                    AND XD1.D1_LOCAL = '01'
				A0001 += "                    AND XD1.D1_TES NOT IN('397','3I7')
				A0001 += "                    AND XD1.D1_TIPO = 'N'
				A0001 += "                    AND XD1.D1_QUANT <> 0
				A0001 += "                    AND XD1.D_E_L_E_T_ = ' '), '        ') DT_E_ATU
				TcQuery A0001 ALIAS "A001" NEW
				dbSelectArea("A001")
				dbGoTop()
				xk_Custo  := A001->EMP_ATU
				xk_UltCom := stod(A001->DT_E_ATU)
				wk_RefVl  := "NF"
				xk_EmpOri := cEmpAnt
				A001->(dbCloseArea())
			Else
				If SBZ->BZ_COD < "A"
					xk_Custo   := SBZ->BZ_YCTREF
					wk_RefVl   := "I "
					xk_UltCom  := SBZ->BZ_YDTCTRF
					xk_EmpOri  := cEmpAnt
				Else
					If Posicione("SB1", 1, xFilial("SB1")+wProduto,"B1_YACABAM") $ "002/004/007" .and. Posicione("SB1", 1, xFilial("SB1")+ESTRUT->COMP,"B1_TIPO") == "PA"
						xk_Custo   := SBZ->BZ_YCTREF
						wk_RefVl   := "R "
						xk_UltCom  := SBZ->BZ_YDTCTRF
						xk_EmpOri  := cEmpAnt
						xdContaC   := "RETIFICADO"
						xdDescrC   := "SERVICO DE RETIFICACAO"
						If xk_Custo <> 0
							gtVlrRet    := .T.
						EndIf
					EndIf
				EndIf
			EndIf
			// Acumula dados para não precisar ficar executando querys sucessivas para o mesmo componente.
			If !cs_VdRetif
				dbSelectArea("T002")
				RecLock("T002",.T.)
				T002->CODCOMP := ESTRUT->COMP
				T002->CUSTO   := xk_Custo
				T002->ULTCOM  := xk_UltCom
				T002->EMPR    := xk_EmpOri
				T002->REFER   := wk_RefVl
				MsUnLock()
			EndIf
		Else
			xk_Custo   := T002->CUSTO
			xk_UltCom  := T002->ULTCOM
			xk_EmpOri  := T002->EMPR
			wk_RefVl   := T002->REFER
		EndIf

		// Controle de Projeção de Custo
		xf_Projetd := xk_Custo
		Z04->(dbSetOrder(1))
		If Z04->(dbSeek(xFilial("Z04") + ESTRUT->COMP))

			xf_QuantRf  := 0
			xf_CtVlrRf  := 0
			xf_CtFrtRf  := 0
			//   As regras que seguem abaixo se fazem necessárias porque a QUERY principal do programa traz
			//o valor do frete aglutinado ao valor da mercadoria.
			//   Neste ponto do programa, estas duas informações necessitam ser separadas.
			PX001 := " SELECT SD1.D1_QUANT, SD1.D1_CUSTO
			PX001 += "   FROM "+RetSqlName("SD1")+" SD1
			PX001 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
			PX001 += "                       AND F4_CODIGO = D1_TES
			PX001 += "                       AND F4_ESTOQUE = 'S'
			PX001 += "                       AND SF4.D_E_L_E_T_ = ' '
			PX001 += "  INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = SD1.D1_FILIAL
			PX001 += "                       AND F1_DOC = SD1.D1_DOC
			PX001 += "                       AND F1_SERIE = SD1.D1_SERIE
			PX001 += "                       AND F1_FORNECE = SD1.D1_FORNECE	
			PX001 += "                       AND F1_LOJA = SD1.D1_LOJA
			PX001 += "                       AND F1_EMISSAO = SD1.D1_EMISSAO
			PX001 += "                       AND F1_STATUS <> 'B'
			PX001 += "                       AND SF1.D_E_L_E_T_ = ' '
			PX001 += "  WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'
			PX001 += "    AND SD1.D1_COD = '"+ESTRUT->COMP+"'
			PX001 += "    AND SD1.D1_LOCAL = '01'
			PX001 += "    AND SD1.D1_TES NOT IN('397','3I7')
			PX001 += "    AND SD1.D1_DTDIGIT = '"+dtos(xk_UltCom)+"'
			PX001 += "    AND SD1.D_E_L_E_T_ = ' '
			PX001 += "  ORDER BY D1_QUANT DESC
			TcQuery PX001 ALIAS "PX01" NEW
			dbSelectArea("PX01")
			dbGoTop()
			While !Eof()
				If PX01->D1_QUANT > 0
					xf_QuantRf  += PX01->D1_QUANT
					xf_CtVlrRf  += PX01->D1_CUSTO
				Else
					xf_CtFrtRf  += PX01->D1_CUSTO
				EndIf
				dbSelectArea("PX01")
				dbSkip()
			End
			PX01->(dbCloseArea())

			// Monta o Custo unitário do Valor da Mercadoria e do Frete
			xf_CtPrjtVl := 0
			xf_CtPrjtFr := 0
			If xf_QuantRf > 0
				xf_CtPrjtVl := xf_CtVlrRf / xf_QuantRf
				xf_CtPrjtFr := xf_CtFrtRf / xf_QuantRf
			EndIf
			If Z04->Z04_INCIVL == "1"   // Percentual
				xf_CtPrjtVl := xf_CtPrjtVl + (xf_CtPrjtVl*Z04->Z04_VALOR/100)
			ElseIf Z04->Z04_INCIVL == "2"   // Valor
				xf_CtPrjtVl := Z04->Z04_VALOR
			EndIf
			If Z04->Z04_INCIFR == "1"   // Percentual
				xf_CtPrjtFr := xf_CtPrjtFr + (xf_CtPrjtFr*Z04->Z04_FRETE/100)
			ElseIf Z04->Z04_INCIFR == "2"   // Valor
				xf_CtPrjtFr := Z04->Z04_FRETE
			EndIf
			xf_Projetd := xf_CtPrjtVl + xf_CtPrjtFr

		EndIf

		// Necessidade de posicionar no componente para buscar a UMIDADE PADRÃO.
		SBZ->(dbSetOrder(1))
		SBZ->(dbSeek(xFilial("SBZ")+ESTRUT->COMP))

		Aadd(aDados2, { ESTRUT->PRODPAI,;
		ESTRUT->ORDEM,;
		ESTRUT->CODIGO,;
		ESTRUT->COMP,;
		ESTRUT->TRT,;
		ESTRUT->QUANT,;
		ESTRUT->QTDORI,;
		ESTRUT->NIVEL,;
		xk_Custo,;
		xk_UltCom,;
		xk_EmpOri,;
		xf_Projetd,;
		wk_RefVl,;
		SBZ->BZ_YUMIDAD} )

		i := Len(aDados2)

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+aDados2[i][3]))

		// Tratamento feito em 27/06/14 para não duplica o custo de produtos que podem ser feitos pela Biancogres e Vitcer concomitantemente...
		If ( Substr(aDados2[i][3],1,3) $ "RET/ETA" .or. Substr(aDados2[i][4],1,3) $ "RET/ETA" ) .and. gtVlrRet
			ESTRUT->(dbSkip())
			Loop
		EndIf

		ql_GrpCod := Alltrim(SB1->B1_GRUPO)
		If SB1->B1_TIPO == "PA" .and. Empty(ql_PrdRefR) .and. Alltrim(aDados2[i][3]) <> Alltrim(wProduto) //.and. Substr(SB1->B1_COD,1,2) == "C1"
			ql_PrdRefR := aDados2[i][3]
		EndIf
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+aDados2[i][4]))
		If ql_GrpCod $ Alltrim(MV_PAR04) .or. Alltrim(SB1->B1_GRUPO) $ Alltrim(MV_PAR04) .or. Empty(MV_PAR04)

			// Calcula percetual da Projeção
			ql_Quant := aDados2[i][6]
			ql_Perct := 0

			// Novo tratamento para adicional de umidade
			If aDados2[i][14] <> 0
				ql_Quant := ql_Quant/(-(((aDados2[i][14]/100)/1)-1))
			EndIf

			If (ql_Quant*aDados2[i][12]) - (ql_Quant*aDados2[i][9]) <> 0
				If aDados2[i][9] == 0
					ql_Perct := 100
				Else
					ql_Perct := ((ql_Quant*aDados2[i][12]) - (ql_Quant*aDados2[i][9])) / (ql_Quant*aDados2[i][9]) * 100
				EndIf
			EndIf

			// KEY para amarração entre o padrão e o realizado
			xdContaC := ""
			xdDescrC := ""
			CT1->(dbSetOrder(1))
			If CT1->(dbSeek(xFilial("CT1")+SB1->B1_YCTRIND))
				xdContaC := Substr(CT1->CT1_YAGRUP,1,20)
				If CT1->(dbSeek(xFilial("CT1")+xdContaC))
					xdDescrC := CT1->CT1_DESC01
				EndIf
			EndIf
			If Alltrim(aDados2[i][4]) == "1030019"
				xdContaC := "MODRCOG"
				xdDescrC := "COGERACAO"
			EndIf

			//        1         , 2    , 3     , 4   , 5  , 6    , 7    , 8        , 9       , 10         , 11     , 12         , 13            , 14           , 15     , 16         , 17
			// Vetor: ProdutoPai, Ordem, Codigo, Comp, TRT, Nível, Quant, CustoUnit, CustoTot, OrigemCusto, DataRef, EmpresaOrig, CustoProjetado, PercProjetado, Umidade, ContaContab, DescrContab
			Aadd(aDadosRet, { aDados2[i][1]   ,;
			aDados2[i][2]                     ,;
			aDados2[i][3]                     ,;
			aDados2[i][4]                     ,;
			aDados2[i][5]                     ,;
			aDados2[i][8]                     ,;
			ql_Quant                          ,;
			aDados2[i][9]                     ,;
			ql_Quant * aDados2[i][9]          ,;
			aDados2[i][13]                    ,;
			dtoc(aDados2[i][10])              ,;
			aDados2[i][11]                    ,;
			ql_Quant * aDados2[i][12]         ,;
			ql_Perct                          ,;
			aDados2[i][14]                    ,;
			xdContaC                          ,;
			xdDescrC                          })

		EndIf

		ESTRUT->(dbSkip())
	End
	U_BIAFimStru(cAliasTRB,cArqTRB)

	//-----------------------------------------------------------
	// Bloco do programa destinado ao tratamento dos custos fixos
	If MV_PAR07 <> 1

		A0007 := " SELECT TOP 1 "+IIF(MV_PAR07 == 2, "Z13_CUSTFX", "Z13_DESPFX")+" Z13_CUSTFX
		A0007 += "   FROM "+RetSqlName("Z13")+" Z13
		A0007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
		A0007 += "                       AND B1_COD = '"+IIF(Empty(ql_PrdRefR), fxCodRef, ql_PrdRefR)+"'
		A0007 += "                       AND SB1.D_E_L_E_T_ = ' '
		//A0007 += "  INNER JOIN "+RetSqlName("ZZ7")+" ZZ7 ON ZZ7_FILIAL = '"+xFilial("ZZ7")+"'
		//A0007 += "                       AND ZZ7_COD = B1_YLINHA
		//A0007 += "                       AND ZZ7_LINSEQ = B1_YLINSEQ
		//A0007 += "                       AND ZZ7.D_E_L_E_T_ = ' '
		A0007 += "  WHERE Z13_FILIAL = '"+xFilial("Z13")+"'
		A0007 += "    AND '"+dtos(dDataBase)+"' >= Z13_DATADE
		A0007 += "    AND '"+dtos(dDataBase)+"' <= Z13_DATAAT
		A0007 += "    AND Z13_TIPO = '03'
		A0007 += "    AND Z13_FORMAT = B1_YFORMAT
		//A0007 += "    AND Z13_LINHCR = ZZ7_TIPO
		A0007 += "    AND Z13.D_E_L_E_T_ = ' '
		A0007 += "  ORDER BY Z13_PLANO DESC
		TcQuery A0007 ALIAS "A007" NEW
		dbSelectArea("A007")
		dbGoTop()

		//        1         , 2    , 3     , 4   , 5  , 6    , 7    , 8        , 9       , 10         , 11     , 12         , 13            , 14           , 15     , 16         , 17
		// Vetor: ProdutoPai, Ordem, Codigo, Comp, TRT, Nível, Quant, CustoUnit, CustoTot, OrigemCusto, DataRef, EmpresaOrig, CustoProjetado, PercProjetado, Umidade, ContaContab, DescrContab
		Aadd(aDadosRet, { fxCodRef        ,;
		'999'                             ,;
		fxCodRef                          ,;
		'C.FIXO'                          ,;
		'   '                             ,;
		999                               ,;
		1                                 ,;
		A007->Z13_CUSTFX                  ,;
		1 * A007->Z13_CUSTFX              ,;
		'FX'                              ,;
		dtoc(dDataBase)                   ,;
		cEmpAnt                           ,;
		1 * A007->Z13_CUSTFX              ,;
		1                                 ,;
		0                                 ,;
		'C.FIXO'                          ,;
		'CUSTO FIXO'                      })
		A007->(dbCloseArea())

	EndIf

	T002->(dbCloseArea())

Return ( aDadosRet )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Função   ¦ StrutCRPBia ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 18/06/14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Ação     ¦ Navega Estrutura de Produto para Acumular quantidades que  ¦¦¦
¦¦¦          ¦ servirão de base para custo variável                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function StrutCRPBia(cProduto, nQuant, cAliasEstru, cArqTrab, lAsShow, cRevisao, xNivel)

	LOCAL nRegi   := 0, nQuantItem := 0
	LOCAL aCampos := {}, aTamSX3:={}, lAdd :=.F.
	LOCAL nRecno
	cAliasEstru   := IIF(cAliasEstru == NIL,"ESTRUT",cAliasEstru)
	nQuant        := IIF(nQuant == NIL,1,nQuant)
	lAsShow       := IIF(lAsShow==NIL,.F.,lAsShow)
	xNivel        := IIF(xNivel == NIL, 1, xNivel)
	nEstru++
	If nEstru == 1
		xk_Ordem := 0
		aTamSX3:=TamSX3("G1_COD")
		AADD(aCampos,{"PRODPAI","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_TRT")
		AADD(aCampos,{"ORDEM","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_COD")
		AADD(aCampos,{"CODIGO","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_COMP")
		AADD(aCampos,{"COMP","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_TRT")
		AADD(aCampos,{"TRT","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_QUANT")
		AADD(aCampos,{"QUANT","N",Max(aTamSX3[1],18),aTamSX3[2]})
		aTamSX3:=TamSX3("G1_QUANT")
		AADD(aCampos,{"QTDORI","N",Max(aTamSX3[1],18),aTamSX3[2]})
		aTamSX3:=TamSX3("G1_NIV")
		AADD(aCampos,{"NIVEL","N",Max(aTamSX3[1],18),aTamSX3[2]})
		cArqTrab := CriaTrab(aCampos)
		If Select(cAliasEstru) > 0
			dbSelectArea(cAliasEstru)
			dbCloseArea()
		EndIf
		Use &cArqTrab NEW Exclusive Alias &(cAliasEstru)
		IndRegua(cAliasEstru,cArqTrab,"CODIGO+COMP+TRT",,,"Selecionando Registros...")
		dbSetIndex(cArqtrab+OrdBagExt())
	EndIf

	dbSelectArea("SG1")
	dbSetOrder(1)
	dbSeek(xFilial("SG1")+cProduto)

	ProcRegua(RecCount())
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Estrutura....   Tempo: "+cTempo)

	While !Eof() .and. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cProduto
		nRegi:=Recno()
		If SG1->G1_COD != SG1->G1_COMP
			lAdd:=.F.
			If dDataBase >= SG1->G1_INI .and. dDataBase <= SG1->G1_FIM

				// Retorno somado à Massa. Incluido em 30/09/11 para equiparação do programa ao que o Jecimar faz no excel
				sm_Perc := 0
				sm_QtdPlus := 0
				sm_QtdBkp := nQuant
				If AK08->(dbSeek(SG1->G1_COD)) .and. AK08->PERC < 100
					sm_Perc := (SG1->G1_YMISTUR / AK08->PERC) * 100
					sm_QtdPlus := sm_Perc * nQuant / SG1->G1_YMISTUR
					nQuant := sm_QtdPlus
					xSomaRet := .T.
					xQtdRetn := AK08->PERC
				EndIf

				// Cálculo padrão do sistema para perda
				// nQuantItem := ((nQuant * nG1Quant) / (100 - G1_PERDA)) * 100
				// nQuant = Quantidade Pai
				// nG1Quant = Quantidade Corrente do Componente
				nQuantItem := ExplEstr(nQuant,,,cRevisao)
				nQuant := sm_QtdBkp

				If (lNegEstr .Or. (!lNegEstr .And. QtdComp(nQuantItem,.T.) > QtdComp(0) )) .And. (QtdComp(nQuantItem,.T.) # QtdComp(0,.T.))

					dbSelectArea(cAliasEstru)
					xk_Ordem ++
					RecLock(cAliasEstru,.T.)
					ESTRUT->ORDEM  := StrZero(xk_Ordem,3)
					ESTRUT->PRODPAI:= wProduto
					ESTRUT->CODIGO := SG1->G1_COD
					ESTRUT->COMP   := SG1->G1_COMP
					ESTRUT->TRT    := SG1->G1_TRT
					If MV_PAR03 == 1
						ESTRUT->QUANT  := ( nQuantItem * (100 - SG1->G1_PERDA) ) / 100
					ElseIf MV_PAR03 == 2
						ESTRUT->QUANT  := nQuantItem
					EndIf
					ESTRUT->QTDORI := SG1->G1_QUANT
					ESTRUT->NIVEL  := xNivel
					MsUnlock()
					lAdd:=.T.
				EndIf
				dbSelectArea("SG1")

				// Verifica se existe sub-estrutura
				nRecno:=Recno()
				IF dbSeek(xFilial("SG1")+SG1->G1_COMP)
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+SG1->G1_COD))
					SBZ->(dbSetOrder(1))
					SBZ->(dbSeek(xFilial("SBZ") + SG1->G1_COD))
					StrutCRPBia(SG1->G1_COD, nQuantItem, cAliasEstru, cArqTrab, lAsShow, SB1->B1_REVATU, xNivel+1)
					nEstru --
				Endif
			EndIf
		EndIf
		dbGoto(nRegi)
		dbSkip()
	End
	cArqTmp := cArqTrab

Return cArqTrab

// ------------------------------------- Fim BiaCtRepo01 -------------------------------------
// -------------------------------------------------------------------------------------------

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BConvXlsDbf ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 27.02.14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Converte Arquivo Xls em DBF                                ¦¦¦
¦¦¦          ¦ Dentro do Sistema tem que existir o arquivo convxls.xls    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BConvXlsDbf()

	Local oDlg, oExcelApp
	Local cTemp := GetTempPath()
	Local cSystem := Upper(GetSrvProfString("STARTPATH",""))
	Local cArqMacro := "ConvXLS.xls"
	Local cNomeXLS := Lower(CriaTrab(Nil,.f.))
	Private cArquivo := Space(100)
	Private nLin := 18
	Private nCol1 := 16
	Private nCol2 := 40
	Private nCol3 := 170
	Private bOk := { || If(ValidaDir(), (lOk:=.T.,oDlg:End()) ,) }
	Private bCancel := { || lOk:=.F.,oDlg:End() }

	Private oComboBox1
	Private nComboBox1 := 0

	//Set Deleted On
	Define MsDialog oDlg Title "Diretório" From 08,15 To 20,65 Of GetWndDefault()
	@nLin,nCol1 Say "Diretorio:" Size 050,10 Of oDlg Pixel
	@nLin,nCol2 MsGet cArquivo Size 110,08 Of oDlg Pixel

	@nLin+18,nCol1 SAY oSay1 PROMPT "Layout: " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@nLin+15,nCol2 MSCOMBOBOX oComboBox1 VAR nComboBox1 ITEMS {"Meta Receita (Layout BPC)","Meta Receita (Layout Livre)"} SIZE 082, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@nLin,nCol3-15 Button "…" Size 010,10 Action Eval({|| SelectFile() }) Of oDlg Pixel

	Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

	If !File(alltrim(cArquivo))
		MsgStop("Caminho ou Arquivo inválido!","Atenção")
		Return .F.
	Endif

	//Apaga o Arquivo XLS do diretorio temporario caso ja exista
	If File(cTemp+cNomeXLS+".xls")
		fErase(cTemp+cNomeXLS+".xls")
	EndIf

	//Copia o arquivo XLS para o Temporario para ser executado
	If !AvCpyFile(cArquivo,cTemp+cNomeXLS+".xls",.T.) .and. !File(cTemp+cNomeXLS+".xls")
		MsgInfo("Problemas na copia do arquivo "+cArquivo+" para "+cTemp+cNomeXLS+".xls" ,"AvCpyFile()")
		Return .F.
	EndIf

	If File(cTemp+cArqMacro)
		fErase(cTemp+cArqMacro)
	EndIf

	//Copia o arquivo XLS para o Temporario para ser executado
	If !AvCpyFile(cSystem+cArqMacro,cTemp+cArqMacro,.T.) .and. !File(cTemp+cArqMacro)
		MsgInfo("Problemas na copia do arquivo "+cSystem+cArqMacro+" para "+cTemp+cArqMacro ,"AvCpyFile()")
		Return .F.
	EndIf

	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cTemp+cArqMacro) //Instancia a macro

	U_BIAMsgRun("Aguarde... Convertendo arquivo... ",,{|| oExcelApp:Run(cArqMacro+'!XLS2DBF',cTemp,cNomeXLS,"Exemplo") })

	oExcelApp:Quit()
	oExcelApp:Destroy()

	If Select("TMP") > 0
		TMP->(dbCloseArea())
	EndIf

	//Exclui o arquivo DBF antigo (se existir) e copia o novo
	If File(cSystem+cNomeXLS+".Dbf")
		fErase(cSystem+cNomeXLS+".Dbf") //Deleta o arquivo DBF de origem
	EndIf

	//Copia o arquivo DBF do temporário para o System (Rootpath)
	If !AvCpyFile(cTemp+cNomeXLS+".Dbf",cSystem+cNomeXLS+".Dbf",.T.) .or. !File(cSystem+cNomeXLS+".Dbf")
		MsgInfo("Problemas na copia do arquivo "+cTemp+cNomeXLS+".DBF para "+ cSystem+cNomeXLS+".Dbf" ,"AvCpyFile()")
		Return .F.
	EndIf

	dbUseArea(.T.,"DBFCDXADS",cNomeXLS+".Dbf","BIATMP",.T.,.F.)

	DbSelectArea("BIATMP")
	DbGoTop()

Return .T.

//————————————————————————————————-//
//————————————————————————————————-//
Static Function SelectFile()

	Local cMaskDir := "Arquivos Microsoft Excel (*.xls) |*.xls| Arquivos Microsoft Excel (*.xlsx) |*.xlsx|"
	Local cTitTela := "Arquivo para a integracao"
	Local lInfoOpen := .T.
	Local lDirServidor := .T.
	Local cOldFile := cArquivo

	cArquivo := cGetFile(cMaskDir,cTitTela,,cArquivo,lInfoOpen, (GETF_LOCALHARD+GETF_NETWORKDRIVE) ,lDirServidor)

	If !File(cArquivo)
		MsgStop("Arquivo Não Existe!")
		cArquivo := cOldFile
		Return .F.
	EndIf

Return .T.

//————————————————————————————————-//
//————————————————————————————————-//
Static Function ValidaDir()
	Local lRet := .T.

	If Empty(cArquivo)
		MsgStop("Selecione um arquivo","Atenção")
		lRet := .F.
	ElseIf !File(cArquivo)
		MsgStop("Selecione um arquivo válido!","Atenção")
		lRet := .F.
	EndIf

Return lRet

//————————————————————————————————-//
//————————————————————————————————-//
User Function teste001()

	Local xfValid := U_BConvXlsDbf()

	If xfValid

		dbSelectArea("BIATMP")
		dbGoTop()
		While BIATMP->(!Eof())



			BIATMP->(DbSkip())
		End

		dbSelectArea("BIATMP")
		dbCloseArea()

	EndIf

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Felipe Caiado Almeida
.         := Marcos Alberto Soprani (Concedido por Julio Cesar Almeida)
Empresa   := Biancogres Ceramica S.A.
Data      := 01/03/09
.         := 15/04/14
Uso       := SigaCFG
Aplicação := Gerar planilhas de excel a partir de uma query com scrit válido
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function BiaGerQry1()

	//Variaveis Locais da Funcao
	Local _cSql	 := ""
	Local oMemo
	Local aButtons := {{"BMPTRG", {||Iif(ValidaQuery(_cSql),;
	MsAguarde({|| fVisQry(_cSql)},"Aguarde...","Gerando Visualização..."),;
	MsgAlert("Existe um erro na query digitada"))},"Run (F5)"},;
	{"MDIEXCEL", {||Processa({|| fGeraExcel(aStruct)},"Excel", "Exportação Excel, aguarde...")},"Excel (F8)"},;
	{"S4WB005N", {||Iif(ValidaQuery(_cSql),fRelat(_cSql, fMontaRes(_cSql)),MsgAlert("Existe um erro na query digitada"))},"Relatório"}}
	// Variaveis Private da Funcao
	Private _oDlg				// Dialog Principal
	Private aStruct := {}
	Private oGetDados1

	//	aStruct := fMontaRes(_cSql)

	DEFINE MSDIALOG _oDlg TITLE OemtoAnsi("Contrutor de Query") FROM C(178),C(181) TO C(650),C(1050) PIXEL

	// Cria Componentes Padroes do Sistema
	@ C(014),C(004) GET oMemo Var _cSql MEMO Size C(430),C(80) PIXEL OF _oDlg

	fGetDados1()

	SetKey(VK_F5, {||Iif(ValidaQuery(_cSql),;
	MsAguarde({|| fVisQry(_cSql)},"Aguarde...","Gerando Visualização..."),;
	MsgAlert("Existe um erro na query digitada"))} )

	SetKey(VK_F8, {||Processa({|| fGeraExcel(aStruct)},"Excel", "Exportação Excel, aguarde...")} )

	ACTIVATE MSDIALOG _oDlg ON INIT EnchoiceBar(_oDlg,{|| _oDlg:End()},{|| _oDlg:End()},,aButtons) CENTERED

	SetKey(VK_F5, Nil)
	SetKey(VK_F8, Nil)

Return(.T.)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fGetDados1  ³ Autor ³ Felipe Caiado Almeida ³ Data ³01/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da GetDados                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao ³ O Objeto oGet1  foi criado como Private no inicio do Fonte   ³±±
±±³           ³ desta forma voce podera trata-lo em qualquer parte do        ³±±
±±³           ³ seu programa:                                                ³±±
±±³           ³ Para acessar o aCols desta MsNewGetDados: oGet1 :aCols[nX,nY]³±±
±±³           ³ Para acessar o aHeader: oGet1 :aHeader[nX,nY]                ³±±
±±³           ³ Para acessar o "n"    : oGet1 :nAT                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fGetDados1(aStruct)

	// Variaveis deste Form
	Local nX			:= 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis da MsNewGetDados()      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Vetor responsavel pela montagem da aHeader
	Local aCpoGDa       	:= {}
	// Vetor com os campos que poderao ser alterados
	Local aAlter       	:= {""}
	Local nSuperior    	:= C(100)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
	Local nEsquerda    	:= C(004)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
	Local nInferior    	:= C(232)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
	Local nDireita     	:= C(434)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
	// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia
	Local nOpc         	:= 0//GD_INSERT+GD_DELETE+GD_UPDATE
	Local cLinhaOk     	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols
	Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
	Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.
	// Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do
	// segundo campo>+..."
	Local nFreeze      	:= 000              // Campos estaticos na GetDados.
	Local nMax         	:= 000              // Numero maximo de linhas permitidas. Valor padrao 99
	Local cCampoOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo
	Local cSuperApagar 	:= ""               // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
	Local cApagaOk     	:= "AllwaysTrue"    // Funcao executada para validar a exclusao de uma linha do aCols
	// Objeto no qual a MsNewGetDados sera criada
	Local oWnd          	:= _oDlg
	Local aHead        	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader
	Local aCol         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols
	_aTipo := {}
	_aTam := {}
	_aDec := {}
	If ValType(aStruct) == "A"
		For nX:=1 to Len(aStruct)
			Aadd(aCpoGDa,aStruct[nX,1])
			Aadd(_aTipo,aStruct[nX,2])
			Aadd(_aTam,aStruct[nX,3])
			Aadd(_aDec,aStruct[nX,4])
		Next
	EndIf
	// Carrega aHead
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2)) // Campo
	For nX := 1 to Len(aCpoGDa)
		If SX3->(DbSeek(aCpoGDa[nX]))
			Aadd(aHead,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			""	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			""	,;
			""})
		Else
			Aadd(aHead,{ aCpoGDa[nX],;
			aCpoGDa[nX]	,;
			"",;
			_aTam[nX],;
			_aDec[nX],;
			""	,;
			""	,;
			_aTipo[nX]	,;
			"" 		,;
			"",;
			""	,;
			""})
		Endif
	Next nX
	// Carregue aqui a Montagem da sua aCol
	aAux := {}
	For nX := 1 to Len(aCpoGDa)
		If DbSeek(aCpoGDa[nX])
			Aadd(aAux,CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX
	Aadd(aAux,.F.)
	Aadd(aCol,aAux)

	oGetDados1 := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinhaOk,cTudoOk,cIniCpos,;
	aAlter,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oWnd,aHead,aCol)

Return Nil

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()      ³ Autor ³ Norbert Waage Junior  ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolução horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function C(nTam)

	Local nHRes	:=	oMainWnd:nClientWidth	//Resolucao horizontal do monitor
	Do Case
		Case nHRes == 640	//Resolucao 640x480
		nTam *= 0.8
		Case nHRes == 800	//Resolucao 800x600
		nTam *= 1
		OtherWise			//Resolucao 1024x768 e acima
		nTam *= 1.28
	EndCase
	If "MP8" $ oApp:cVersion
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para tema "Flat"³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Alltrim(GetTheme()) == "FLAT").Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf

Return Int(nTam)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ fExecQry   ³ Autor ³ Felipe Caiado Almeida ³ Data ³01/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por executar a query e criar o arquivo de ³±±
±±³           ³ trabalho                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fVisQry(_cSql)

	aStruct := fMontaRes(_cSql)
	fResult(aStruct)

Return()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ fResult    ³ Autor ³ Felipe Caiado Almeida ³ Data ³01/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fResult(aStruct)

	Local nG

	fGetDados1(aStruct)

	oGetDados1:aCols := {}

	TRBREL->(DbGoTop())
	While !TRBREL->(Eof())
		_aResult := {}
		For nG:=1 To Len(aStruct)
			Aadd(_aResult,TRBREL->&(aStruct[nG,1]))
		Next
		Aadd(_aResult,.F.)
		Aadd(oGetDados1:aCols,_aResult)
		TRBREL->(DbSkip())
	EndDo

	oGetDados1:oBrowse:Refresh()
	_oDlg:Refresh()

Return(aStruct)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ fMontaRes  ³ Autor ³ Felipe Caiado Almeida ³ Data ³01/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fMontaRes(_cSql)

	If Select("TRBREL") > 1
		TRBREL->(DbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSql),"TRBREL",.T.,.T.)

	aStruct  := TRBREL->(dbStruct())

Return(aStruct)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ fGeraExcel ³ Autor ³ Felipe Caiado Almeida ³ Data ³01/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fGeraExcel(aStruct)

	Local cDirDocs   := "\P10\DOCTEMP" //MsDocPath() // Alterado em 21/07/15 porque estava gerando problema com o BancoDeConhecimento
	Local cArquivo := CriaTrab(,.F.)
	Local cCrLf 	:= Chr(13) + Chr(10)
	Local cPath		:= AllTrim(GetTempPath())
	Local nG
	Local nX

	If Len(aStruct) == 0
		Alert("Favor executar a query.")
		Return()
	EndIf
	aStru := {}
	For nG:=1 To Len(aStruct)
		Aadd(aStru,{aStruct[nG,1],aStruct[nG,2],aStruct[nG,3],aStruct[nG,4]})
	Next

	ProcRegua(Len(oGetDados1:aCols)+2)

	nHandle := MsfCreate(cDirDocs+"\"+cArquivo+".CSV",0)

	If nHandle > 0

		// Grava o cabecalho do arquivo
		IncProc("Aguarde! Gerando arquivo de integração com Excel...")
		aEval(aStru, {|e, nX| fWrite(nHandle, e[1] + If(nX < Len(aStru), ";", "") ) } )
		fWrite(nHandle, cCrLf ) // Pula linha

		For nX := 1 to Len(oGetDados1:aCols)
			IncProc("Aguarde! Gerando arquivo de integração com Excel...")
			nG := 0
			For nG:=1 To Len(aStruct)
				If aStruct[nG,2] == "C"
					fWrite(nHandle, oGetDados1:aCols[nX,nG] + ";" )
				ElseIf aStruct[nG,2] == "N"
					fWrite(nHandle, Transform(oGetDados1:aCols[nX,nG],"@E 999,999,999.99") + ";" )
				ElseIf aStruct[nG,2] == "D"
					fWrite(nHandle, Transform(oGetDados1:aCols[nX,nG],"") + ";" )
				Else
					fWrite(nHandle, Iif(oGetDados1:aCols[nX,nG],"VERDADEIRO","FALSO") + ";" )
				EndIf
			Next nG

			fWrite(nHandle, cCrLf ) // Pula linha
		Next nX

		IncProc("Aguarde! Abrindo o arquivo...")

		fClose(nHandle)
		CpyS2T( cDirDocs+"\"+cArquivo+".CSV" , cPath, .T. )

		If ! ApOleClient( 'MsExcel' )
			MsgAlert("MsExcel nao instalado")
			Return
		EndIf

		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cPath+cArquivo+".CSV" ) // Abre uma planilha
		oExcelApp:SetVisible(.T.)
	Else
		MsgAlert("Falha na criação do arquivo")
	Endif

Return()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fRelat      ºAutor  ³Felipe Caiado       º Data ³  06-08-08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fRelat(_cSql, aStruct)

	Local oReport	//Objeto relatorio TReport (Release 4)

	oReport := CUSRRELDEF(_cSql, aStruct)
	oReport:PrintDialog()

Return(.T.)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CUSRRELDEF  ºAutor  ³Felipe Caiado       º Data ³  06-08-08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function CUSRRELDEF(_cSql, aStruct)

	Local nX

	Local oReport				//Objeto relatorio TReport (Release 4)
	Local oSection1 			//Objeto secao 1 do relatorio

	DEFINE REPORT oReport NAME "RELD" TITLE "Relatorio" ACTION {|oReport| CUSRRELIMP( oReport, _cSql, aStruct)} DESCRIPTION "Relatório"

	oReport:SetPortrait()

	DEFINE SECTION oSection1 OF oReport TITLE "Relatório" TABLES "SA1"      // "ORIGEM"

	For nX:=1 To Len(aStruct)
		DEFINE CELL NAME aStruct[nX,1]		OF oSection1 ALIAS "" TITLE aStruct[nX,1]
	Next

Return oReport

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CUSRRELIMP  ºAutor  ³Felipe Caiado       º Data ³  06-08-08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function CUSRRELIMP(oReport, _cSql, aStruct)

	Local oSection1 := oReport:Section(1)		//Objeto secao 1 do relatorio (Cabecalho, campos da tabela SU7)
	Local nX

	TRBREL->(DbGoTop())
	oSection1:Init()
	While !TRBREL->(Eof())
		If oReport:Cancel()
			Exit
		EndIf

		nX := 1
		For nX:=1 To Len(aStruct)
			oSection1:Cell(aStruct[nX,1]):SetValue(TRBREL->&(aStruct[nX,1]))
		Next

		oSection1:PrintLine()
		TRBREL->(DbSkip())
	EndDo

	oSection1:Finish()

Return(.T.)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CUSRRELIMP  ºAutor  ³Felipe Caiado       º Data ³  06-08-08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ValidaQuery(_cSql)

	Local _lRet := .T.

	If TcSqlExec(_cSql) <> 0
		_lRet := .F.
	EndIf

Return(_lRet)

/*
##############################################################################################################
# PROGRAMA...: PedIntraGrupo
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 04/07/2014
# DESCRICAO..: Validar se a Movimentacao esta sendo realizada entre o Grupo Biancogres
# 				 Se nao passar a EmpresaOrigem, a validacao utilizara cEmAnt (logada no momento)
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function PedIntraGrupo(_cCodCli,_cEmpOrigem)

	Local lRet := .F.
	Default _cEmpOrigem := cEmpAnt

	//Alltrim(C5_YSUBTP = 'A')  .And. cliente =
	//(Biancogres, LM, Mundi e Incesa).

	_cCodCli := Alltrim(_cCodCli)

	Do Case
		Case _cEmpOrigem == "01"	//BIANCOGRES
		If(_cCodCli == "010083") .Or. (_cCodCli == "004536")	//BIANCOGRES -> INCESA
			lRet := .T.
		EndIf
		If(_cCodCli == "010064")	//BIANCOGRES -> LM
			lRet := .T.
		EndIf
		If(_cCodCli == "014395") .Or. (_cCodCli == "018714")	//BIANCOGRES -> MUNDI
			lRet := .T.
		EndIf

		Case _cEmpOrigem == "05" //INCESA
		If(_cCodCli == "000481") .Or. (_cCodCli == "005884") .Or. (_cCodCli == "005885")	//INCESA -> BIANCOGRES
			lRet := .T.
		EndIf
		If(_cCodCli == "010064") //INCESA -> LM
			lRet := .T.
		EndIf
		If(_cCodCli == "014395") .Or.	(_cCodCli == "018714") //INCESA -> MUNDI
			lRet := .T.
		EndIf

		Case _cEmpOrigem == "07"	//LM
		If(_cCodCli == "000481") .Or. (_cCodCli == "005884") .Or. (_cCodCli == "005885")	//LM -> BIANCOGRES
			lRet := .T.
		EndIf
		If(_cCodCli == "010083") .Or. (_cCodCli == "004536") //LM -> INCESA
			lRet := .T.
		EndIf
		If(_cCodCli == "014395") .Or.	(_cCodCli == "018714") //LM -> MUNDI
			lRet := .T.
		EndIf

		Case _cEmpOrigem == "13"	//MUNDI
		If(_cCodCli == "000481") .Or. (_cCodCli == "005884") .Or. (_cCodCli == "005885")	//MUNDI -> BIANCOGRES
			lRet := .T.
		EndIf
		If(_cCodCli == "010083") .Or. (_cCodCli == "004536") //MUNDI -> INCESA
			lRet := .T.
		EndIf
		If(_cCodCli == "010064") //MUNDI -> LM
			lRet := .T.
		EndIf
	EndCase

Return lRet

/*
|------------------------------------------------------------|
| Função:	| BIAF003										 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas	 |
| Data:		| 29/09/14										 |
|------------------------------------------------------------|
| Desc.:	| Função para validar se a operação de venda esta|
| 			| sendo feita entre a empresa JK e outra empresa |
| 			| do grupo: 									 |
| 			|                                                |
| 			| Codigo de Clientes							 |
| 			| 000481 - Bianco 								 |
| 			| 004536 - Incesa 								 |
| 			| 010064 - LM 									 |
| 			| 018410 - ST Gestao 							 |
| 			| 014395 - Mundi 								 |
| 			| 008615 - Vitcer 								 |
|------------------------------------------------------------|
| OS:		|	1683-14 - Usuário: Fabiana Aparecida Corona  |
|------------------------------------------------------------|
*/

User Function BIAF003(cClvl, cItemCT, cCodCli)
	Local lRet := .F.

	cCodCli := Alltrim(cCodCli)

	If Empty(cClvl) .And. Empty(cItemCT)

		If cEmpAnt == "06"

			If cCodCli == "000481" .Or. cCodCli = "004536" .Or. cCodCli == "010064" .Or. cCodCli == "018410" .Or. cCodCli == "014395" .Or. cCodCli == "008615"
				lRet := .T.
			EndIf

		EndIf

	EndIf

Return(lRet)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BiaVldCtrt ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Em virtude da implantação do módulo EIC foi necessário     ¦¦¦
¦¦¦            efetuar tratamento para o gatilho D1_CLVL - 002            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BiaVldCtrt()

	Local kgRtOk := .T.

	If Alltrim(FunName()) $ "MATA910/MATA116/EICDI154/MATA140"
		kgRtOk := .F.
	EndIf

Return( kgRtOk )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BimpOrct  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 04.12.14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Importa orçamento unitário variável                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BimpOrct()

	Processa({|| R1ptDetail()})

Return

Static Function R1ptDetail()

	Local kw
	dtRef := dDataBase

	xcTab := "\bkp_Marcos\ctaorct"
	dbUseArea(.T.,,xcTab+".dbf","REF1",.F.)
	dbCreateIndex(xcTab+".cdx","CTA",{||CTA })
	dbSelectArea("REF1")
	dbGoTop()

	For kw := 1 to 12

		heTab := "\bkp_Marcos\orct"+cEmpAnt+StrZero(kw,2)
		dbUseArea(.T.,,heTab+".dbf","O1RCT",.F.)
		dbCreateIndex(heTab+".cdx", "PROD",{|| PROD })
		dbSelectArea("O1RCT")
		dbGoTop()
		ProcRegua(RecCount())
		t_Contad := 0
		While !Eof()

			t_Contad ++
			IncProc("Processando.... Mês: " + Alltrim(Str(kw)) + " " + Alltrim(Str(t_Contad)))

			dbSelectArea("REF1")
			dbGoTop()
			While !Eof()

				If &("O1RCT->"+REF1->CTA) <> 0

					dbSelectArea("Z50")
					dbSetOrder(1)
					If !dbSeek(xFilial("Z50") + dtos(dtRef) + O1RCT->PROD + REF1->CONTA)
						RecLock("Z50",.T.)
						Z50->Z50_FILIAL  := xFilial("Z50")
						Z50->Z50_DATARF  := dtRef
						Z50->Z50_COD     := O1RCT->PROD
						Z50->Z50_CONTA   := REF1->CONTA
						Z50->Z50_CTOTAL  := &("O1RCT->"+REF1->CTA)
					Else
						RecLock("Z50",.F.)
					EndIf
					&("Z50_M"+StrZero(kw,2)) := &("O1RCT->"+REF1->CTA)
					MsUnLock()

				EndIf

				dbSelectArea("REF1")
				dbSkip()

			End

			dbSelectArea("O1RCT")
			dbSkip()
		End
		O1RCT->(dbCloseArea())
		Ferase(heTab+".cdx")

	Next kw

	REF1->(dbCloseArea())
	Ferase(xcTab+".cdx")

	UZ005 := " UPDATE "+RetSqlName("Z50")+" SET Z50_ITCUS = CT1_YITCUS
	UZ005 += "   FROM "+RetSqlName("Z50")+" Z50
	UZ005 += "  INNER JOIN "+RetSqlName("CT1")+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"'
	UZ005 += "                       AND CT1_CONTA = Z50_CONTA
	UZ005 += "                       AND CT1.D_E_L_E_T_ = ' '
	UZ005 += "  WHERE Z50_DATARF = '"+dtos(dtRef)+"'
	UZ005 += "    AND Z50.D_E_L_E_T_ = ' '
	TCSQLExec(UZ005)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BGthD1TES ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 16.01.15 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Gatilho para preenchimento do D1_LOCAL em empresa 14       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BGthD1TES()

	Local d1Local := Gdfieldget('D1_LOCAL',n)

	If cTipo == "B"
		d1Local   := "07"
	Else
		spTes := ""
		If Alltrim(__readvar) == "M->D1_TES"
			spTes := M->D1_TES
		Else
			spTes := Gdfieldget('D1_TES',n)
		EndIf
		If cEmpAnt == "14" .and. spTes == "004" .and. cA100For $ "000534/007602"  // Tratamento implementado em 15/05/14 por Marcos Alberto Soprani para atender ao emquadramento de almoxarifados da Vitcer
			d1Local   := "01"
		EndIf
	EndIf

Return ( d1Local )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BGArredDc ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 18.09.15 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Gatilho para arredondamento das casas decimentos de PA     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BGArredDc()

	Local xyzQtd   := 0
	Local xyzCasas := TamSX3("D3_QUANT")[02]

	//                                                             Mod.I, Prod-Mod.I
	********************************************************************************
	If     Alltrim(FunName()) $ "MATA240/MATA250"

		If SB1->B1_TIPO == "PA"
			xyzCasas := 2
		EndIf

		If Alltrim(__readvar) == "M->D3_QUANT"
			xyzQtd        := Round(M->D3_QUANT  ,xyzCasas)
			M->D3_QUANT   := Round(M->D3_QUANT  ,xyzCasas)
			M->D3_QTSEGUM := Round(M->D3_QTSEGUM,xyzCasas)
		EndIf
		If Alltrim(__readvar) == "M->D3_QTSEGUM"
			xyzQtd        := Round(M->D3_QTSEGUM,xyzCasas)
			M->D3_QUANT   := Round(M->D3_QUANT  ,xyzCasas)
			M->D3_QTSEGUM := Round(M->D3_QTSEGUM,xyzCasas)
		EndIf

		//                                   Mod.II, Tansf.II, Desmontagem (aHeader)
		****************************************************************************
	ElseIf Alltrim(FunName()) $ "MATA241/MATA261/MATA242"

		If SB1->B1_TIPO == "PA"
			xyzCasas := 2
		EndIf

		If Alltrim(__readvar) == "M->D3_QUANT"
			xyzQtd        := Round(GdFieldGet("D3_QUANT"  , n),xyzCasas)
			Gdfieldput("D3_QUANT"  , Round(GdFieldGet("D3_QUANT"  , n),xyzCasas), n)
			Gdfieldput("D3_QTSEGUM", Round(GdFieldGet("D3_QTSEGUM", n),xyzCasas), n)
		EndIf
		If Alltrim(__readvar) == "M->D3_QTSEGUM"
			xyzQtd        := Round(GdFieldGet("D3_QTSEGUM", n),xyzCasas)
			Gdfieldput("D3_QUANT"  , Round(GdFieldGet("D3_QUANT"  , n),xyzCasas), n)
			Gdfieldput("D3_QTSEGUM", Round(GdFieldGet("D3_QTSEGUM", n),xyzCasas), n)
		EndIf

		//                                                       Desmontagem (Cabec)
		****************************************************************************
	ElseIf Alltrim(FunName()) $ "MATA242"

		// Será necessário contruir via pontos de entrada: MTA242Q, MTA242S

		//                                                            Pre-Requisição
		****************************************************************************
	ElseIf Alltrim(FunName()) $ "BIA902"

		//   Os teste identificaram que mesmo executando o ExecAuto, a rotina não
		// dispara os gatilhos do SD3

		//                                                                Apont.Auto
		****************************************************************************
	ElseIf Alltrim(FunName()) $ "BIA570" .Or. IsInCallsTack("U_BIAFG120")

		//   Os teste identificaram que mesmo executando o ExecAuto, a rotina não
		// dispara os gatilhos do SD3

		//                                                                  Transf.I
		****************************************************************************
	ElseIf Alltrim(FunName()) $ "MATA260"

		// Será necessário contruir via pontos de entrada: MT260UM. Este ponto não
		// é dos melhores, porém como as variáveis nQuant260 e nQuant260D são TIPO
		// PRIVATE, poderia-se efetuar o arredondamento retornando sempre .T.

	EndIf

Return ( xyzQtd )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BiaTablUsad ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 16.05.16 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Verifica se uma tabela está em uso ou não facilitando a ma-¦¦¦
¦¦¦          ¦ nutenção a quente da mesma                                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BiaTablUsad(kfyTabl)

	/*
	dbSelectArea(kfyTabl)
	kfyExclvo := DBInfo(20) // .T. Bloquado, .F. Liberado, nome da Variável DBI_ISFLock
	If kfyExclvo
	Aviso("Acesso Exclusivo", "O arquivo " + kfyTabl + " NÃO pode ser aberto de forma exclusiva!!!", {'Ok'})
	Else
	Aviso("Acesso Exclusivo", "O arquivo " + kfyTabl + " PODE ser aberto de forma exclusiva!!!", {'Ok'})
	EndIf
	*/

	Local zpaArea         := GetArea()
	Local zplLocked       := .F.
	Local zpcArquivo      := kfyTabl
	Local zplShowHelp     := .F.
	Local zplQuitProg     := .F.
	Local zpxProsseg      := .T.



	// Quando .T. conseguiu lockar a tabela indicando que não tem ninguem usando.
	// Quando .F. a tabela está em uso por algum usuário do sistema, impedindo qualquer processamento estrutural com a tabela.
	zplLocked := Ma280Flock( zpcArquivo , zplShowHelp , zplQuitProg )
	If !zplLocked
		zpxProsseg := .F.
		MsgSTOP("Impossível prosseguir porque a tabela " + zpcArquivo + " está em uso!!!")
	Else
		&(zpcArquivo)->(dbCloseArea())
		MsgSTOP("Pode prosseguir com a manutenção porque a tabela " + zpcArquivo + " NÃO está em uso!!!")
	EndIf

	RestArea( zpaArea )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BiaGrvCtb1  ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 03.08.16 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Grava retroativamente o CT2_YHIST                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BiaGrvCtb1()

	Processa({|| DetProc01()})

Return

Static Function DetProc01()

	Local aRet   := {ctod("  /  /  "), ctod("  /  /  ")}
	Local aPergs := {}
	aAdd( aPergs ,{1, "De Data" , ctod("  /  /  "), , ".T.", ,".T.", 8, .F.})
	aAdd( aPergs ,{1, "Até Data", ctod("  /  /  "), , ".T.", ,".T.", 8, .F.})

	If !ParamBox(aPergs, "Parâmetros", aRet, , , , , , , , .F., .F.)
		Return
	EndIf

	MV_PAR01 := aRet[1]
	MV_PAR02 := aRet[2]

	dbSelectArea("CT2")
	dbSetOrder(1)
	dbSeek(xFilial("CT2") + dtos(MV_PAR01))
	ProcRegua(RecCount())
	While !Eof() .and. dtos(CT2->CT2_DATA) <= dtos(MV_PAR02)

		ParamIxb := {,}
		ParamIxb[1] := 3 
		ParamIxb[2] := "BiaGrvCtb1" 

		IncProc("Proc.: " + dtoc(CT2->CT2_DATA)+'-'+CT2->CT2_LOTE+'-'+CT2->CT2_SBLOTE+'-'+CT2->CT2_DOC+'-'+CT2->CT2_LINHA)

		If Empty(CT2->CT2_YHIST)

			U_CTBGRV()

		EndIf

		dbSelectArea("CT2")
		dbSkip()
	End

	MsgINFO("Fim do processamento... " + dtoc(MV_PAR01) + " " + dtoc(MV_PAR02))

Return

// teste Em 29/08/16....

User Function BIA1Calend()

	Local aTabPadrao 	:= {}
	Local aTabCalend	:= {}
	Local dPerIni       := ctod("11/08/16")
	Local dPerFim       := ctod("10/10/16")
	Local kd

	dbSelectArea("SRA")
	dbSeek(xFilial("SRA")+"000029")

	If !CriaCalend(dPerIni, dPerFim, SRA->RA_TNOTRAB, SRA->RA_SEQTURN, @aTabPadrao, @aTabCalend, SRA->RA_FILIAL, SRA->RA_MAT, SRA->RA_CC )
		Oidf := 0
	EndIf

	xTablOrh := "Escala"
	xPlanOrh := "Planilha 1"
	oExcel := FWMSEXCEL():New()
	oExcel:AddworkSheet(xTablOrh)
	oExcel:AddTable (xTablOrh, xPlanOrh)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 1"                                           , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 2"                                           , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 3"                                           , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 4"                                           , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 5"                                           , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 6"                                           , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 7"                                           , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 8"                                           , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 9"                                           , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 10"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 11"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 12"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 13"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 14"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 15"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 16"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 17a"                                         , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 17b"                                         , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 18"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 19"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 20"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 21"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 22"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 23"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 24"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 25"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 26"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 27"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 28"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 29"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 30"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 31"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 32"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 33"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 34"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 35"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 36"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 37"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 38"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 39"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 40"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 41"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 42"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 43"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 44"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 45"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 46"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 47"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 48"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 49"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 50"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 51"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 52"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 53"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 54"                                          , 1, 1)
	oExcel:AddColumn(xTablOrh, xPlanOrh, "Parametro 55"                                          , 1, 1)

	For kd := 1 to Len(aTabCalend)

		oExcel:AddRow(xTablOrh, xPlanOrh, { ATABCALEND[kd][1]    ,;
		ATABCALEND[kd][2]                                        ,;
		ATABCALEND[kd][3]                                        ,;
		ATABCALEND[kd][4]                                        ,;
		ATABCALEND[kd][5]                                        ,;
		ATABCALEND[kd][6]                                        ,;
		ATABCALEND[kd][7]                                        ,;
		ATABCALEND[kd][8]                                        ,;
		ATABCALEND[kd][9]                                        ,;
		ATABCALEND[kd][10]                                       ,;
		ATABCALEND[kd][11]                                       ,;
		ATABCALEND[kd][12]                                       ,;
		ATABCALEND[kd][13]                                       ,;
		ATABCALEND[kd][14]                                       ,;
		ATABCALEND[kd][15]                                       ,;
		ATABCALEND[kd][16]                                       ,;
		ATABCALEND[kd][17][1]                                    ,;
		ATABCALEND[kd][17][2]                                    ,;
		ATABCALEND[kd][18]                                       ,;
		ATABCALEND[kd][19]                                       ,;
		ATABCALEND[kd][20]                                       ,;
		ATABCALEND[kd][21]                                       ,;
		ATABCALEND[kd][22]                                       ,;
		ATABCALEND[kd][23]                                       ,;
		ATABCALEND[kd][24]                                       ,;
		ATABCALEND[kd][25]                                       ,;
		ATABCALEND[kd][26]                                       ,;
		ATABCALEND[kd][27]                                       ,;
		ATABCALEND[kd][28]                                       ,;
		ATABCALEND[kd][29]                                       ,;
		ATABCALEND[kd][30]                                       ,;
		ATABCALEND[kd][31]                                       ,;
		ATABCALEND[kd][32]                                       ,;
		ATABCALEND[kd][33]                                       ,;
		ATABCALEND[kd][34]                                       ,;
		ATABCALEND[kd][35]                                       ,;
		ATABCALEND[kd][36]                                       ,;
		ATABCALEND[kd][37]                                       ,;
		ATABCALEND[kd][38]                                       ,;
		ATABCALEND[kd][39]                                       ,;
		ATABCALEND[kd][40]                                       ,;
		ATABCALEND[kd][41]                                       ,;
		ATABCALEND[kd][42]                                       ,;
		ATABCALEND[kd][43]                                       ,;
		ATABCALEND[kd][44]                                       ,;
		ATABCALEND[kd][45]                                       ,;
		ATABCALEND[kd][46]                                       ,;
		ATABCALEND[kd][47]                                       ,;
		ATABCALEND[kd][48]                                       ,;
		ATABCALEND[kd][49]                                       ,;
		ATABCALEND[kd][50]                                       ,;
		ATABCALEND[kd][51]                                       ,;
		ATABCALEND[kd][52]                                       ,;
		ATABCALEND[kd][53]                                       ,;
		ATABCALEND[kd][54]                                       ,;
		ATABCALEND[kd][55]                                       })

	Next kd

	zdNPath := "c:\temp\"
	If !lIsDir( zdNPath )
		MakeDir( zdNPath )
	EndIf

	If File(zdNPath+"TESTE"+".xml")
		If fErase(zdNPath+"TESTE"+".xml") == -1
			Aviso('Arquivo em uso','Favor fechar o arquivo: ' + zdNPath+"TESTE"+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile(zdNPath+"TESTE"+".xml")

Return

//==================================================
//
//==================================================
User Function BiaUpdBas7(lWizard)

	Local cLog		:= ""

	PRIVATE cArqEmp := "SigaMat.Emp"
	PRIVATE __cInterNet := Nil

	PRIVATE cMessage
	PRIVATE aArqUpd	 := {}
	PRIVATE aREOPEN	 := {}
	PRIVATE oMainWnd 

	DEFAULT lWizard  := .F. 

	Set Dele On

	lEmpenho	:= .F.
	lAtuMnu		:= .F.

	If lWizard
		cLog := Alert("123")
		Return cLog
	Else

		lHistorico 	:= MsgYesNo("Deseja efetuar a atualizacao do Dicionário? Esta rotina deve ser utilizada em modo exclusivo ! Faca um backup dos dicionários e da Base de Dados antes da atualização para eventuais falhas de atualização !", "Atenção")

		DEFINE WINDOW oMainWnd FROM 0,0 TO 01,30 TITLE "Atualização do Dicionário"

		ACTIVATE WINDOW oMainWnd ;
		ON INIT If(lHistorico,(Processa({|lEnd| U_BiaCyTabl() }, "Processando", "Aguarde , processando preparação dos arquivos", .F.) , Final("Atualização efetuada!")),oMainWnd:End())

	Endif

Return

//==================================================
// Criada em 23/11/16 e Executada a partir do ponto
// de entrada MBRWBTN
//==================================================
User Function BIAATUSBZ()

	Public xBZAlmUsr := .F. // Almoxarifado
	Public xBZFisUsr := .F. // Fiscal
	Public xBZCusUsr := .F. // Custos
	Public xBZIndUsr := .F. // Industrial
	Public xBZEstUsr := .F. // Estoque/Suprimentos

	If U_VALOPER("033") // Almoxarifado
		xBZAlmUsr := .T.
	EndIf
	If U_VALOPER("034") // Fiscal
		xBZFisUsr := .T.
	EndIf
	If U_VALOPER("035") // Custos
		xBZCusUsr := .T.
	EndIf
	If U_VALOPER("036") // Industrial
		xBZIndUsr := .T.
	EndIf
	If U_VALOPER("037") // Estoque/Suprimentos
		xBZEstUsr := .T.
	EndIf

Return

/*/{Protheus.doc} bTrocaQuente
@author Marcos Alberto Soprani
@since 05/04/17
@version 1.0
@description Rotina para efetuar Troca a Quente sem necessidade de Logar no sistema
@obs OS: 0137-17
@type function
/*/
User Function bTrocaQuente(lWizard)

	Local cLog		:= ""

	PRIVATE cArqEmp := "SigaMat.Emp"
	PRIVATE __cInterNet := Nil

	PRIVATE cMessage
	PRIVATE aArqUpd	 := {}
	PRIVATE aREOPEN	 := {}
	PRIVATE oMainWnd 

	DEFAULT lWizard  := .F. 

	Set Dele On

	lEmpenho	:= .F.
	lAtuMnu		:= .F.

	If lWizard
		cLog := Alert("123")
		Return cLog
	Else

		lHistorico 	:= MsgYesNo("Deseja atualizar o RPO de produção?", "Atenção")

		DEFINE WINDOW oMainWnd FROM 0,0 TO 01,50 TITLE "Atualização do Repositório de Objetos do Protheus (RPO)"

		ACTIVATE WINDOW oMainWnd ;
		ON INIT If(lHistorico,(Processa({|lEnd| U_AtualForm() }, "Processando", "Aguarde...",.F.) , Final("Atualização efetuada!")),oMainWnd:End())

	Endif

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ gBia791SRZ  ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 27/05/14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function mBiaChkUsd(mTablUsd)

	dbSelectArea(mTablUsd)
	frValid := MA280FLock(mTablUsd)
	If frValid
		MsgINFO("Tabela: " + mTablUsd + " não está em uso... Pode proceder com a atualização do sistema!!!")
	Endif

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Empresa   := Biancogres Ceramica S.A.
Data      := 20/06/17
Uso       := Movimentação de Estoque
Aplicação := Criação se documento para SD3
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function bUltDocSD3()

	Local htfAreaX := GetArea()
	Local htfDocum := Space(9)

	XT002 := " SELECT ISNULL(MAX(D3_DOC),'H00000000') ULTDOCD3 "
	XT002 += "   FROM " + RetSqlName("SD3") + " (NOLOCK) "
	XT002 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	XT002 += "    AND LEN(RTRIM(D3_DOC)) = 9 "
	XT002 += "    AND D3_DOC LIKE 'H%' "
	XT002 += "    AND D3_ESTORNO <> 'S' "
	XT002 += "    AND D_E_L_E_T_ = ' ' "
	XTIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XT002),'XT02',.T.,.T.)
	dbSelectArea("XT02")
	dbGoTop()
	htfDocum := Soma1(XT02->ULTDOCD3)
	XT02->(dbCloseArea())
	Ferase(XTIndex+GetDBExtension())
	Ferase(XTIndex+OrdBagExt())

	dbSelectArea("SD3")
	nSavReg		:= RecNo()
	dbSetOrder(2)
	dbSeek(xFilial("SD3") + htfDocum)
	cMay := "SD3" + Alltrim(xFilial("SD3")) + htfDocum
	While SD3->D3_FILIAL + SD3->D3_DOC == xFilial("SD3") + htfDocum .Or. !MayIUseCode(cMay)
		If SD3->D3_ESTORNO <> "S"
			htfDocum := Soma1(htfDocum)
			cMay := "SD3" + Alltrim(xFilial("SD3")) + htfDocum
		EndIf
		dbSkip()
	End
	dbSetOrder(1)
	dbGoTo(nSavReg)

	RestArea(htfAreaX)

Return ( htfDocum )

User Function xCstPromot()

	sadfsdfs := 0
	aLog     := {}
	aAddVerb := {}
	lGeraLog := .F.

	abacaxi := CalCustoFun("01", "001954",.T.,.T.,ctod("01/01/17"),ctod("31/01/17"),/*cCusto*/,	/*aPIS*/,/*aINSS*/,/*aAcidente*/,/*aLabore*/,/*aAutonomo*/,/*aProvisao*/,/*aVerbas*/,/*aFGTS*/,/*aContSoc*/,.F.,,,)

	asdasd := 0

Return

User Function BShellExec1()

	Local klRetExe
	ConOut("HORA: " + TIME() + " - BShellExec1: Inicio do processamento...")

	klRetExe := shellExecute("Open", "C:\Windows\System32\cmd.exe", " /k dir", "C:\", 1 )

	ConOut("HORA: " + TIME() + " - BShellExec1: Resultado da execucao: " + Alltrim(Str(klRetExe)) )
	ConOut("HORA: " + TIME() + " - BShellExec1: Fim do processamento...")

Return

User Function JobBShellExec1()

	STARTJOB("U_BShellExec1()",GetEnvServer(),.F.,cEmpAnt,cFilAnt)

Return

// --------------------------------------------
// Exemplo de conexão via Socket, neste caso
// será conectado um socket em Delphi via AdvPL
// --------------------------------------------

User Function BiaSocket47()

	Local oObj := tSocketClient():New()
	Local nX := 0

	//u_tSocketAuth()

	//Return

	// -------------------------------
	// Tenta conectar 3 vezes
	// -------------------------------
	For nX := 1 to 15         

		MV_PAR01 := Space(10)
		If !ValidPerg()
			Return
		EndIf

		nPort := Val(Alltrim(MV_PAR01))
		nIp := '192.168.51.110'
		nResp := oObj:Connect( nPort, nIp, MSECONDS_WAIT )
		// -------------------------------
		// Se conectou abandona o FOR
		// -------------------------------
		if(nResp == 0 )
			exit
		else
			Alert("--> Tentativa de Conexão: " + StrZero(nX,3))
			Sleep(2000) 
		endif
	Next           

	// --------------------------------------
	// Verifica se a conexão foi bem sucedida
	// --------------------------------------
	if( !oObj:IsConnected() ) 
		Alert("--> Falha na conexão")
		return 
	else
		Alert("--> Conexão OK")
	endif

	/*
	// -------------------------------
	// Teste de envio para o socket
	// -------------------------------
	cSend := "Dados enviados pelo AdvPL..."
	nResp := oObj:Send( cSend )
	if( nResp != len( cSend ) )               
	Alert( "--> Erro! Dado não transmitido" )
	else
	Alert( "--> Dado Enviado - Retorno: " +StrZero(nResp,5) )
	endif
	*/

	// -------------------------------
	// Teste de recebimento do socket
	// -------------------------------
	cBuffer := ""
	nResp = oObj:Receive( @cBuffer, MSECONDS_WAIT ) 
	if( nResp >= 0 )
		Alert( "--> Dados Recebidos " + StrZero(nResp,5) )
		Alert( "--> ["+cBuffer+"]" )
	else
		Alert( "--> Não recebi dados" )
	endif

	// -------------------------------
	// Fecha conexão
	// -------------------------------
	oObj:CloseConnection()
	Alert( "--> Conexão fechada" )

Return

Static Function ValidPerg()

	local cLoad	    := "BiaSocket47" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 := Space(10)

	aAdd( aPergs ,{1,"Porta"     		  	,MV_PAR01 ,""  ,"",''  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Socket",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 

	EndIf

Return lRet

/*/
Funcao: tSocketAuth
Autor:  Marinaldo de Jesus
Data:   03/03/2012
Uso:    Exemplo de Uso da Classe tSocketClient
/*/
User Function tSocketAuth()

	Local nVarNameL            := SetVarNameLen( 20 )
	Local atSocketC            := {}
	Local lGetError            := .F.

	Local cGetError
	Local ctSocketSend
	Local ctSocketReceive

	Local ntSocketReset
	Local ntSocketConnected
	Local ntSocketSend
	Local ntSocketReceive

	//Instanciamos um objeto do tipo Socket Client
	Local otSocketC    := tSocketClient():New()
	//Obtemos os Metodos da Classe
	atSocketC    := ClassMethArray( otSocketC )
	lGetError    := ( aScan( atSocketC , { |aMeth| aMeth[1] == "GETERROR" } ) > 0 )

	MV_PAR01 := Space(10)
	If !ValidPerg()
		Return
	EndIf
	nPort := Val(Alltrim(MV_PAR01))

	BEGIN SEQUENCE

		//Tentamos efetuar a Conexao a teste.com.br aguardando n milisegundos
		ntSocketConnected    := otSocketC:Connect( nPort , '192.168.51.110' , MSECONDS_WAIT )
		//Verificamos se a conexao foi efetuada com sucesso
		IF !( otSocketC:IsConnected() ) //ntSocketConnected == 0 OK
			IF ( lGetError )
				//cGetError := otSocketC:GetError()
				DEFAULT cGetError := "otSocketC:GetError()"
				ConOut( cGetError ) 
			EndIF    
			ConOut( "" , "tSocketClient" , "" , "Sem Resposta a requisicao" , "" )
			BREAK
		EndIF

		ctSocketSend := "GET"
		ctSocketSend += " "
		ctSocketSend += "http://user:password@teste.com.br"
		ctSocketSend += __cCRLF
		ctSocketSend += "HTTP/1.0"
		ctSocketSend += __cCRLF
		ctSocketSend += "From:"
		ctSocketSend += " "
		ctSocketSend += "tsocketclient@sample.com"
		ctSocketSend += __cCRLF
		ctSocketSend += "User-Agent: tSocketClient/1.0"
		ctSocketSend += __cCRLF
		ctSocketSend += __cCRLF

		//Enviamos uma Mensagem
		//ntSocketSend := otSocketC:Send( ctSocketSend )
		//Se a mensagem foi totalmente enviada
		//IF ( ntSocketSend == Len( ctSocketSend ) )
		//Tentamos Obter a Resposta aguardando por n milisegundos
		ntSocketReceive := otSocketC:Receive( @ctSocketReceive , MSECONDS_WAIT )
		//Se Obtive alguma Resposta
		IF ( ntSocketReceive > 0 )
			//Direcionamo-a para o Console do Server
			ConOut( "" , ctSocketReceive , "" )
		Else
			IF ( lGetError )
				//cGetError := otSocketC:GetError()
				DEFAULT cGetError := "otSocketC:GetError()"
				ConOut( cGetError ) 
			EndIF    
			ConOut( "" , "tSocketClient" , "" , "Sem Resposta a requisicao" , "" )
		EndIF
		//Else
		//	IF ( lGetError )
		//		//cGetError := otSocketC:GetError()
		//		DEFAULT cGetError := "otSocketC:GetError()"
		//		ConOut( cGetError ) 
		//	EndIF    
		//	ConOut( "" , "tSocketClient" , "" , "Problemas no Enviamos da Mensagem" , "" )
		//EndIF
		//Verificamos se ainda esta Conectado
		IF !( otSocketC:IsConnected() )
			//Tentamos Nova Conexao
			ntSocketReset         := otSocketC:ReSet() //ntSocketReset == 0 OK
			ntSocketConnected    := otSocketC:Connect( nPort , '192.168.51.110' , MSECONDS_WAIT )        
		EndIF
		//Se permanecemos conectado ou reconectou
		IF !( otSocketC:IsConnected() ) //ntSocketConnected == 0 OK
			IF ( lGetError )
				//cGetError := otSocketC:GetError()
				DEFAULT cGetError := "otSocketC:GetError()"
				ConOut( cGetError ) 
			EndIF    
			ConOut( "" , "tSocketClient" , "" , "Sem Resposta a requisicao" , "" )
			BREAK
		EndIF

	END SEQUENCE

	//Encerramos a Conexao
	otSocketC:CloseConnection()
	otSocketC    := NIL

	SetVarNameLen( nVarNameL )

Return( ctSocketReceive )

/*/
Funcao: tBiaUpdAplic
Autor:  Marcos Alberto Soprani
Data:   14/05/18
Uso:    Acertando CT2_YAPLIC, apenas para abril de 2018 num primeiro momento.
/*/
User Function tBiaUpdAplic()

	Processa({|| DetXProc01()})

Return

Static Function DetXProc01()

	xdbl := 0
	AC004 := " WITH CONTALX AS (SELECT R_E_C_N_O_ REGCT2,
	AC004 += "                         CT2_LP,
	AC004 += "                         CT2_KEY
	AC004 += "                    FROM CT2010 CT2 WITH (NOLOCK)
	AC004 += "                   WHERE CT2_FILIAL BETWEEN '  ' AND 'ZZ'
	AC004 += "                     AND CT2_DATA BETWEEN '20180401' AND '20180430'
	AC004 += "                     AND CT2_DC <> '4'
	AC004 += "                     AND CT2_KEY <> ''
	AC004 += "                     AND ( SUBSTRING(CT2_DEBITO,1,3) IN('613', '614', '616') OR SUBSTRING(CT2_CREDIT,1,3) IN('613', '614', '616') )
	AC004 += "                     AND CT2.D_E_L_E_T_ = ' ')
	AC004 += " SELECT *
	AC004 += "   FROM CONTALX
	AC004 += "  WHERE 1 = 2
	ACIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,AC004),'AC04',.T.,.T.)
	dbSelectArea("AC04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		xdbl ++
		IncProc("Reg: " + StrZero(xdbl))

		CTL->( dbSetOrder(1) )
		If CTL->( dbSeek( xFilial("CTL") + AC04->CT2_LP ) )

			xtrAlias := CTL->CTL_ALIAS
			xtrOrder := Val(Alltrim(CTL->CTL_ORDER))
			xtrKey   := CTL->CTL_KEY

			&(xtrAlias)->( dbSetOrder(xtrOrder) )
			If &(xtrAlias)->( dbSeek( Alltrim(AC04->CT2_KEY) ) )

				If xtrAlias == "SD1"

					dbSelectArea("CT2")
					dbGoTo(AC04->REGCT2)
					RecLock("CT2",.F.)
					CT2->CT2_YAPLIC    := SD1->D1_YAPLIC
					MsUnLock()

				EndIf

				If xtrAlias == "SD3"
					dbSelectArea("CT2")
					dbGoTo(AC04->REGCT2)
					RecLock("CT2",.F.)
					CT2->CT2_YAPLIC    := SD3->D3_YAPLIC
					MsUnLock()
				EndIf


			EndIf

		EndIf

		dbSelectArea("AC04")
		dbSkip()
	End

	AC04->(dbCloseArea())
	Ferase(ACIndex+GetDBExtension())
	Ferase(ACIndex+OrdBagExt())

Return

User Function BiaSalAtu(dLocEst, aLocEst, dProdut, aProdut)

	lJob := .T.

	//Atualiza as perguntas (baixar fonte em https://terminaldeinformacao.com/2017/02/28/funcao-altera-conteudo-de-perguntas-mv_par-em-advpl/ )
	cPerg := "MTA300"
	u_zAtuPerg(cPerg, "MV_PAR01", dLocEst)     // Armazém De
	u_zAtuPerg(cPerg, "MV_PAR02", aLocEst)     // Armazém Até
	u_zAtuPerg(cPerg, "MV_PAR03", dProdut)     // Produto De
	u_zAtuPerg(cPerg, "MV_PAR04", aProdut)     // Produto Até
	Pergunte(cPerg, .F.)

	//Executa a operação automática
	lMsErroAuto := .F.
	MSExecAuto({|x| MATA300(x)}, lJob)

	//Se houve erro, salva um arquivo dentro da protheus data
	If lMsErroAuto

		cDiretorio := "\p10\"
		cArquivo   := "log_mata300_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-')

		MostraErro(cDiretorio, cArquivo)

	EndIf

Return
