#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} XPROXNUM
@author Wlysses Cerqueira (Facile)
@since 11/02/2020
@Ticket 21607 - Devido duplicidades do numseq pelo padrão,
estamos customizando o numseq para controle via tabela.
@version 1.0
@description
@type function
/*/

User Function XPROXNUM()

	Local aArea			:=GetArea()
	Local cEmp_			:= cEmpAnt
	Local cFil_
	Local cSp

	Local nTam			:= TamSx3("D3_NUMSEQ")[1]
	Local cProxNum		:= Replicate("0",nTam)

	cProxNum	:= Subs(GetMV("MV_DOCSEQ"),1,nTam)
	cFil_		:= If(Empty(SX6->X6_FIL), Space(Len(SX6->X6_FIL)), cFilAnt) // MV_DOCSEQ ja esta posicionado

	cSp := "SP_BIAPROXNUM"
	IF TCSPEXIST(cSp)

		CONOUT("[Emp: "+cEmp_+" Fil: "+cFil_+" "+DTOC(Date())+" "+Time()+"] XPROXNUM >>> SP_BIAPROXNUM","XPROXNUM")
		cProxNum := ProxNumSP(cSp, cEmp_, cFil_, cProxNum)

	ENDIF

	IF !TCSPEXIST(cSp) .Or. Empty(cProxNum)

		CONOUT("[Emp: "+cEmp_+" Fil: "+cFil_+" "+DTOC(Date())+" "+Time()+"] XPROXNUM >>> SX6/ZL7","XPROXNUM")

		cProxNum := Soma1(cProxNum)

		While !SoftLock("ZL7")
			Sleep(100)
			loop
		EndDo

		While !RecLock("ZL7", .F.) // Garante lock
			Sleep(100)
			loop
		EndDo

		If ( Soma1(ZL7->ZL7_DOCSEQ) > cProxNum  )

			cProxNum := Soma1(ZL7->ZL7_DOCSEQ)

		EndIf

		ZL7->ZL7_DOCSEQ	:= cProxNum
		PutMV("MV_DOCSEQ", cProxNum)

		ZL7->(MSUnLock())

		CONOUT("[Emp: "+cEmp_+" Fil: "+cFil_+" "+DTOC(Date())+" "+Time()+"] XPROXNUM >>> RETORNO SX6/ZL7 OK - Numero Gerado: "+cProxNum,"XPROXNUM")

	END

	RestArea(aArea)
Return(cProxNum)


Static Function ProxNumSP(cSp, cEmp_, cFil_, cProxNum)

	Local aRetSp

	aRetSp := TCSPEXEC(cSp, AllTrim(cEmp_), AllTrim(cFil_), cProxNum)
	If VALTYPE(aRetSp) == "A" .And. Len(aRetSp) > 0

		cProxNum := aRetSp[1]

		If Empty(aRetSp[1])

			CONOUT("FPROXNUM [ERRO] >>> Ocorreu problema na geração de DOCSEQ via SP. [VAZIO] >>> "+aRetSp[2],"FPROXNUM")
			cProxNum := ""

		else

			PutMV("MV_DOCSEQ", cProxNum)
			CONOUT("[Emp: "+cEmp_+" Fil: "+cFil_+" "+DTOC(Date())+" "+Time()+"] FPROXNUM >>> RETORNO SP OK - Numero Gerado: "+cProxNum,"FPROXNUM")

		EndIf
	else
		CONOUT("FPROXNUM [ERRO] >>> Ocorreu problema na geração de DOCSEQ via SP. [VALTYPE] >>> "+aRetSp[2],"FPROXNUM")
		cProxNum := ""
	EndIf

Return(cProxNum)