#include "rwmake.ch"

User Function BIA930() 

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ BIA930	  ³ Autor ³ Gustav Koblinger Jr   ³ Data ³ 28/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Contabilizar o ICMS Autonomo                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Faturamento.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Private LCABECALHO,CPADRAO,LPADRAO,NTOTAL,CLOTE,LDIGITA
Private LAGLUT,CARQUIVO,AROTINA,NHDLPRV,ncont:=1,dta_aux,cult := .T.
Private cfiltro
Private lop, dta_ini, dta_fin, inclui := .t.
Private _ddata, _ddata2, dt_contab

If SF2->F2_EMISSAO <= GetMv("MV_ULMES") 
	//Se o Mes ja estiver fechado, contabiliza no primeiro dia posterior ao Fechamento
	dt_contab := GetMv("MV_ULMES")+1 
Else
	dt_contab := SF2->F2_EMISSAO
EndIf

_ddata  := ddatabase
_ddata2 := _ddata  

dta_ini := SF2->F2_EMISSAO
dta_fin := SF2->F2_EMISSAO

Processa( {|| fEntrFut() } , "SF2", "Contabilizando ICMS Frete Autonomo")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Funcao    := fEntrFut
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function fEntrFut()

Private LCABECALHO,CPADRAO,LPADRAO,NTOTAL,CLOTE,LDIGITA
Private LAGLUT,CARQUIVO,AROTINA,NHDLPRV,ncont:=1,dta_aux,cult := .T.

lCabecalho	:= .F.
cPadrao 	:= "P01"
lPadrao 	:= .F.
nTotal  	:= 0
clote   	:= "8820"
lDigita 	:= .T.
lAglut  	:= .F.
carquivo	:= ""
aRotina 	:= {}

cfiltro  := "@F2_EMISSAO >= '"+DTOS(dta_ini)+"' "
cfiltro  += " AND F2_FILIAL = '"+xFilial("SF2")+"' "
cfiltro  += " AND F2_EMISSAO <= '"+DTOS(dta_fin)+"' "
cfiltro  += " AND F2_DOC = '"+SF2->F2_DOC+"' "
cfiltro  += " AND F2_SERIE = '"+SF2->F2_SERIE+"' "
cfiltro  += " AND F2_CLIENTE = '"+SF2->F2_CLIENTE+"' "
cfiltro  += " AND F2_LOJA = '"+SF2->F2_LOJA+"' "
cfiltro  += " AND D_E_L_E_T_ = '' "
DbSelectArea("SF2")
DbSetOrder(1)
Set Filter to &(cfiltro)
DbGotop()

dta_aux := SF2->F2_EMISSAO
While !Eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alterar o conteudo da database para forcar contabilizacao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ddatabase := dt_contab
	//ddatabase := SF2->F2_EMISSAO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o n£mero do Lote                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lPadrao := VerPadrao( cPadrao )
	If lPadrao
		If !lCabecalho
			a370Cabecalho(@nHdlPrv,@cArquivo)
		Endif
		nTotal  := nTotal + DetProva(nHdlPrv,cPadrao ,"CONTABIL",cLote)
		cult := .F.
/*		dbSelectArea("SF2")
		If Empty(SF2->F2_DTLANC)
			Reclock("SF2",.F.)
			SF2->F2_DTLANC := dDataBase
			MsUnlock()
		End*/
	EndIf
	dbSelectArea("SF2")
	dbSetOrder(1)
	dbSkip()
End

If cult == .F.
	fcont()
EndIf

ddatabase := _ddata2
Set filter to

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Funcao := fcont
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function fcont()
If lCabecalho
	RodaProva(nHdlPrv,nTotal)
Endif
If lPadrao
	cMesCtbz 	:= Left(DtoS(ddatabase),4) + "S"
	cA100Incl(cArquivo ,nHdlPrv ,3,cLote ,lDigita , lAglut  )
   	//PutSx5(StrZero(Month(ddatabase),2),cMesCtbz)         	
	//FCLOSE(nHdlPrv)
End
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Funcao := A370Cab
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function a370Cabecalho()
nHdlPrv := HeadProva(cLote,"CONTABIL",Substr(cUserName,1,6),@cArquivo)
lCabecalho := .T.
Return
