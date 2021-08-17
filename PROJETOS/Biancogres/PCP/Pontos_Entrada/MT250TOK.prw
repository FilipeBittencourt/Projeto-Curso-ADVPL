#Include "Protheus.ch"
#include "topconn.ch"

User Function MT250TOK()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := MT250TOK
Empresa   := Biancogres Cerâmica S/A
Data      := 14/06/12
Uso       := PCP / Estoque Custos
Aplicação := Apontamento de Produção com adicional ao que foi previsto.
.            Faz-se necessário ajustar
.            Em 22/04/14 passamos a bloquear qualquer apontamento de produção
.            cuja soma deste apontamento associado ao que já havia sido apon-
.            tado
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local gtArea  := GetArea()
Local xsRet   := .T.

// Tratamento implementado em 22/04/14, por Marcos Alberto Soprani
If ( M->D3_QUANT + SC2->C2_QUJE ) > SC2->C2_QUANT
	
	Aviso('MT250TOK (Produção A MAIOR)','O apontamento de produção que se pretende realizar somado ao que já foi apontamento é maior que a quantidade prevista para a OP em questão. Favor encerrar esta OP '+Alltrim(M->D3_OP)+ ' e firmar uma nova OP para prosseguir com os apontamentos.',{'Ok'})
	lxPrdMaior := .T.
	xsRet      := .F.
	
EndIf

// Tratamento efetuado em 29/04/14 por Marcos Alberto Soprani para atender a obrigatoriedade de baixa de UMIDADE no momento do apontamento de produção de PI-MASSA.
SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1") + M->D3_COD ))
If Alltrim(SB1->B1_GRUPO) == "PI01"
	
	jh_MesA := stod(Substr(dtos(dDataBase),1,6)+"01")-1
	jh_PriD := Substr(dtos(jh_MesA),1,6) + "01"
	jh_UltD := dtos(Ultimodia(jh_MesA))
	
	TK001 := " SELECT D4_COD,
	TK001 += "        ISNULL((SELECT SUM(Z02_UMIDAD * Z02_QTDCRG) / SUM(Z02_QTDCRG)
	TK001 += "                  FROM " + RetSqlName("Z02")
	TK001 += "                 WHERE Z02_FILIAL = '"+xFilial("Z02")+"'
	TK001 += "                   AND Z02_DATREF BETWEEN '"+jh_PriD+"' AND '"+jh_UltD+"'
	TK001 += "                   AND Z02_PRODUT = D4_COD
	TK001 += "                   AND Z02_QTDCRG <> 0
	TK001 += "                   AND Z02_ORGCLT = '2'
	TK001 += "                   AND D_E_L_E_T_ = ' '), 0) UMIDADE,
	TK001 += "        ISNULL((SELECT BZ_YUMIDAD
	TK001 += "                  FROM " + RetSqlName("SBZ")
	TK001 += "                 WHERE BZ_FILIAL = '"+xFilial("SBZ")+"'
	TK001 += "                   AND BZ_COD = D4_COD
	TK001 += "                   AND D_E_L_E_T_ = ' '), 0) UMIDAD2
	TK001 += "   FROM "+RetSqlName("SD4")+" SD4
	TK001 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"'
	TK001 += "    AND D4_OP = '"+M->D3_OP+"'
	TK001 += "    AND SD4.D_E_L_E_T_ = ' '
	TKIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TK001),'TK01',.T.,.T.)
	dbSelectArea("TK01")
	dbGoTop()
	While !Eof()
		
		xrUmidad := TK01->UMIDADE
		If xrUmidad == 0
			xrUmidad := TK01->UMIDAD2
		EndIf
		
		If xrUmidad == 0
			xsRet := .F.
			Aviso('MT250TOK','UMIDADE da MPM ' + TK01->D4_COD + ' não informada. Favor verificar!!!',{'Ok'})
		EndIf
		
		dbSelectArea("TK01")
		dbSkip()
		
	End
	
	TK01->(dbCloseArea())
	Ferase(TKIndex+GetDBExtension())
	Ferase(TKIndex+OrdBagExt())
	
EndIf

If !(SB1->B1_TIPO $ "PA#PP") .And. M->D3_LOCAL $ "02#04"
	MsgBox("Almoxarifado destino incorreto: " + M->D3_LOCAL,"A261TOK","STOP")
	zlRet := .F.			
EndIf

//  Implementado em 20/02/13 por Marcos Alberto Soprani para auxilio do fechamento de estoque vs movimentações retroativas que poderiam
// acontecer pelo fato de o parâmtro MV_ULMES necessitar permanecer em aberto até que o fechamento de estoque esteja concluído
If M->D3_EMISSAO <= GetMv("MV_YULMES")
	MsgSTOP("Impossível prosseguir, pois este movimento interfere no fechamento de custo!!! Favor verificar com a contabilidade!!!","MT250TOK")
	xsRet := .F.
EndIf


If xsRet .And. Alltrim(FunName()) == "MATA250" .And. SB1->B1_TIPO == "PI" .And. SB1->B1_GRUPO == 'PI01' .And. M->D3_LOCAL == "01" .And. Empty(M->D3_YRECURS)
	Aviso('MT250TOK','É necessário informar o campo Recurso' ,{'Ok'})
	xsRet := .F.
EndIf


RestArea(gtArea)

Return ( xsRet )
