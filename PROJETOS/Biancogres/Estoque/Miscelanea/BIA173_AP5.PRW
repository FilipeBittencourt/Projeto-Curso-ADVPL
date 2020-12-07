#include "rwmake.ch"

User Function BIA173()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Cesar Magnago
Autor(REV) := Marcos Alberto Soprani
Programa  := BIA173
Empresa   := Biancogres Ceramica S.A.
Data      := 09/09/99
Data(REV) := 18/02/13
Uso       := Estoque / Custos
Aplicação := ALTERA OS PARAMETROS DE FECHAMENTO MENSAL
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local aRetArea  := GetArea()
wOk       := .T.
nDiasEmi  := 0
nHoraExc  := 0
wSenha    := ALLTRIM( GETMV("MV_SENHA") )

If U_VALOPER("005",.T.)  //Apenas para Diretores e Gerentes
	
	While wOk
		
		@ 96,42 TO 323,505 DIALOG oEntra1 TITLE "Autorizacao p/Alterar Parametros do Fechamento de Sistema"
		@ 8,10 TO 84,222
		
		Get_Senha := SPACE(10)
		
		@ 23,14 SAY "Digite Senha Autorizada : "
		@ 23,80 Get Get_Senha PICTURE "@!" PASSWORD Object oGet
		@ 55,20 BUTTON "_Submeter" SIZE 30,15 ACTION fSubmit()
		@ 55,60 BUTTON "_Abortar"  SIZE 30,15 ACTION fAborta1()
		ACTIVATE DIALOG oEntra1 CENTERED
		wOk := .F.
		
	EndDo
	
Endif

RestArea(aRetArea)

Return

//²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
//² Funcao - fSubmit                         ²
//²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
Static FUNCTION fSubmit()

If Alltrim(wSenha) == ALLTRIM(Get_Senha)
	
	Close( oEntra1 )
	fParametros()
	wOk := .F.
	
Else
	
	Get_Senha := IIf(!Empty(Get_Senha),Space(10),Space(10))
	dlgRefresh(oEntra1)
	ObjectMethod(oGet,"SetFocus(Get_Senha)")
	ObjectMethod(oGet,"Refresh()")
	
	MsgStop("Senha INVALIDA, Favor Redigitar.....")
	
Endif

Return

//²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
//² Funcao - fAborta1                        ²
//²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
Static FUNCTION fAborta1()

wOk    := .F.
Close( oEntra1 )

Return

//²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
//² Funcao - fParametros                     ²
//²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
Static FUNCTION fParametros()

//DbSelectArea("SX6")
wOk      := .T.

While wOk
	
	//@ 0,0 TO 350,450 DIALOG oEntra TITLE "Parametros do Fechamento do Sistema"
	//@ 03,08 TO 160,175
	@ 0,0 TO 520,450 DIALOG oEntra TITLE "Parametros do Fechamento do Sistema"
	@ 08,08 TO 250,220
	
	cDataEst := GETMV("MV_YULMES")
	cDtEstX	 := cDataEst
	cDataFin := GETMV("MV_DATAFIN")
	cDataFis := GETMV("MV_DATAFIS")
	cLibera	 := GETMV("MV_YNFDUPL")
	nDiasEmi := GETMV("MV_YDIASNF")
	nHoraExc := GETMV("MV_SPEDEXC")
	nDiasDTS := GETMV("MV_YDIASDS")
	nlibFrete:= GETMV("MV_YLIBFRT")
	lChaveNfe:= GETMV("MV_CHVNFE")
	cDataRAC := GETMV("MV_YULRAC")
	
	libFreteVar := "2"
	if nlibFrete 
		libFreteVar := "1"		
	End if
	
	@  15,15 SAY "Libera NF: 1-Sim, 2-Nao"
	@  15,165 GET cLibera   SIZE 40,30 PICT "@!"
	@  35,15 SAY "Data Movimentação Estoque:  "
	@  35,165 GET cDataEst	SIZE 40,30 PICT "@D"
	@  55,15 SAY "Data Movimentação Financeiro:  "
	@  55,165 GET cDataFin	SIZE 40,30 PICT "@D"
	@  75,15 SAY "Data Movimentação Fiscal:  "
	@  75,165 GET cDataFis	SIZE 40,30 PICT "@D"
	@  95,15 SAY "Dias Emissao:  "
	@  95,165 GET nDiasEmi	SIZE 40,30 PICT "9999"
	@ 115,15 SAY "Horas Exclusão NF Saida: "
	@ 115,165 GET nHoraExc	SIZE 40,30 PICT "9999"
	@ 135,15 SAY "Dias p/ avançar DT Saida: "
	@ 135,165 GET nDiasDTS	SIZE 40,30 PICT "9999"
	@ 155,15 SAY "Liberar/Bloquear Lançamento NF Frete: 1-Libera, 2-Bloqueia"
	@ 155,165 GET libFreteVar	SIZE 40,30 PICT "@!"
	TCheckBox():New(175,15,'Validação de Chave de NFE Ativada',{||lChaveNfe},oEntra,102,13,,{|| lChaveNfe := !lChaveNfe},,,,,,.T.,,,)
	//@ 175,15 CHECKBOX oChkChave VAR lChaveNfe PROMPT "Validação de Chave de NFE Ativada" SIZE 102, 013 OF oEntra PIXEL
	@ 195,15 SAY "Data Último proc. dados GMCD/RAC:  "
	@ 195,165 GET cDataRAC	SIZE 40,30 PICT "@D"
	
	// falso bloqueia / verdadeiro libera
	
	@ 225, 80 BUTTON "_Ok"       SIZE 30,15 ACTION fGrava()
	@ 225,120 BUTTON "_Abortar"  SIZE 30,15 ACTION fAborta()
	ACTIVATE DIALOG oEntra CENTERED
	
EndDo

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±+
|                                                                             |
|                                   fGrava                                    |
|                                                                             |
+±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fGrava()

if libFreteVar == "1"
	nlibFrete := .T.		
Else
	nlibFrete := .F.
End if

PutMV("MV_YULMES" , DTOC(cDataEst) )
if cDataEst <> cDtEstX
	U_BIABC009(cDataEst, cDtEstX)
end if

PutMV("MV_DATAFIN", DTOC(cDataFin) )
PutMV("MV_DATAFIS", DTOC(cDataFis) )
PutMV("MV_YNFDUPL", cLibera )
PutMV("MV_YDIASNF", Alltrim(Str(nDiasEmi)) )
PutMV("MV_SPEDEXC", Alltrim(Str(nHoraExc)) )
PutMV("MV_YDIASDS", Alltrim(Str(nDiasDTS)) )
PutMV("MV_YLIBFRT", nlibFrete )
PutMv("MV_CHVNFE", lChaveNfe)
PutMv("MV_YULRAC", DTOC(cDataRAC) )

MsgStop("Alteracao Realizada com SUCESSO.....")
wOk    := .F.
Close(oEntra)

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±+
|                                                                             |
|                                  fAborta                                    |
|                                                                             |
+±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fAborta()

wOk    := .F.
Close( oEntra )

Return
