#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

Class TGerenteAtendente From LongClassName

	Public Data cMarca
	Public Data cTpSeg
	Public Data cUF
	Public Data cVend
	Public Data cGrpCli
	Public Data cCateg
	
	Public Method New() Constructor
	Public Method Get()
	Public Method GetCliente()
	
EndClass

Method New() Class TGerenteAtendente
	
	::cMarca	:= ""
	::cTpSeg	:= ""
	::cUF		:= ""
	::cVend		:= ""
	::cGrpCli	:= ""
	::cCateg	:= ""
		
Return()

Method GetCliente(_cMarca, _Cliente, _cLoja, _cVend) Class TGerenteAtendente
	Local aArea := GetArea()
	
	oTGAResult := TGAResult():New()
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	
	If SA1->(DbSeek(xFilial("SA1") + _Cliente + _cLoja))
	//TODO Verificar ZKM 
	oTGAResult := ::Get(_cMarca, SA1->A1_YTPSEG, SA1->A1_EST, _cVend, SA1->A1_GRPVEN, SA1->A1_YCAT)
	EndIf
	
	RestArea(aArea)
Return oTGAResult


Method Get(_cMarca, _cTpSeg, _cUF, _cVend, _cGrpCli, _cCateg) Class TGerenteAtendente
	
	Local cQuery 		:= ""
	Local _cAlias		:= GetNextAlias()
	
	::cMarca	:= _cMarca
	::cTpSeg	:= _cTpSeg
	::cUF		:= _cUF
	::cVend		:= _cVend
	::cGrpCli	:= _cGrpCli
	::cCateg	:= _cCateg
	
	
	cQuery = "SELECT * FROM [dbo].[GET_ZKP] ('"+::cTpSeg+"', '"+::cMarca+"', '"+::cUF+"', '"+::cVend+"', '"+::cCateg+"', '"+::cGrpCli+"')"
	conout(cQuery)
	
	TcQuery cQuery New Alias (_cAlias)
	
	
	oTGAResult := TGAResult():New()
	
	If (!(_cAlias)->(Eof()))
		oTGAResult:cGerente		:= (_cAlias)->GERENT
		oTGAResult:cAtendente	:= (_cAlias)->ATENDE
		oTGAResult:cEmailAten	:= (_cAlias)->EMAILATEN	
	EndIf
	
	(_cAlias)->(DbCloseArea())
	
Return oTGAResult


Class TGAResult From LongClassName

	Public Data cGerente
	Public Data cAtendente
	Public Data cEmailAten

	Public Method New() Constructor
	
EndClass


Method New() Class TGAResult
	::cGerente		:= ""
	::cAtendente	:= ""
	::cEmailAten	:= ""	
Return()
