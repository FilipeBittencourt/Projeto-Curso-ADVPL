#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User function FCACGA02(cProd)

cSeq := "001"

DbSelectArea("SZ4")

if SZ4->(DbSeek(xFilial("SZ4")+cProd))
	WHILE SZ4->Z4_PRODUTO == cProd
		cSeq := SZ4->Z4_SEQ
		SZ4->(DbSkip())
	EndDo
	cSeq := SOMA1(cSeq)
endif

RETURN cSeq