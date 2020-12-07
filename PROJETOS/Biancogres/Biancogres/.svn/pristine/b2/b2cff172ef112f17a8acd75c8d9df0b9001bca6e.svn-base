#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TBiaLogProc
@author Artur Antunes
@since 10/03/2017
@version 1.0
@description Classe Generica para gravação de Log de processamento
@obs OS: 0782-17
@type Class
/*/

Class TBiaLogProc from LongClassName

	Data nRecProc
	Data nSecStart
	
	Method New() Constructor
	Method LogIniProc(_cRotina,_cPerg,_aParam)  // Inicio do processo               
	Method LogFimProc() 			  			// Fim do processo        

EndClass


Method New() CLASS TBiaLogProc
	::nRecProc  := 0
	::nSecStart := 0
Return


Method LogIniProc(_cRotina,_cPerg,_aParam) Class TBiaLogProc
  
local cAlias	 := 'Z06' 
local nc		 := 0
local cParam	 := ''
local cTime		 := ''
local aPergs	 := {}
local nRecTemp	 := 0
default _cRotina := ''
default _aParam	 := {}
default _cPerg	 := ''

if !empty(_cPerg)
	dbSelectArea("SX1")
	nRecTemp := Recno()
	SX1->(dbSetOrder(1))
	SX1->(dbgotop())
	if SX1->(dbseek(PadR(_cPerg,10)))
		While !SX1->(EOF()) .and. SX1->X1_GRUPO == PadR(_cPerg,10)
			AADD(aPergs,&(SX1->X1_VAR01))
			SX1->(dbSkip())
		end
	endif	
	SX1->(dbgoto(nRecTemp))
endif

if !empty(_cRotina)
	cTime := TIME()
	::nSecStart := Seconds()
	
	DbSelectArea(cAlias)
	(cAlias)->(RecLock(cAlias,.T.))
	
    (cAlias)->Z06_FILIAL := xFilial(cAlias) 
    (cAlias)->Z06_EMPFIL := cEmpAnt + cFilAnt
    (cAlias)->Z06_ROTINA := _cRotina
    (cAlias)->Z06_USER 	 := UsrRetName(RetCodUsr())
    (cAlias)->Z06_DTINI  := Date()
    (cAlias)->Z06_HRINI  := cTime
    (cAlias)->Z06_DTPSIS := iif(Type("dDataBase") == "D",iif(!empty(dDataBase),dDataBase,Date()),Date())  
    if !empty(aPergs)
	    for nc := 1 to len(aPergs)
	    	cParam	+= 'Parametro '+ StrZero(nc,2) + ': ' + Alltrim(cValtoChar(aPergs[nc])) + CRLF
	    next nc	
	endif    
    if !empty(_aParam)
	    for nc := 1 to len(_aParam)
	    	cParam	+= 'Parametro '+ StrZero(nc,2) + ': ' + Alltrim(cValtoChar(_aParam[nc])) + CRLF
	    next nc	
	endif    
    (cAlias)->Z06_PARAM  := cParam
    
	(cAlias)->(MsUnLock())
	
	::nRecProc := (cAlias)->(Recno())
endif
return


Method LogFimProc() Class TBiaLogProc

local cAlias    := 'Z06' 
local nDias	    := 0
local nTempSec  := 0
local cTempo    := ''
local nx	    := 0
local nHoraSec	:= 3600
local nHoras    := 0
local nMinutos  := 0
local nSegundos := 0
local cHoraFim	:= ''

DbSelectArea(cAlias)

if ::nRecProc > 0
	(cAlias)->(DbGoTo(::nRecProc))
	if ! (cAlias)->(Eof())
		
		nDias  := DateDiffDay((cAlias)->Z06_DTINI,DATE()) + 1
		for nx := 1 to nDias
			if nx == nDias
				cHoraFim := Time()
				nTempSec += Seconds() 
				nTempSec -= ::nSecStart  
			else
				nTempSec += 86399 // um dia 
			endif
		next nx
		nTempSec := Int(nTempSec)
		
		nHoras    := Int(nTempSec/nHoraSec) //resultado das horas
		nMinutos  := Int(( nTempSec - ( nHoraSec * nHoras ) ) / 60) //resultado dos minutos
		nSegundos := (nTempSec - ( nHoraSec * nHoras ) - ( nMinutos * 60 ) )
 
		cTempo := StrZero(nHoras,iif(nHoras > 99,3,2)) + ":" + StrZero(nMinutos,2) + ":" + StrZero(nSegundos,2)
	
		(cAlias)->(RecLock(cAlias,.F.))
	    (cAlias)->Z06_DTFIM	 := DATE()
	    (cAlias)->Z06_HRFIM  := cHoraFim
	    (cAlias)->Z06_TEMPEX := cTempo
		(cAlias)->(MsUnLock())
	endif
endif
return
