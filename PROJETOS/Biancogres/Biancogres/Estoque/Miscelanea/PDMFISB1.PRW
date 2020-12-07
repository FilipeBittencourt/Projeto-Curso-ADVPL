#include "TOTVS.CH"


User Function PDMFISB1()

	Local aRet   	:= {"",""}
	Local aPergs 	:= {}
	Local _cPMarca
	Local _cPPNum

	Local cAliasFil := "SB1"
	Local aIndex 	:= {}
	Local cFiltra

	Local cQry

	aAdd( aPergs ,{1, "Pesquisar Marca:" 		, space(50), , ".T.", ,".T.", 50, .F.})
	aAdd( aPergs ,{1, "Pesquisar Part Number:"	, space(50), , ".T.", ,".T.", 50, .F.})

	If !ParamBox(aPergs, "Parâmetros", aRet, , , , , , , , .F., .F.)
		Return
	EndIf

	_cPMarca 	:= aRet[1]
	_cPPNum		:= aRet[2]

	If !Empty(_cPMarca) .Or. !Empty(_cPPNum)

		_cLikeMar	:= "% ZD6_MARCA like '%"+AllTrim(_cPMarca)+"%' %"
		_cLikePN	:= "% ZD6_REFER like '%"+AllTrim(_cPPNum)+"%' %"

		cQry := GetNextAlias()
		BeginSql Alias cQry

			select distinct B1_COD
			from %Table:SB1% SB1
			join %Table:ZD6% ZD6 on ZD6_COD = B1_COD
			where
			SB1.D_E_L_E_T_=''
			and ZD6.D_E_L_E_T_=''
			and %Exp:_cLikeMar%
			and %Exp:_cLikePN%

		EndSql

		_cFilCod := ""

		While !(cQry)->(Eof())

			_cFilCod += (cQry)->B1_COD + "#"

			(cQry)->(DbSkip())
		EndDo

		(cQry)->(DbCloseArea())

		If !Empty(_cFilCod)

			cFiltra := "AllTrim(SB1->B1_COD) $ '"+_cFilCod+"'"


			oMBrowse:SetFilterDefault(cFiltra)
			oMBrowse:Refresh()


		Else

			MsgInfo("Filtro de Marca/Part Number sem nenhum resultado.","PDM")
			oMBrowse:SetFilterDefault("")
			oMBrowse:Refresh()

		EndIf

	Else

		oMBrowse:SetFilterDefault("")
		oMBrowse:Refresh()

	Endif

Return