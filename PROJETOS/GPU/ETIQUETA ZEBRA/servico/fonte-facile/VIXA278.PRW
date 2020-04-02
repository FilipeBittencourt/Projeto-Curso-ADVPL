#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "rwmake.ch"

User Function VIXA278()

	Local oObj		:= Nil

	oObj	:= TFZLeituraEtiqueta():New()
	oObj:LerEtiqueta()

	FreeObj(oObj)

Return
