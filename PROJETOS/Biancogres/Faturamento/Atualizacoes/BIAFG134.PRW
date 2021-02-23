#include 'protheus.ch'

/*/{Protheus.doc} BIAFG134
@author Gabriel Rossi Mafioletti
@since 23/10/2020
@version 1.0
@description Tela para controle de parâmetros de bloqueios para representantes
@type function
/*/

User Function BIAFG134()

	Private _aBfg134	:=	{;
		{"REP_BLQPED"		,"MV_PAR01"	,	'Pedidos'},;
		{"REP_BLQF6"		,"MV_PAR02"	,	'Consulta Estoque'},;
		{"REP_BLQRDISP"	,"MV_PAR03"	,	'Relatório de Disp.'},;
		{"REP_BLQREST"	,"MV_PAR04"	,	'Workflow Estoque PA'},;
		{"REP_BLQPROPENG","MV_PAR05"	,	'Proposta de engenharia'};
		}
	ValidPerg()

	If U_VALOPER('060')

		ValidPerg()

	Else
		MsgSTOP("Usuário sem permissão para acessar a rotina", "BIAFG134")
	EndIf




Return

Static Function ValidPerg()

	local lRet		:= .F.
	Local aPergs	:=	{}

	Local _nI

	For _nI	:=	1 to Len(_aBfg134)
		&(_aBfg134[_nI,2]) := U_GETBIAPAR(_aBfg134[_nI,1],.F.)

		aAdd( aPergs ,{5,_aBfg134[_nI,3]  		  	,&(_aBfg134[_nI,2]) ,100,"",	.F.})

	Next


	If ParamBox(aPergs ,"Bloqueio de Rotinas para os Representantes",,,,,,,,,.T.,.T.)

		For _nI	:=	1 to Len(_aBfg134)
			U_PUTBIAPAR(_aBfg134[_nI,1],&(_aBfg134[_nI,2]))
		Next
		MsgInfo("Parâmetros salvos com sucesso!","BIAFG134")
	EndIf
Return lRet