#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG124
@author Gabriel Rossi Mafioletti
@since 13/05/2020
@version 1.0
@description Nova Rotina de Impressão de Etiquetas
@type function
/*/

User Function BIAFG124(_cCod,_nQtd,_cPedido,_cCodImp,_cSufix,_cAlmox)

	Local aArea	:=	GetArea()

	Local _cSolicit	:=	""
	Local _cNumPc	:=	""

	Local _cAlias	:=	GetNextAlias()

	Local _cLpt		:=	""
	Local _cLocal	:=	""
	Local _cArquivo	:=	""
	Local _cCaminho	:=	""
	Local _cLocali	:=	""

	Local _cBat
	Local _cPathbat
	Local _cComando

	Local _cPrint	:=	""

	Local _cDescPrd	:=	""

	Default _cPedido	:=	""
	Default _nQtd		:=	1
	Default _cSufix		:=	""
	Default _cAlmox		:=	""

	BeginSql Alias _cALias

		%NoParser%
		SELECT *
		FROM VW_BZ_IMPRESSORAS
		WHERE CODIGO = %Exp:_cCodImp%

	EndSql

	If (_cAlias)->(!EOF())

		_cLpt	:=	"lpt"+ Alltrim(Str(Val((_cAlias)->CODIGO)+2))
		_cLocal	:=	Alltrim((_cAlias)->CAMINHO)
		_cArquivo	:=	_cLpt+"ETIQ"+_cSufix+".TMP"
		_cBat		:=	_cLpt+"ETIQ"+_cSufix+".BAT"
		If Empty(_cAlmox)
			_cAlmox		:=	(_cAlias)->ALMOXARIFADO
		EndIf

	Else

		//MsgBox("Impressora não encontrada no cadastro de impressoras.","Alerta","ERRO")
		(_cAlias)->(DbCloseArea())
		RestArea(aArea)
		Return

	EndIf

	(_cAlias)->(DbCloseArea())

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(xFilial("SB1") + _cCOd))

		//MsgBox("O codigo de produto digitado nao existe!"+CHR(13) + CHR(10)+"Verifique-o e tente novamente.","Alerta","ERRO")
		RestArea(aArea)
		Return

	EndIf

	If _nQtd < 1 .Or. _nQtd > 999

		//MsgBox("A quantidade informada deve ser de 1 a 999!","Alerta","ERRO")

		RestArea(aArea)	

		Return

	EndIf

	If !Empty(_cPedido)

		_cAlias	:=	GetNextAlias()

		BeginSql Alias _cAlias
			%NoParser%
			SELECT ISNULL(SC1.C1_YMAT ,'') C1_YMAT,
				ISNULL(SC1.C1_YMATRIC ,'') C1_YMATRIC,
				C7_NUM, C7_LOCAL
			FROM %TABLE:SC7% (NOLOCK) SC7
			LEFT JOIN %TABLE:SC1% (NOLOCK) SC1 ON C1_FILIAL = %XFILIAL:SC1%
			AND C1_NUM = C7_NUMSC
			AND C1_ITEM = C7_ITEMSC
			AND SC1.%NotDel%			
			WHERE C7_FILIAL = %XFILIAL:SC7%
			AND C7_NUM = %Exp:_cPedido%
			AND C7_PRODUTO = %Exp:_cCod%
			AND SC7.%NotDel%

		EndSql
		If (_cAlias)->(!EOF())
			_cNumPc		:=	(_cAlias)->C7_NUM
			
			_cSolicit	:=	""
			
			If !Empty((_cAlias)->C1_YMATRIC)
			
				_cSolicit	:=	fGetFunc((_cAlias)->C1_YMATRIC)
				
			ElseIf !Empty((_cAlias)->C1_YMAT)
			
				_cSolicit	:=	fGetFunc((_cAlias)->C1_YMAT)
			
			EndIf
			
			
			
			If Empty(_cAlmox)
				_cAlmox		:=	(_cAlias)->C7_LOCAL
			EndIf
		EndIf

		(_cAlias)->(DbCloseArea())

	EndIf

	_cCaminho	:=	"\\urano\Arquivos_P12\Etiquetas\" + _cArquivo
	_cPathBat	:=	"\\urano\Arquivos_P12\Etiquetas\" + _cBat

	If File(_cCaminho)
		Delete File &(_cCaminho)
	EndIf	

	If File(_cPathBat)
		Delete File &(_cPathBat)
	EndIf	

	_cPrint	:=	""
	_cPrint	+=	'I8,A,001' + CHR(13) + CHR(10)
	_cPrint	+=	CHR(13) + CHR(10)
	_cPrint	+=	CHR(13) + CHR(10)
	_cPrint	+=	'Q320,024' + CHR(13) + CHR(10)
	_cPrint	+=	'q831' + CHR(13) + CHR(10)
	_cPrint	+=	'rN' + CHR(13) + CHR(10)
	_cPrint	+=	'S5' + CHR(13) + CHR(10)
	_cPrint	+=	'D15' + CHR(13) + CHR(10)
	_cPrint	+=	'ZT' + CHR(13) + CHR(10)
	_cPrint	+=	'JF' + CHR(13) + CHR(10)
	_cPrint	+=	'O' + CHR(13) + CHR(10)
	_cPrint	+=	'R116,0' + CHR(13) + CHR(10)
	_cPrint	+=	'f100' + CHR(13) + CHR(10)
	_cPrint	+=	'N' + CHR(13) + CHR(10)
	_cPrint	+=	'A574,279,2,3,1,1,N,"Data: ' + DtoC(Date()) + '"' + CHR(13) + CHR(10)
	_cPrint	+=	'A572,223,2,3,1,1,N,"UND: ' + SB1->B1_UM + '"' + CHR(13) + CHR(10)

	_cLocali	:=	POSICIONE("ZCN",2,xFilial("ZCN")+PADR(_cCod,TamSx3("B1_COD")[1])+_cAlmox, "ZCN_LOCALI")

	_cDescPrd	:=	fRetCEsp(Alltrim(SB1->B1_DESC))

	_cPrint	+=	'A573,157,2,1,2,2,N,"LOC.: '+Alltrim(_cLocali)+'"' + CHR(13) + CHR(10)
	_cPrint	+=	'A572,116,2,2,1,1,N,"'+SUBSTR(_cDescPrd,1,42)+'"' + CHR(13) + CHR(10)
	_cPrint	+=	'A572,35,2,2,1,1,N,"PC: '+_cNumPc+'"' + CHR(13) + CHR(10)
	_cPrint	+=	'B289,297,2,1,2,6,91,B,"'+Alltrim(SB1->B1_COD)+'"' + CHR(13) + CHR(10)
	_cPrint	+=	'A412,34,2,2,1,1,N,"SOLIC: '+_cSolicit+'"' + CHR(13) + CHR(10)
	_cPrint	+=	'A572,90,2,2,1,1,N,"'+SUBSTR(_cDescPrd,43,42)+'"' + CHR(13) + CHR(10)
	_cPrint	+=	'A573,66,2,2,1,1,N,"'+SUBSTR(_cDescPrd,85,42)+'"' + CHR(13) + CHR(10)
	_cPrint	+=	'P' + Alltrim(Str(_nQtd))  + CHR(13) + CHR(10)

	MemoWrite(_cCaminho,_cPrint)

	_cComando	:=	""
	_cComando	+=	"net use "+_cLpt+" /delete" + CHR(13) + CHR(10)
	_cComando	+=	"net use "+_cLpt + " " +_cLocal + CHR(13) + CHR(10)
	_cComando	+=	"CMD /C TYPE "+ _cCaminho +" > "+ _cLpt + CHR(13) + CHR(10)

	MemoWrite(_cPathBat,_cComando)

	WaitRunSrv( "D:\PROTHEUS12\Protheus_Data\P10\Etiquetas\" + _cBat , .t. , "D:\PROTHEUS12\Protheus_Data\P10\Etiquetas" )

Return

Static Function fRetCEsp(_cTexto)

	Local _nI
	Local _cRet	:=	""

	_cTexto	:=	NoAcento(_cTexto)

	For _nI	:= 1 to Len(_cTexto)
		If IsDigit(Substr(_cTexto,_nI,1)) .Or. IsAlpha(Substr(_cTexto,_nI,1)) .Or. Substr(_cTexto,_nI,1) == " "  
			_cRet	+=	Substr(_cTexto,_nI,1)
		EndIf
	Next _nI

Return _cRet

Static Function fGetFunc(_cMat)

	Local _aArea	:=	GetArea()

	Local _cAlias	:=	GetNextAlias()

	Local _cEmpresa	:=	Alltrim(Str(Val(cEmpAnt)))
	
	Local _cSolic	:=	""
	
	_cMat	:=	Iif(Len(_cMat) == 8,Substr(_cMat,3,6),_cMat)
	
	BeginSql Alias _cAlias
	%NoParser%
	SELECT TOP 1 NOMFUN
	FROM VETORH..R034FUN
	WHERE NUMEMP = %Exp:_cEmpresa%
		AND TIPCOL = 1
		AND NUMCAD = %Exp:_cMat%
	
	EndSql

	If (_cAlias)->(!EOF())
	
		_cSolic	:=	SUBSTR((_cAlias)->NOMFUN,1,10)

	EndIf
	(_cAlias)->(DbCloseArea())
	RestArea(_aArea)
Return _cSolic