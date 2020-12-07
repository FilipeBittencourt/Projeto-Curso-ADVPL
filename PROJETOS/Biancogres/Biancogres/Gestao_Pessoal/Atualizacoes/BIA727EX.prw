#include "TOTVS.CH"

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

User Function BIA727EX()

Local cCondicao
Local aIndScr := {}

cHInicio := Time()
fPerg := "B727EX"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()

If !Pergunte(fPerg,.T.)
	Return
EndIf

cCadastro := "Calendário de Feriados - EXPEDIÇÃO"
aRotina   := { {"Pesquisar"     ,"AxPesqui"	  ,0,1},;
{               "Visualizar"    ,"AxVisual"	  ,0,2},;
{               "Incluir"       ,"AxInclui"	  ,0,3},;
{               "Alterar"       ,"AxAltera"	  ,0,4},;
{               "Excluir"       ,"AxDeleta"	  ,0,5},;
{               "Imprimir"      ,"U_B727EXA"  ,0,6}}

dbSelectArea("Z24")
cCondicao := "Dtos(Z24_DATREF) >= '"+MV_PAR01+"0101"+"' .And. Dtos(Z24_DATREF) <= '"+MV_PAR01+"1231"+"' "

mBrowse(6,1,22,75, "Z24", , , , , ,, , , , , , , , , , , , cCondicao)

EndFilBrw("Z24",aIndScr)

Return

User Function B727EXA()

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Private aArea           := GetArea()
Private lAdjustToLegacy := .T.  // Usado para montar o Objeto Printer
Private lDisableSetup   := .T.  // Usado para montar o Objeto Printer
Private lzServer        := .F.
Private lzViewPDF       := .T.

Private zpDirLocal      := "c:\temp\"

Private nHPage
Private nVPage
Private nLine
Private nBaseTxt
Private nBaseCol

Private oCaledFr
Private PixelX
Private PixelY
Private oSetup
Private nConsNeg      := 0.40 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
Private nConsTex      := 0.38 // Constante para concertar o cálculo retornado pelo GetTextWidth.
Private oBrush        := TBrush():New( , CLR_BLACK )

Private fNmRel := "calendferiado"

If !lIsDir( zpDirLocal )
	MakeDir( zpDirLocal )
EndIf

oCaledFr := FWMsPrinter():New( fNmRel+".rel", IMP_PDF, lAdjustToLegacy, , lDisableSetup, , , , lzServer, , , lzViewPDF)
PixelX   := oCaledFr:nLogPixelX()
PixelY   := oCaledFr:nLogPixelY()

oFont20n   := TFontEx():New(oCaledFr,"Arial",20,20,.T.,.T.,.F.)
oFont20    := TFontEx():New(oCaledFr,"Arial",20,20,.F.,.T.,.F.)
oFont18n   := TFontEx():New(oCaledFr,"Arial",18,18,.T.,.T.,.F.)
oFont18    := TFontEx():New(oCaledFr,"Arial",18,18,.F.,.T.,.F.)
oFont15n   := TFontEx():New(oCaledFr,"Lucida Console",15,15,.T.,.T.,.F.)
oFont15    := TFontEx():New(oCaledFr,"Arial",15,15,.F.,.T.,.F.)
oFont10n   := TFontEx():New(oCaledFr,"Arial",10,10,.T.,.T.,.F.)
oFont10    := TFontEx():New(oCaledFr,"Arial",10,10,.F.,.T.,.F.)
oFont12n   := TFontEx():New(oCaledFr,"Arial",12,12,.T.,.T.,.F.)
oFont12    := TFontEx():New(oCaledFr,"Arial",12,12,.F.,.T.,.F.)
oFntEx12   := TFontEx():New(oCaledFr,"Lucida Console",12,12,.T.,.T.,.F.)
oFont09n   := TFontEx():New(oCaledFr,"Arial",09,09,.T.,.T.,.F.)
oFont09    := TFontEx():New(oCaledFr,"Arial",09,09,.F.,.T.,.F.)
oFont08n   := TFontEx():New(oCaledFr,"Arial",08,08,.T.,.T.,.F.)
oFont08    := TFontEx():New(oCaledFr,"Arial",08,08,.F.,.T.,.F.)

// Ordem obrigátoria de configuração do relatório
oCaledFr:SetResolution(72)
oCaledFr:SetPortrait()
oCaledFr:SetPaperSize(DMPAPER_A4)
oCaledFr:SetMargin(60,60,60,60)       // nEsquerda, nSuperior, nDireita, nInferior
oCaledFr:cPathPDF := zpDirLocal       // Caso seja utilizada impressão em IMP_PDF, define diretório de gravação

xPrntPdf := .T.
If Alltrim(oCaledFr:cPrinter) <> "PDF" .or. Len(Alltrim(oCaledFr:cPrinter)) > 3
	xPrntPdf := .F.
EndIf

xQdPag := 1
xLnhOld := 0

HY001 := " SELECT Z24_DATREF,
HY001 += "        Z24_EXPEDI,
HY001 += "        Z24_DESCRI
HY001 += "   FROM " + RetSqlName("Z24")
HY001 += "  WHERE Z24_FILIAL = '"+xFilial("Z24")+"'
HY001 += "    AND SUBSTRING(Z24_DATREF,1,4) = '"+MV_PAR01+"'
HY001 += "    AND D_E_L_E_T_ = ' '
HYcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,HY001),'HY01',.T.,.T.)
dbSelectArea("HY01")
dbGoTop()
While !Eof()
	
	If xQdPag == 1
		
		oCaledFr:StartPage()
		nHPage := oCaledFr:nHorzRes()
		nHPage *= (300/PixelX)
		nHPage -= HMARGEM
		nVPage := oCaledFr:nVertRes()
		nVPage *= (300/PixelY)
		nVPage -= VBOX
		nBaseTxt := 50
		nBaseCol := 50
		
	EndIf
	
	nLine  := xLnhOld
	nLine  += IIF(xPrntPdf, 150, 150)

	nLine += 150
	oCaledFr:Say(nLine    , nBaseTxt     , Padc("CALENDÁRIO DE FERIADOS - "+MV_PAR01,135)    , oFont18n:oFont)
	nLine += 100
	
	xf_Titu := +;
	Padc("Dia"                                                                      ,20)+" "+;
	Padc("Feriado"                                                                  ,20)+" "+;
	Padc("Expediente"                                                               ,15)+" "+;
	Padl("Crédito"                                                                  ,07)+" "+;
	Padl("Débito"                                                                   ,07)+" "+;
	Padr("Descrição"                                                                ,50)
	nLine += 100
	oCaledFr:Box(nLine-050, nBaseCol, nLine+020, nHPage - 270, "-4")
	oCaledFr:Say(nLine, nBaseTxt, xf_Titu         , oFntEx12:oFont)
	oCaledFr:Line(nLine-050, 0360, nLine+017, 0360)
	oCaledFr:Line(nLine-050, 0720, nLine+017, 0720)
	oCaledFr:Line(nLine-050, 0970, nLine+017, 0970)
	oCaledFr:Line(nLine-050, 1125, nLine+017, 1125)
	oCaledFr:Line(nLine-050, 1250, nLine+017, 1250)
	
	xhCred := 0
	xhDebt := 0
	dbSelectArea("HY01")
	While !Eof()
		
		xyDia := StrZero(Day(stod(HY01->Z24_DATREF)),2) +"/"+ Substr(MesExtenso(stod(HY01->Z24_DATREF)),1,3) + "   " + DiaSemana(stod(HY01->Z24_DATREF))
		
		xf_Item := +;
		Padc(xyDia                                                                      ,20)+" "+;
		Padc(IIf(HY01->Z24_EXPEDI == "S", "Sim", "Não")                                 ,15)+" "+;
		Padr(HY01->Z24_DESCRI                                                           ,50)
		nLine += 069
		oCaledFr:Box(nLine-050, nBaseCol, nLine+020, nHPage - 270, "-4")
		oCaledFr:Say(nLine, nBaseTxt, xf_Item         , oFntEx12:oFont)
		oCaledFr:Line(nLine-050, 0360, nLine+017, 0360)
		oCaledFr:Line(nLine-050, 0720, nLine+017, 0720)
		oCaledFr:Line(nLine-050, 0970, nLine+017, 0970)
		oCaledFr:Line(nLine-050, 1125, nLine+017, 1125)
		oCaledFr:Line(nLine-050, 1250, nLine+017, 1250)
				
		dbSelectArea("HY01")
		dbSkip()
		
	End
	
	xf_Tot := +;
	Padc(""                                                                                   ,20)+" "+;
	Padc(""                                                                                   ,20)+" "+;
	Padc(""                                                                                   ,15)+" "+;
	Padl(Transform(xhCred, "@E 9999.99")                                                      ,07)+" "+;
	Padl(Transform(xhDebt, "@E 9999.99")                                                      ,07)+" "+;
	Padr("( Credito - Debito ) --->>>      " + Transform(xhCred - xhDebt, "@E 99,999.99")     ,50)
	nLine += 069
	oCaledFr:Box(nLine-050, nBaseCol, nLine+020, nHPage - 270, "-4")
	oCaledFr:Say(nLine, nBaseTxt, xf_Tot         , oFntEx12:oFont)
	oCaledFr:Line(nLine-050, 0360, nLine+017, 0360)
	oCaledFr:Line(nLine-050, 0720, nLine+017, 0720)
	oCaledFr:Line(nLine-050, 0970, nLine+017, 0970)
	oCaledFr:Line(nLine-050, 1125, nLine+017, 1125)
	oCaledFr:Line(nLine-050, 1250, nLine+017, 1250)
	
	nLine += 200
	oCaledFr:Say(nLine    , nBaseTxt+0020, "COMPENSAÇÃO:"                       , oFont15n:oFont)
	nLine += 050
	sfDescr := "A partir do dia 02/01/2013 até 11/03/2013, expediente de 07:30 às 18:00. Na sexta 07:30 às 17:00."
	oCaledFr:Say(nLine    , nBaseTxt+0020, sfDescr                              , oFont12:oFont)
	
	nLine += 200
	oCaledFr:Say(nLine    , nBaseTxt+0020, "APROVAÇÕES:"                        , oFont15n:oFont)
	
	nLine += 150
	oCaledFr:Line (nLine, nBaseCol, nLine, 1000)
	nLine += 050
	oCaledFr:Say(nLine  , nBaseCol, Padc("Diretor Presidente (Biancogres)",110)                , oFont12n:oFont)
	nLine -= 050
	oCaledFr:Line (nLine, nBaseCol+1100, nLine, nHPage - 267)
	nLine += 050
	oCaledFr:Say(nLine  , nBaseCol+1100, Padc("Diretor Presidente (Incesa)",110)               , oFont12n:oFont)
	
	nLine += 150
	oCaledFr:Line (nLine, nBaseCol, nLine, 1000)
	nLine += 050
	oCaledFr:Say(nLine  , nBaseCol, Padc("Diretor Comercial (Biancogres)",110)                 , oFont12n:oFont)
	nLine -= 050
	oCaledFr:Line (nLine, nBaseCol+1100, nLine, nHPage - 267)
	nLine += 050
	oCaledFr:Say(nLine  , nBaseCol+1100, Padc("Diretor Administrativo/Financeiro",110)         , oFont12n:oFont)
	
	xQdPag := 1
	xLnhOld := 0
	oCaledFr:EndPage()
	
End

oCaledFr:Preview()

FreeObj(oCaledFr)
oCaledFr := Nil
RestArea(aArea)

Ferase(HYcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(HYcIndex+OrdBagExt())          //indice gerado
HY01->(dbCloseArea())

Return

Static Function ValidPerg()
local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,fTamX1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Filtra Ano?","","","mv_ch1","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
