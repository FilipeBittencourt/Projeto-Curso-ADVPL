#include "protheus.ch"
#include "topconn.ch"


/*/{Protheus.doc} F3ZZ6FOR
@description Consulta Padrao de formato de produtos
@author Fernando Rocha
@since 17/0/2021
@version undefined
@type function
/*/

static cZZ6Ret := ""
static aLinZZ6 := {}

user Function F3ZZ6FOR()

	local aArea     := GetArea()
	local oDlg		:= nil
	local oCombo	:= nil
	local oButPesq  := nil
	local oGet		:= nil
	local oButOK	:= nil
	local oButCan 	:= nil
	local nLargBot	:= 30
	local nAltBot	:= 11
	local nInterv   := 3
	local nTempInt  := 0
	local nVertBot  := 250
	Local nd
	private lCheck  := .f.
	private nPos    := 1
	private cPesq	:= space(100)
	private aCombo	:= {"Codigo","Descricao"}
	private cCombo	:= ""
	private oBrowse := nil
	private oboOK   := LoadBitmap(GetResources(),'LBTICK')
	private oboNO   := LoadBitmap(GetResources(),'LBNO')
	private aCamLab := {''," Codigo"," Descricao"}
	private aCamTam := {15,35,300}

	cZZ6Ret := ""
	if empty(aLinZZ6)
		Processa( {|| CarregaPar() },"Aguarde...","Carregando Parametros...")
	else
		for nd:=1 to len(aLinZZ6)
			aLinZZ6[nd,1] := 'NO'
		next nd
	endif

	oDlg:=MSDialog():New(0,0,530,700,"Formato de Produtos",,,,,CLR_BLACK,,,,.T.)

	oCombo   := tComboBox():New(3,3,{|u|if(PCount()>0,cCombo:=u,cCombo)},aCombo,200,10,oDlg,,{|| OrdBrowse() },,,,.T.,,,,,,,,,'cCombo')
	oGet     := TGet():New(17,3,{|u| if(PCount()>0,cPesq:=u,cPesq)},oDlg,200,10,,,,,,,,.T.,,,,,,,,,,'cPesq')
	oButPesq := TButton():New(3,205,'Pesquisar',oDlg,{|| pesqBrow()},40,11,,,,.T.)

	// Marca / Desmarca - todos
	oCheck1 := TCheckBox():New(41,04,'',{|| lCheck},oDlg,15,15,,{|| ( lCheck:=!lCheck,MarDesAll(lCheck) )},,,,,,.T.,,,)
	oSay1   := tSay():new(41 ,12,{|| "Marcar/Desmarcar Todos"},oDlg,,,,,,.T.,,,100,10)

	oBrowse := TWBrowse():New( 50,03,350,190,,aCamLab,aCamTam, oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrowse:SetArray(aLinZZ6)
	oBrowse:bLine:={||{  Iif(aLinZZ6[oBrowse:nAt,01]=='OK',oboOK,oboNO), aLinZZ6[oBrowse:nAt,02],aLinZZ6[oBrowse:nAt,03] }}
	oBrowse:bLDblClick := {|| Iif(aLinZZ6[oBrowse:nAt,01]=='OK',aLinZZ6[oBrowse:nAt,01]:='NO',aLinZZ6[oBrowse:nAt,01]:='OK') }

	nTempInt += nInterv
	oButOK   := TButton():New(nVertBot,nTempInt,'OK',oDlg,{|| fRetPacote(),oDlg:End() },nLargBot,nAltBot,,,,.T.)
	nTempInt += nInterv + nLargBot
	oButCan  := TButton():New(nVertBot,nTempInt,'Cancelar',oDlg,{|| cZZ6Ret:="",oDlg:End() },nLargBot,nAltBot,,,,.T.)

	oDlg:activate(,,,.T.)

	RestArea(aArea)
Return .T.


user Function F3ZZ6PFR() //Retorno da Consulta ZZ6A
return cZZ6Ret



static function CarregaPar()

	Local aAreax   := GetArea()
	local cQuery   := ''
	local nTotReg  := 0
	local nContReg := 0
	local cTab     := GetNextAlias()

	BeginSql alias cTab
		%noparser%    
		SELECT ZZ6_COD,ZZ6_DESC
		FROM  ZZ6010 (NOLOCK)
		WHERE D_E_L_E_T_ = ''
		
	EndSql
	dbselectarea(cTab)
	Count To nTotReg
	ProcRegua(nTotReg)
	(cTab)->(dbgotop())

	While !(cTab)->(EOF())
		nContReg++
		IncProc("Carregando - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(100,3)) + "%")
		AADD( aLinZZ6, { "", Alltrim((cTab)->ZZ6_COD), alltrim((cTab)->ZZ6_DESC) } )
		(cTab)->(dbskip())
	enddo
	RestArea(aAreax)
return


static function OrdBrowse() // ordena Browse--------------------------------------------------------
	if cCombo == aCombo[2]
		aSort( aLinZZ6,,,{ |x,y| ( x[3]+x[2] ) < ( y[3]+y[2] ) } )
		oBrowse:GoBottom()
		oBrowse:GoTop()
	else
		aSort( aLinZZ6,,,{ |x,y| ( x[2]+x[3] ) < ( y[2]+y[3] ) } )
		oBrowse:GoBottom()
		oBrowse:GoTop()
	endif
return


static function pesqBrow() // realiza a busca da pesquisa no array e posiciona o ponteiro -------------------
	if cCombo == aCombo[2]
		nPos:= ASCANX(aLinZZ6,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[3]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)
		if nPos == 0
			oBrowse:SetFocus()
			oBrowse:GoPosition(1)
			nPos:= ASCANX(aLinZZ6,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[3]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)
		endif
		oBrowse:SetFocus()
		if nPos > 0
			oBrowse:GoPosition(nPos)
		endif
	else
		nPos:= ASCANX(aLinZZ6,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[2]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)
		if nPos == 0
			oBrowse:SetFocus()
			oBrowse:GoPosition(1)
			nPos:= ASCANX(aLinZZ6,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[2]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)
		endif
		oBrowse:SetFocus()
		if nPos > 0
			oBrowse:GoPosition(nPos)
		endif
	endif
return


static function fContMark()
	local ntotmark := 0
	Local nh
	for nh:=1 to len(aLinZZ6)
		if aLinZZ6[nh,1] == 'OK'
			ntotmark ++
		endif
	next nh
return ntotmark


static function fRetPacote()

	Local nk

	cZZ6Ret := ""
	for nk:=1 to len(aLinZZ6)
		if aLinZZ6[nk,1] <> 'OK'
			loop
		endif
		cZZ6Ret += aLinZZ6[nk,2]+";"
	next nk
return


static function MarDesAll(pCheck)
	local nTempLin := oBrowse:nAt
	Local nx
	for nx := 1 to len(aLinZZ6)
		aLinZZ6[nx,1]:= iif(pCheck,'OK','NO')
	next nx
	oBrowse:GoPosition(len(aLinZZ6))
	oBrowse:GoPosition(nTempLin)
return
