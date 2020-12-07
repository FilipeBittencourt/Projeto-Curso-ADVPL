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

User Function BIA222()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA222
Empresa   := Biancogres Cerâmica S/A
Data      := 22/01/13
Uso       := Gestão de Pessoal
Aplicação := Comprovante de Recebimento da CTPS
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local kLp
Local aArea     := GetArea()
Local lExistNfe := .F.
Local lAdjustToLegacy := .T.  // Usado para montar o Objeto Printer
Local lDisableSetup   := .T.  // Usado para montar o Objeto Printer

Private nHPage
Private nVPage
Private nLine
Private nBaseTxt
Private nBaseCol

Private oRecCTPS   := FWMSPrinter():New("rec_ctps.rel", IMP_PDF , lAdjustToLegacy )//, , lDisableSetup)
Private oSetup
Private nConsNeg := 0.40 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
Private nConsTex := 0.38 // Constante para concertar o cálculo retornado pelo GetTextWidth.

PRIVATE oFont20n   := TFontEx():New(oRecCTPS,"Arial",20,20,.T.,.T.,.F.)
PRIVATE oFont12n   := TFontEx():New(oRecCTPS,"Arial",12,12,.T.,.T.,.F.)
PRIVATE oFont14n   := TFontEx():New(oRecCTPS,"Arial",14,14,.T.,.T.,.F.)
PRIVATE oFntEx12   := TFontEx():New(oRecCTPS,"Lucida Console",12,12,.T.,.T.,.F.)

Private PixelX := oRecCTPS:nLogPixelX()
Private PixelY := oRecCTPS:nLogPixelY()
oBrush         := TBrush():New( , CLR_BLACK )

fPerg := "BIA222"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
fValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

// Caso seja cancelado o processamento.
If oRecCTPS:Canceled()
	Return
EndIf

// Ordem obrigátoria de configuração do relatório
oRecCTPS:SetResolution(72)
oRecCTPS:SetPortrait()
oRecCTPS:SetPaperSize(DMPAPER_A4)
oRecCTPS:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior
oRecCTPS:cPathPDF := "c:\temp\" // Caso seja utilizada impressão em IMP_PDF
aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"

xPrntPdf := .T.
If Alltrim(oRecCTPS:cPrinter) <> "PDF" .or. Len(Alltrim(oRecCTPS:cPrinter)) > 3
	xPrntPdf := .F.
EndIf

xjMotiv := ""
KX003 := " SELECT RA_MAT, RA_NOME, RA_NUMCP, RA_SERCP
KX003 += "   FROM " + RetSqlName("SRA")
KX003 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
KX003 += "    AND RA_MAT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
If MV_PAR05 == 1                                                            // Férias
	*********************************************************************************
	KX003 += "  AND RA_MAT IN (SELECT RF_MAT FROM " + RetSqlName("SRF") 
	KX003 += "  WHERE RF_FILIAL = '"+xFilial("SR8")+"'
	KX003 += "  AND RF_MAT = RA_MAT
	KX003 += "  AND (RF_DATAINI BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"'
	KX003 += "    OR RF_DATINI2 BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' 
	KX003 += "    OR RF_DATINI3 BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"')
	KX003 += "  AND D_E_L_E_T_ = ' ' AND RA_DEMISSA = '')
	KX003 += "  AND RA_DEMISSA = ''  	
	xjMotiv := "FÉRIAS"
	
ElseIf MV_PAR05 == 2                                                      // Rescisão
	*********************************************************************************
	KX003 += "    AND RA_DEMISSA BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"'
	xjMotiv := "RESCISÃO"
	
ElseIf MV_PAR05 == 3                                                      // Admissão
	*********************************************************************************
	KX003 += "    AND RA_ADMISSA BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"'
	xjMotiv := "ADMISSÃO"
	
Else                                                                        // Avulso
	*********************************************************************************
	// TODOS OS REGISTROS
	xjMotiv := Alltrim(MV_PAR06)
	
EndIf
KX003 += "    AND RA_CATFUNC <> 'A'
KX003 += "    AND D_E_L_E_T_ = ' '
KX003 += "  ORDER BY RA_MAT
KX003 := ChangeQuery(KX003)
cIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,KX003),'KX03',.T.,.T.)
dbSelectArea("KX03")
dbGoTop()
xQdPag := 1
xLnhOld := 0
While !Eof()
	
	If xQdPag == 1
		
		oRecCTPS:StartPage()
		nHPage := oRecCTPS:nHorzRes()
		nHPage *= (300/PixelX)
		nHPage -= HMARGEM
		nVPage := oRecCTPS:nVertRes()
		nVPage *= (300/PixelY)
		nVPage -= VBOX
		nBaseTxt := 50
		nBaseCol := 50
		
	EndIf
	
	nLine  := xLnhOld
	nLine  += IIF(xPrntPdf, 220, 50)
	
	// O limite da Margem é nHPage - 270
	oRecCTPS:Box(nLine+000, nBaseCol, nLine+085, nHPage - 270, "-4")
	oRecCTPS:Say(nLine+055, nBaseTxt+300, Padc("Comprovante de Recebimento da CTPS",070) , oFont20n:oFont)
	If File(aBitmap)
		oRecCTPS:SayBitmap( nLine+005, nBaseCol+005, aBitmap, 0300, 0075 )
	EndIf
	
	oRecCTPS:Say(nLine+150, nBaseTxt+1350, Padc(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),45)                                         , oFntEx12:oFont)
	oRecCTPS:Say(nLine+200, nBaseTxt+1350, Padc(Alltrim(SM0->M0_NOMECOM),45)                                                               , oFntEx12:oFont)
	oRecCTPS:Say(nLine+250, nBaseTxt+1350, Padc(Alltrim(SM0->M0_ENDCOB),45)                                                                , oFntEx12:oFont)
	oRecCTPS:Say(nLine+300, nBaseTxt+1350, Padc(Alltrim(SM0->M0_BAIRCOB)+" - "+Alltrim(SM0->M0_CIDCOB)+" - "+Alltrim(SM0->M0_ESTCOB),45)   , oFntEx12:oFont)
	oRecCTPS:Say(nLine+350, nBaseTxt+1350, Padc(Alltrim(SM0->M0_CEPCOB),45)                                                                , oFntEx12:oFont)
	
	nLine += 200
	oRecCTPS:Say(nLine    , nBaseTxt+0020, "Nome: " + KX03->RA_NOME                                                                        , oFont14n:oFont)
	nLine += 050
	oRecCTPS:Say(nLine    , nBaseTxt+0020, "Matrícula: " + KX03->RA_MAT                                                                    , oFont14n:oFont)
	xf_Ref := "Recebemos nesta data a CTPS "+Alltrim(KX03->RA_NUMCP)+", Série: "+Alltrim(KX03->RA_SERCP)+", para anotações de: "
	nLine += 100
	oRecCTPS:Say(nLine    , nBaseTxt+0020, Substr(xf_Ref, 1, 120)                                                                          , oFont14n:oFont)
	nLine += 100
	oRecCTPS:Say(nLine    , nBaseTxt+0020, xjMotiv /*+ " " + Replicate("_",135-Len(Alltrim(xjMotiv))) */                                       , oFont14n:oFont)
	nLine += 100
	//oRecCTPS:Say(nLine    , nBaseTxt+0020, Replicate("_",135)                                                                              , oFont14n:oFont)
	
	nLine += 100
	oRecCTPS:Line (nLine  , nBaseCol+0030, nLine, 1000)
	oRecCTPS:Say(nLine-05 , nBaseCol+1700, Padc("_____/_____/________",20)                                                                 , oFont12n:oFont)
	nLine += 050
	oRecCTPS:Say(nLine    , nBaseCol+0030, Padc("Assinatura - Setor de Pessoal",110)                                                       , oFont12n:oFont)
	oRecCTPS:Say(nLine    , nBaseCol+1700, Padc("Data",20)                                                                                 , oFont12n:oFont)
	
	nLine += 100
	oRecCTPS:Box(nLine+000, nBaseCol, nLine+085, nHPage - 270, "-4")
	oRecCTPS:Say(nLine+055, nBaseTxt+300, Padc("Recibo de Devolução da CTPS",070) , oFont20n:oFont)
	
	xf_Ref := "Recebi nesta data em devolução, minha CTPS, que apresentei no dia "
	nLine += 200
	oRecCTPS:Say(nLine    , nBaseTxt+0020, Substr(xf_Ref, 1, 120)                                                                          , oFont14n:oFont)
	xf_Ref := "_____/_____/________, para anotações acima."
	nLine += 100
	oRecCTPS:Say(nLine    , nBaseTxt+0020, Substr(xf_Ref, 1, 120)                                                                          , oFont14n:oFont)
	
	nLine += 100
	oRecCTPS:Line (nLine  , nBaseCol+0030, nLine, 1000)
	oRecCTPS:Say(nLine-05 , nBaseCol+1700, Padc("_____/_____/________",20)                                                                 , oFont12n:oFont)
	
	nLine += 050
	oRecCTPS:Say(nLine    , nBaseCol+0030, Padc("Assinatura - Colaborador",110)                                                            , oFont12n:oFont)
	oRecCTPS:Say(nLine    , nBaseCol+1700, Padc("Data",20)                                                                                 , oFont12n:oFont)
	
	If xQdPag == 1
		
		nLine += 100
		oRecCTPS:Say(nLine    , nBaseTxt+0020, Replicate("- ",100)                                                                             , oFont14n:oFont)
		
		xQdPag  := 2
		xLnhOld := nLine - 100
		
	Else
		
		xQdPag := 1
		xLnhOld := 0
		oRecCTPS:EndPage()
		
	EndIf
	
	dbSelectArea("KX03")
	dbSkip()
End

Ferase(cIndex+GetDBExtension())     //arquivo de trabalho
Ferase(cIndex+OrdBagExt())          //indice gerado
KX03->(dbCloseArea())

oRecCTPS:EndPage()
oRecCTPS:Preview()

FreeObj(oRecCTPS)
oRecCTPS := Nil
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
aAdd(aRegs,{cPerg,"01","De Matricula          ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
aAdd(aRegs,{cPerg,"02","Até Matricula         ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
aAdd(aRegs,{cPerg,"03","De Data               ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
aAdd(aRegs,{cPerg,"04","Até Data              ?","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
aAdd(aRegs,{cPerg,"05","Motivo                ?","","","mv_ch5","N",01,0,0,"C","","mv_par05","Férias","","","","","Rescisão","","","","","Admissão","","","","","Avulso","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Descrição p/ Avulso   ?","","","mv_ch6","C",75,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
