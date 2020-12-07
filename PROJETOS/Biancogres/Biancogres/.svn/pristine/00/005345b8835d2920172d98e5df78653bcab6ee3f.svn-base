#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFA003
@author Artur Antunes
@since 10/05/2017
@version 1.0
@description Consulta personalizada de Grupos - SBM
@obs OS 1172-17
@type function
/*/

user Function BIAFA003()     

	local aArea     	:= GetArea()
	local oDlg			:= nil 
	local oCombo		:= nil 
	local oButPesq  	:= nil 
	local oGet			:= nil
	local oButOK		:= nil 
	local oButCan 		:= nil 
	local nLargBot		:= 30  
	local nAltBot		:= 11
	local nInterv   	:= 3 
	local nTempInt  	:= 0  
	local nVertBot  	:= 250
	local cVar			:= ReadVar()
	local cConteudo 	:= &(cVar)
	local lOk			:= .F.
	private nPos    	:= 1  
	private cPesq		:= space(100)
	private aCombo		:= {"Cod Grupo","Descricao"}
	private cCombo		:= "Cod Grupo"
	private oBrowse 	:= nil  
	private oboOK   	:= LoadBitmap(GetResources(),'LBTICK')    
	private oboNO   	:= LoadBitmap(GetResources(),'LBNO')   
	private aCamLab 	:= {'',"Cod Grupo","  Descricao","Bloqueado"}
	private aCamTam 	:= {30,60,200,60}
	private cBiaSmbRet 	:= "" 
	private aBiaLinSbm 	:= {}

	Processa( {|| fCarregaGrupo(Alltrim(cConteudo)) },"Aguarde...","Carregando Grupos...")

	if len(aBiaLinSbm) == 0
		return .T.
	endif

	OrdBrowse()
	oDlg:=MSDialog():New(0,0,530,700,"Parametros",,,,,CLR_BLACK,,,,.T.) 

	oCombo := tComboBox():New(3,3,{|u|if(PCount()>0,cCombo:=u,cCombo)},aCombo,200,10,oDlg,,{|| OrdBrowse() },,,,.T.,,,,,,,,,'cCombo')
	oGet := TGet():New(17,3,{|u| if(PCount()>0,cPesq:=u,cPesq)},oDlg,200,10,,,,,,,,.T.,,,,,,,,,,'cPesq')
	oButPesq := TButton():New(3,205,'Pesquisar',oDlg,{|| pesqBrow()},40,11,,,,.T.)

	oBrowse := TWBrowse():New( 40,01,350,200,,aCamLab,aCamTam, oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrowse:SetArray(aBiaLinSbm) 
	oBrowse:bLine:={||{  Iif(aBiaLinSbm[oBrowse:nAt,01]=='OK',oboOK,oboNO), aBiaLinSbm[oBrowse:nAt,02],aBiaLinSbm[oBrowse:nAt,03],aBiaLinSbm[oBrowse:nAt,04] }}      
	oBrowse:bLDblClick := {|| Iif(aBiaLinSbm[oBrowse:nAt,01]=='OK',aBiaLinSbm[oBrowse:nAt,01]:='NO',aBiaLinSbm[oBrowse:nAt,01]:='OK') }

	nTempInt += nInterv
	oButOK  := TButton():New(nVertBot,nTempInt,'OK',oDlg,{|| lOk:=.T.,fRetParam(),oDlg:End() },nLargBot,nAltBot,,,,.T.) 
	nTempInt += nInterv + nLargBot
	oButCan := TButton():New(nVertBot,nTempInt,'Cancelar',oDlg,{|| oDlg:End() },nLargBot,nAltBot,,,,.T.)

	oDlg:activate(,,,.T.)
	if lOk
		&(cVar) := cBiaSmbRet
	endif	
	RestArea(aArea) 
Return .T.


static function fCarregaGrupo(cConteudo)

	Local aAreax 	:= GetArea()
	local nTotReg	:= 0  
	local nContReg	:= 0 
	Local cTab     	:= GetNextAlias() 
	local cQuery	:= ''
	local cMarca	:= ''

	cConteudo := StrTran(cConteudo,'|',';')
	cConteudo := StrTran(cConteudo,'/',';')
	cConteudo := StrTran(cConteudo,'\',';')
	cConteudo := StrTran(cConteudo,',',';')
	cConteudo := ';'+cConteudo+';'

	cQuery	:= " SELECT *  " + CRLF
	cQuery	+= " FROM "+RetSqlName("SBM")+" (NOLOCK) SBM  " + CRLF
	cQuery	+= " WHERE SBM.D_E_L_E_T_ = '' " + CRLF 
	cQuery	+= " ORDER BY SBM.BM_GRUPO " + CRLF

	TcQuery cQuery Alias (cTab) New
	(cTab)->(DbGoTop())
	Count To nTotReg 
	(cTab)->(dbGoTop())
	nTotReg += 1
	ProcRegua(nTotReg)

	While !(cTab)->(Eof())
		nContReg++
		IncProc("Carregando Grupos - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(99,2)) + "%")	
		if ASCAN(aBiaLinSbm,{|x| x[2] == Alltrim(SX6->X6_VAR) } ) == 0 
			cMarca	:= ''
			if ';'+Alltrim((cTab)->BM_GRUPO)+';' $ Alltrim(cConteudo) .and. !empty(cConteudo) 
				cMarca	:= 'OK'
			endif
			AADD( aBiaLinSbm, { cMarca, alltrim((cTab)->BM_GRUPO),alltrim((cTab)->BM_DESC),iif((cTab)->BM_MSBLQL=='1','Sim','Não') } )  
		endif	
		(cTab)->(dbskip())
	enddo
	IncProc("Carregando Grupos - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(100,3)) + "%")	
	RestArea(aAreax)
return    


static function OrdBrowse() // ordena Browse--------------------------------------------------------
	if cCombo == aCombo[2]  
		aSort( aBiaLinSbm,,,{ |x,y| ( x[3] ) < ( y[3] ) } ) 
		if !Empty(oBrowse) 
			oBrowse:GoBottom()
			oBrowse:GoTop() 
		endif	
	else
		aSort( aBiaLinSbm,,,{ |x,y| ( x[2] ) < ( y[2] ) } ) 
		if !Empty(oBrowse) 
			oBrowse:GoBottom()
			oBrowse:GoTop() 
		endif	
	endif	
return       


static function pesqBrow() // realiza a busca da pesquisa no array e posiciona o ponteiro -------------------   
	if cCombo == aCombo[2] 
		nPos:= ASCANX(aBiaLinSbm,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[3]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)
		if nPos == 0
			oBrowse:SetFocus() 
			oBrowse:GoPosition(1) 
			nPos:= ASCANX(aBiaLinSbm,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[3]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)
		endif   
		oBrowse:SetFocus()
		if nPos > 0
			oBrowse:GoPosition(nPos) 
		endif	
	else
		nPos:= ASCANX(aBiaLinSbm,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[2]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)  
		if nPos == 0
			oBrowse:SetFocus() 
			oBrowse:GoPosition(1) 
			nPos:= ASCANX(aBiaLinSbm,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[2]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)  
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
	for nh:=1 to len(aBiaLinSbm)
		if aBiaLinSbm[nh,1] == 'OK'
			ntotmark ++
		endif
	next nh	
return ntotmark    


static function fRetParam()
	Local nk
	cBiaSmbRet := ""
	for nk:=1 to len(aBiaLinSbm)
		if aBiaLinSbm[nk,1] <> 'OK'
			loop
		endif
		cBiaSmbRet += aBiaLinSbm[nk,2]+";"
	next nk 
return	
