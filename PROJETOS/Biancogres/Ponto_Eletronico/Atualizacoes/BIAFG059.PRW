#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG059
@author Gabriel Rossi Mafioletti
@since 27/07/2018
@version 1.0
@description Tela para tratar parâmetros de Workflows
@type function
/*/

User Function BIAFG059()

	LOCAL xv_Emps
	Local _nI
	Local _aAreaSM0

	If !Validperg()
		Return
	EndIf

	_aAreaSM0 := SM0->(GetArea())

	xv_Emps    := U_BAGtEmpr("01_05")
	
	OpenSM0()
	SM0->(RestArea(_aAreaSM0))
	
	For _nI := 1 to Len(xv_Emps)

		STARTJOB("U_BFG59ALT",GetEnvServer(),.T.,xv_Emps[_nI,1],xv_Emps[_nI,2], MV_PAR01)
			
	Next

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG059" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	GetNewPar("MV_YWFPON",.T.)
	MV_PAR02 :=	GetNewPar("MV_YWFBH",.T.)
	
	aAdd( aPergs ,{5,"Workflows de Ponto Habilitados?"  		  	,MV_PAR01 ,100,"",	.F.})
	aAdd( aPergs ,{5,"Workflows de BH Habilitados?"  		  	,MV_PAR02 ,100,"",	.F.})

	If ParamBox(aPergs ,"Controle de Parâmetros",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
//		MV_PAR02 := ParamLoad(cFileName,,1,MV_PAR02)


	EndIf
	
	PutMv("MV_YWFBH",MV_PAR02)
	
Return lRet

User Function BFG59ALT(_cEmp,_cFil,_lHab)

	Local _cCont	:=	Iif(_lHab,".T.",".F.")

	RpcSetType(3)
	RpcSetEnv(_cEmp,_cFil)

	DbSelectArea("SX6")
	If !ExisteSX6("MV_YWFPON ")
		CriarSX6("MV_YWFPON", 'L', 'Indica se os Workflows de Ponto estão Ativos', _cCont )
	Else
		PutMv("MV_YWFPON",_cCont)
	EndIf
	
	RpcClearEnv()
Return

