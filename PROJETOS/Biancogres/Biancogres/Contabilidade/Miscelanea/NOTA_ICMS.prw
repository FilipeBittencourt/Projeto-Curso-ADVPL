#include "rwmake.ch"

/*/{Protheus.doc} nomeFunction
@description Contabilizar o GNRE
@type  Function
@author  Ranisses A. Corona 
@since 16/10/07
/*/

User Function NOTA_ICMS()

	Private LCABECALHO,CPADRAO,LPADRAO,NTOTAL,CLOTE,LDIGITA
	Private LAGLUT,CARQUIVO,AROTINA,NHDLPRV,ncont:=1,dta_aux,cult := .T.
	Private lop, dta_ini, dta_fin, inclui := .t.
	Private _ddata, _ddata2, dt_contab

	If SF2->F2_EMISSAO <= GetMv("MV_ULMES")
		//Se o Mes ja estiver fechado, contabiliza no primeiro dia posterior ao Fechamento
		dt_contab := GetMv("MV_ULMES")+1
	Else
		dt_contab := SF2->F2_EMISSAO
	EndIf

	dt_contab	:= SF2->F2_EMISSAO
	_ddata  	:= ddatabase
	_ddata2 	:= _ddata
	dta_ini 	:= SF2->F2_EMISSAO
	dta_fin 	:= SF2->F2_EMISSAO

	Processa( {|| fEntrFut() } , "SF2", "Contabilizando GNRE")

Return

Static Function fEntrFut()

	Local cFilBkp := CFILANT

	lCabecalho	:= .F.
	cPadrao 		:= "P02"
	lPadrao 		:= .F.
	nTotal  		:= 0
	clote   		:= "8820"
	lDigita 		:= .F.
	lAglut  		:= .F.
	carquivo		:= ""
	aRotina 		:= {}

	DbSelectArea("SF2")
	DbSetOrder(1)
	If DbSeek(xFilial("SF2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)

		If AllTrim(CEMPANT)+AllTrim(CFILANT) == "0701" .And. Alltrim(SF2->F2_CLIENTE) $ "000712"
			CFILANT := "05"
		EndIf

		//Alterar o conteudo da database para forcar contabilizacao
		ddatabase := dt_contab

		//Verifica o n£mero do Lote
		lPadrao := VerPadrao( cPadrao )
		If lPadrao
			If !lCabecalho
				a370Cabecalho()
			Endif
			nTotal  += DetProva(nHdlPrv,cPadrao ,"CONTABIL",cLote)
		EndIf

		//Executa Rotina de Contabilizacao
		fcont()

		ddatabase := _ddata2

		If AllTrim(CFILANT) <> cFilBkp
			CFILANT := cFilBkp
		EndIf

	End

Return

Static Function fcont()
	RodaProva(nHdlPrv,nTotal)
	If lPadrao
		cMesCtbz 	:= Left(DtoS(ddatabase),4) + "S"
		cA100Incl(cArquivo ,nHdlPrv ,3,cLote ,lDigita , lAglut  )
	End
Return

Static Function a370Cabecalho()
	nHdlPrv := HeadProva(cLote,"CONTABIL",Substr(cUserName,1,6),@cArquivo)
	lCabecalho := .T.
Return