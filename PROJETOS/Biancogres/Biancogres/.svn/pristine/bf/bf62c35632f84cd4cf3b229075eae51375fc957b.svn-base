#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
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

User Function BIA246()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA246
Empresa   := Biancogres Ceramica S.A.
Data      := 11/10/12
Uso       := Faturamento
Aplicação := Impressão da Carta de Correção Eletrônica - CCE
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local zpArea    := GetArea()
Local cError    := ""
Local cWarning  := ""
Local cvRetOk   := .T.

Local kLp
Local aArea           := GetArea()
Local lExistNfe       := .F.
Local lAdjustToLegacy := .T.  // Usado para montar o Objeto Printer
Local lDisableSetup   := .T.  // Usado para montar o Objeto Printer

Private nHPage
Private nVPage
Private nLine
Private nBaseTxt
Private nBaseCol

Private oxCCE
Private oSetup
Private nConsNeg   := 0.40 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
Private nConsTex   := 0.38 // Constante para concertar o cálculo retornado pelo GetTextWidth.

Private _oXML   := NIL

fPerg := "BIA246"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

nCol := oMainWnd:nClientWidth
nLin := oMainWnd:nClientHeight

oFont1     := TFont():New( "Arial Black",0,-19,,.T.,0,,700,.F.,.F.,,,,,, )

If MV_PAR03 == 1
	KJ001 := " SELECT (SELECT F2_TIPO
	KJ001 += "           FROM " + RetSqlName("SF2")
	KJ001 += "          WHERE F2_FILIAL = '"+xFilial("SF2")+"'
	KJ001 += "            AND F2_DOC = '"+MV_PAR01+"'
	KJ001 += "            AND F2_SERIE = '"+MV_PAR02+"'
	KJ001 += "            AND F2_CHVNFE = SPED.NFE_CHV "
	KJ001 += "            AND D_E_L_E_T_ = ' ') F2_TIPO,
	KJ001 += "        (SELECT F2_CLIENTE+F2_LOJA
	KJ001 += "           FROM " + RetSqlName("SF2")
	KJ001 += "          WHERE F2_FILIAL = '"+xFilial("SF2")+"'
	KJ001 += "            AND F2_DOC = '"+MV_PAR01+"'
	KJ001 += "            AND F2_SERIE = '"+MV_PAR02+"'
	KJ001 += "            AND F2_CHVNFE = SPED.NFE_CHV "
	KJ001 += "            AND D_E_L_E_T_ = ' ') CLIFOR,
	KJ001 += "        NFE_CHV,
	KJ001 += "        PROTOCOLO,
	KJ001 += "        SUBSTRING(CONVERT(VARCHAR(30) , DHREGEVEN, 127), 1, 19) DHREGEVEN,
	KJ001 += "        CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),XML_SIG)) AS XXML,
	KJ001 += "        CORGAO,
	KJ001 += "        TPEVENTO,
	KJ001 += "        SEQEVENTO,
	KJ001 += "        VEREVENTO,
	KJ001 += "        CMOTEVEN
	KJ001 += "   FROM SPED150 SPED
	KJ001 += "  WHERE R_E_C_N_O_ IN(SELECT MAX(R_E_C_N_O_)
	KJ001 += "                        FROM SPED150
	KJ001 += "                       WHERE NFE_CHV IN (SELECT F2_CHVNFE
	KJ001 += "                                           FROM " + RetSqlName("SF2")
	KJ001 += "                                          WHERE F2_FILIAL = '"+xFilial("SF2")+"'
	KJ001 += "                                            AND F2_DOC = '"+MV_PAR01+"'
	KJ001 += "                                            AND F2_SERIE = '"+MV_PAR02+"'
	KJ001 += "                                            AND D_E_L_E_T_ = ' ')
	KJ001 += "                         AND PROTOCOLO <> 0
	KJ001 += "                         AND D_E_L_E_T_ = ' ')
Else
	KJ001 := " SELECT (SELECT F1_TIPO
	KJ001 += "           FROM " + RetSqlName("SF1")
	KJ001 += "          WHERE F1_FILIAL = '"+xFilial("SF1")+"'
	KJ001 += "            AND F1_DOC = '"+MV_PAR01+"'
	KJ001 += "            AND F1_SERIE = '"+MV_PAR02+"'
	KJ001 += "            AND F1_CHVNFE = SPED.NFE_CHV "
	KJ001 += "            AND D_E_L_E_T_ = ' ') F2_TIPO,
	KJ001 += "        (SELECT F1_FORNECE+F1_LOJA
	KJ001 += "           FROM " + RetSqlName("SF1")
	KJ001 += "          WHERE F1_FILIAL = '"+xFilial("SF1")+"'
	KJ001 += "            AND F1_DOC = '"+MV_PAR01+"'
	KJ001 += "            AND F1_SERIE = '"+MV_PAR02+"'
	KJ001 += "            AND F1_CHVNFE = SPED.NFE_CHV "
	KJ001 += "            AND D_E_L_E_T_ = ' ') CLIFOR,
	KJ001 += "        NFE_CHV,
	KJ001 += "        PROTOCOLO,
	KJ001 += "        SUBSTRING(CONVERT(VARCHAR(30) , DHREGEVEN, 127), 1, 19) DHREGEVEN,
	KJ001 += "        CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),XML_SIG)) AS XXML,
	KJ001 += "        CORGAO,
	KJ001 += "        TPEVENTO,
	KJ001 += "        SEQEVENTO,
	KJ001 += "        VEREVENTO,
	KJ001 += "        CMOTEVEN
	KJ001 += "   FROM SPED150 SPED
	KJ001 += "  WHERE R_E_C_N_O_ IN(SELECT MAX(R_E_C_N_O_)
	KJ001 += "                        FROM SPED150
	KJ001 += "                       WHERE NFE_CHV IN (SELECT F1_CHVNFE
	KJ001 += "                                           FROM " + RetSqlName("SF1")
	KJ001 += "                                          WHERE F1_FILIAL = '"+xFilial("SF1")+"'
	KJ001 += "                                            AND F1_DOC = '"+MV_PAR01+"'
	KJ001 += "                                            AND F1_SERIE = '"+MV_PAR02+"'
	KJ001 += "                                            AND D_E_L_E_T_ = ' ')
	KJ001 += "                         AND PROTOCOLO <> 0
	KJ001 += "                         AND D_E_L_E_T_ = ' ')
	
EndIf

If chkfile("KJ01")
	dbSelectArea("KJ01")
	dbCloseArea()
EndIf

TCQUERY KJ001 New Alias "KJ01"
dbSelectArea("KJ01")
dbGotop()

_oXML := XmlParser(KJ01->XXML, "_", @cError, @cWarning )
If ValType(_oXML) != "O"
	cvRetOk  := .F.
Else
	SAVE _oXML XMLSTRING pMGetXML
Endif

If !cvRetOk
	MsgINFO("Problema com o XML da Carta de Correção - CCE!!!")
	Return
EndIf

kTextCorr := _oXML:_ENVEVENTO:_EVENTO:_INFEVENTO:_DETEVENTO:_XCORRECAO:TEXT
kCondUso  := _oXML:_ENVEVENTO:_EVENTO:_INFEVENTO:_DETEVENTO:_XCONDUSO:TEXT

kCnpjDest := ""
kEmaiDest := ""
If !KJ01->F2_TIPO $ "B/D" .and. MV_PAR03 == 1
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+KJ01->CLIFOR))
	kCnpjDest := SA1->A1_CGC
	kEmaiDest := SA1->A1_EMAIL
Else
	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA2")+KJ01->CLIFOR))
	kCnpjDest := SA2->A2_CGC
	kEmaiDest := SA2->A2_EMAIL
EndIf

oxCCE      := FWMSPrinter():New(KJ01->NFE_CHV, IMP_PDF , lAdjustToLegacy )//, , lDisableSetup)

oFont20n   := TFontEx():New(oxCCE,"Arial",20,20,.T.,.T.,.F.)
oFont20    := TFontEx():New(oxCCE,"Arial",20,20,.F.,.T.,.F.)
oFont15n   := TFontEx():New(oxCCE,"Arial",15,15,.T.,.T.,.F.)
oFont15    := TFontEx():New(oxCCE,"Arial",15,15,.F.,.T.,.F.)
oFont12n   := TFontEx():New(oxCCE,"Arial",12,12,.T.,.T.,.F.)
oFont12    := TFontEx():New(oxCCE,"Arial",12,12,.F.,.T.,.F.)
oFt12Luc   := TFontEx():New(oxCCE,"Lucida Console",12,12,.F.,.T.,.F.)
oFont10n   := TFontEx():New(oxCCE,"Arial",10,10,.T.,.T.,.F.)
oFont10    := TFontEx():New(oxCCE,"Arial",10,10,.F.,.T.,.F.)
oFont09n   := TFontEx():New(oxCCE,"Arial",09,09,.T.,.T.,.F.)
oFont09    := TFontEx():New(oxCCE,"Arial",09,09,.F.,.T.,.F.)
oFont08n   := TFontEx():New(oxCCE,"Arial",08,08,.T.,.T.,.F.)
oFont08    := TFontEx():New(oxCCE,"Arial",08,08,.F.,.T.,.F.)

PixelX     := oxCCE:nLogPixelX()
PixelY     := oxCCE:nLogPixelY()

oBrush     := TBrush():New( , CLR_BLACK )

If !oxCCE:Canceled()
	
	// Ordem obrigátoria de configuração do relatório
	oxCCE:SetResolution(72)
	oxCCE:SetLandscape()
	oxCCE:SetPaperSize(DMPAPER_A4)
	oxCCE:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior
	//oxCCE:cPathPDF := "c:\temp\" // Caso seja utilizada impressão em IMP_PDF
	
	xPrntPdf := .T.
	If Alltrim(oxCCE:cPrinter) <> "PDF" .or. Len(Alltrim(oxCCE:cPrinter)) > 3
		xPrntPdf := .F.
	EndIf
	
	oxCCE:StartPage()
	nHPage := oxCCE:nHorzRes()
	nHPage *= (300/PixelX)
	nHPage -= HMARGEM
	nVPage := oxCCE:nVertRes()
	nVPage *= (300/PixelY)
	nVPage -= VBOX
	nLine  := 0
	nLine  += IIF(xPrntPdf, 220, 50)
	nBaseTxt := 50
	nBaseCol := 50
	
	// O limite da Margem é nHPage - 270
	oxCCE:Box(nLine+000, nBaseCol, nLine+070, nHPage - 250, "-4")
	oxCCE:Say(nLine+045, nBaseTxt+10, dtoc(dDataBase) +"  "+ Substr(Time(),1,5) , oFont10:oFont)
	oxCCE:Say(nLine+055, nBaseTxt   , Padc("CARTA DE CORREÇÃO - CCE",115)       , oFont20n:oFont)
	
	nLine += 110
	oxCCE:Box(nLine+000  , nBaseCol        , nLine+240, (nHPage - 250)/2, "-4")
	oxCCE:Box(nLine+000  , (nHPage - 250)/2, nLine+120, nHPage - 250    , "-4")
	oxCCE:Box(nLine+120  , (nHPage - 250)/2, nLine+240, nHPage - 250    , "-4")
	nFontSize := 37
	oxCCE:Code128C(nLine + 180, nBaseCol+50, KJ01->NFE_CHV, nFontSize )
	oxCCE:Say(nLine+030  , ((nHPage - 250)/2) + 20, "Chave de Acesso"                               , oFont09n:oFont)
	oxCCE:Say(nLine+090  , ((nHPage - 250)/2) + 20, KJ01->NFE_CHV                                   , oFont15:oFont)
	oxCCE:Say(nLine+150  , ((nHPage - 250)/2) + 20, "Protocolo de autorização de uso"               , oFont09n:oFont)
	xDtHr := Substr(KJ01->DHREGEVEN,9,2)+"/"+Substr(KJ01->DHREGEVEN,6,2)+"/"+Substr(KJ01->DHREGEVEN,1,4)+"  "+Substr(KJ01->DHREGEVEN,12,8)
	oxCCE:Say(nLine+210  , ((nHPage - 250)/2) + 20, Alltrim(Str(KJ01->PROTOCOLO)) + "  " + xDtHr    , oFont15:oFont)
	
	nLine += 240
	oxCCE:Box(nLine+000  , nBaseCol + 100         , nLine+100, nBaseCol + 700    , "-4")
	oxCCE:Box(nLine+000  , nBaseCol + 700         , nLine+100, nHPage - 350      , "-4")
	
	oxCCE:Say(nLine+030  , nBaseCol + 100         , Padc("CNPJ/CPF Emitente",085)                     , oFont09n:oFont)
	oxCCE:Say(nLine+030  , nBaseCol + 720         , Padr("Razão Social",300)                          , oFont09n:oFont)
	xdCgc := Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")
	oxCCE:Say(nLine+090  , nBaseCol + 100         , Padc(xdCgc,46)                                    , oFont15:oFont)
	oxCCE:Say(nLine+090  , nBaseCol + 720         , Padr(SM0->M0_NOMECOM,300)                         , oFont15:oFont)
	
	nLine += 150
	oxCCE:Box(nLine+000, nBaseCol, nLine+1100, nHPage - 250, "-4")
	xrSalto := 040
	While !Empty(Alltrim(Substr(kTextCorr, 1, 125)))
		oxCCE:Say(nLine+xrSalto  , nBaseCol+10, Substr(kTextCorr, 1, 125)                                    , oFt12Luc:oFont)
		kTextCorr := Substr(kTextCorr, 126, Len(Alltrim(kTextCorr))-125)
		xrSalto += 040
	End
	
	nLine += 1100
	oxCCE:Box(nLine+000, nBaseCol       , nLine+120, nHPage - 2070, "-4")
	oxCCE:Box(nLine+000, (nHPage - 2070), nLine+120, nHPage - 1770, "-4")
	oxCCE:Box(nLine+000, (nHPage - 1770), nLine+120, nHPage - 1470, "-4")
	oxCCE:Box(nLine+000, (nHPage - 1470), nLine+120, nHPage - 1170, "-4")
	oxCCE:Box(nLine+000, (nHPage - 1170), nLine+120, nHPage - 0870, "-4")
	oxCCE:Box(nLine+000, (nHPage - 0870), nLine+120, nHPage - 0250, "-4")
	
	oxCCE:Say(nLine+030,  nBaseCol + 20       , "NF-e"                               , oFont09n:oFont)
	oxCCE:Say(nLine+030, (nHPage - 2070) + 20 , "Orgão"                              , oFont09n:oFont)
	oxCCE:Say(nLine+030, (nHPage - 1770) + 20 , "Tipo Evento"                        , oFont09n:oFont)
	oxCCE:Say(nLine+030, (nHPage - 1470) + 20 , "Seq Evento"                         , oFont09n:oFont)
	oxCCE:Say(nLine+030, (nHPage - 1170) + 20 , "Versão Evento"                      , oFont09n:oFont)
	
	oxCCE:Say(nLine+090,  nBaseCol + 20       , MV_PAR01                             , oFont12:oFont)
	oxCCE:Say(nLine+090, (nHPage - 2070) + 20 , Alltrim(Str(KJ01->CORGAO))           , oFont12:oFont)
	oxCCE:Say(nLine+090, (nHPage - 1770) + 20 , Alltrim(Str(KJ01->TPEVENTO))         , oFont12:oFont)
	oxCCE:Say(nLine+090, (nHPage - 1470) + 20 , Alltrim(Str(KJ01->SEQEVENTO))        , oFont12:oFont)
	oxCCE:Say(nLine+090, (nHPage - 1170) + 20 , Alltrim(Str(KJ01->VEREVENTO))        , oFont12:oFont)
	oxCCE:Say(nLine+090, (nHPage - 0870) + 20 , KJ01->CMOTEVEN                       , oFont12:oFont)
	
	nLine += 120
	oxCCE:Box(nLine+000, nBaseCol       , nLine+120, nHPage - 1410, "-4")
	oxCCE:Box(nLine+000, (nHPage - 1410), nLine+120, nHPage - 0250, "-4")
	
	oxCCE:Say(nLine+030,  nBaseCol + 20       , "CNPJ/CPF Destinatário"              , oFont09n:oFont)
	oxCCE:Say(nLine+030, (nHPage - 1410) + 20 , "E-mail Destinatário"                , oFont09n:oFont)
	kCnpjDest := Transform(kCnpjDest,"@R 99.999.999/9999-99")
	oxCCE:Say(nLine+090,  nBaseCol + 20       , kCnpjDest                            , oFont12:oFont)
	oxCCE:Say(nLine+090, (nHPage - 1410) + 20 , kEmaiDest                            , oFont12:oFont)
	
	nLine += 170
	oxCCE:Say(nLine+030,  nBaseCol + 20       , "Condições de uso da Carta de Correção"          , oFont09n:oFont)
	nLine += 080
	While !Empty(Alltrim(Substr(kCondUso, 1, 125)))
		oxCCE:Say(nLine          , nBaseCol+20, Substr(kCondUso, 1, 125)                             , oFt12Luc:oFont)
		kCondUso := Substr(kCondUso, 126, Len(Alltrim(kCondUso))-125)
		nLine += 040
	End
	
	nLine += 150
	oxCCE:line( nLine, nBaseCol     , nLine, nBaseCol+1000)
	oxCCE:line( nLine, nBaseCol+1100, nLine, nHPage - 250 )
	oxCCE:Say(nLine+030,  nBaseCol  , Padc("Local e data",135)              , oFont10n:oFont)
	
	nLine += 200
	oxCCE:Say(nLine+030,  nBaseCol      , "NF-e emitida em ambiente de: "   , oFont09:oFont)
	oxCCE:Say(nLine+030,  nBaseCol+400  , "PRODUÇÃO"                        , oFont12n:oFont)
	
	oxCCE:EndPage()
	oxCCE:Preview() //Visualiza antes de imprimir
	
EndIf

KJ01->(dbCloseArea())

FreeObj(oxCCE)
oxCCE := Nil

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 07/08/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,fTamX1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Nota Fiscal            ?","","","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Serie                  ?","","","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Tipo de NFe            ?","","","mv_ch3","N",01,0,0,"C","","mv_par03","1-Saída","","","","","2-Entrada","","","","","","","","","","","","","","","","","","",""})
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
