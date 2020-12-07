#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"

User Function BIA703()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA703
Empresa   := Biancogres Ceramica S.A.
Data      := 07/02/13
Uso       := Estoque / Custos
Aplicação := Rotinas usadas para facilitar a contabilização do custo médio
.            Regra Original contida no LP 666-001
.            IIF(!SD3->D3_TIPO $ "PA/PI" .AND. !SD3->D3_TM $ "555/520/010" .AND. ALLTRIM(SD3->D3_DOC) <> 'ESTCRE' .AND. SUBSTR(SD3->D3_COD,1,3) <> "MOD", SD3->D3_CUSTO1, 0 )
.            Regra Original contida no LP 668-001
.            IIF(!SD3->D3_TIPO $ "PA/PI" .AND. !SD3->D3_TM $ "155/010" .AND. LEFT(SD3->D3_DOC,2) <> "OT" .AND. ALLTRIM(SD3->D3_DOC) <> 'ESTCRE' .AND. SUBSTR(SD3->D3_COD,1,3) <> "MOD", SD3->D3_CUSTO1, 0)
.            ----------+----------+----------+----------+----------+----------+----------+----------+----------+
.            Em 02/06/14 incluída a clausula a seguir: .and. !SD3->D3_CF $ "RE3/DE3", para atender à apropriação indireta de custo
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local gpCtdMov
Local gPosiAre  := GetArea()
Local idLanPad  := ParamIXB
// Necessário guardar indice e regno de todas as tabelas que eventuamente forem desposicionadas, pois apresentou problema.
Local gpIndSB1  := SB1->(IndexOrd())
Local gpRegSB1  := SB1->(Recno())
Local gpIndSC2  := SC2->(IndexOrd())
Local gpRegSC2  := SC2->(Recno())

If idLanPad == "666001"
	
	gpCtdMov := 0
	
	// O TM 720 foi incluido no filtro para tratamento dos ajustes de estoque de PI Massa e Esmalte. Este poderão ser contemplados em outro lançamento.
	If !SD3->D3_TIPO $ "PA/PP" .and. !SD3->D3_TM $ "555/520/720/710" .and. Alltrim(SD3->D3_DOC) <> 'ESTCRE' .and. Substr(SD3->D3_COD,1,3) <> "MOD" .and. !SD3->D3_CF $ "RE3/DE3"
		
		gpCtdMov := SD3->D3_CUSTO1
		
		If !Empty(SD3->D3_OP)
			SC2->(dbSetOrder(1))
			SC2->(dbSeek(xFilial("SC2")+SD3->D3_OP))
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
			If SD3->D3_TIPO == "PI" .and. SB1->B1_TIPO == "PI"
				gpCtdMov := 0
			EndIf
		EndIf
		
	EndIf
	
ElseIf idLanPad == "668001"
	
	gpCtdMov := 0
	
	// O TM 120 foi incluido no filtro para tratamento dos ajustes de estoque de PI Massa e Esmalte. Este poderão ser contemplados em outro lançamento.
	If !SD3->D3_TIPO $ "PA/PP" .and. !SD3->D3_TM $ "155/120/010" .and. Left(SD3->D3_DOC,2) <> "OT" .and. Alltrim(SD3->D3_DOC) <> 'ESTCRE' .and. SUBSTR(SD3->D3_COD,1,3) <> "MOD" .and. !SD3->D3_CF $ "RE3/DE3"
		
		gpCtdMov := SD3->D3_CUSTO1
		
		If !Empty(SD3->D3_OP)
			SC2->(dbSetOrder(1))
			SC2->(dbSeek(xFilial("SC2")+SD3->D3_OP))
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
			If SD3->D3_TIPO == "PI" .and. SB1->B1_TIPO == "PI"
				gpCtdMov := 0
			EndIf
		EndIf
		
	EndIf
	
EndIf

dbSelectArea("SB1")
dbSetOrder(gpIndSB1)
dbGoTo(gpRegSB1)

dbSelectArea("SC2")
dbSetOrder(gpIndSC2)
dbGoTo(gpRegSC2)

RestArea(gPosiAre)

Return ( gpCtdMov )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA703RSD3 ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 04/07/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Retorna Recno do SD3                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA703RSD3()

Local xfRegSd3 := Space(15) + Str(SD3->(Recno()))

Return ( xfRegSd3 )
