#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA904   ³ Autor ³ Ranisses A. Corona    ³ Data ³ 27/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a Quant. e maior que o saldo                   |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExecBlock                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Codigo do Produto                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BIA904() 

wCOD		 := aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_COD'})]  
wUM 		 := aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_UM'})]
wQUANT	 := aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_QUANT'})]
wLOCAL	 := aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_LOCAL'})]
wEMPDEST := aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_EMPDEST'})]
wLocal	 := Gdfieldget("ZJ_LOCAL",n)

GdFieldPut("ZJ_QTAPROV",0,n) //Sempre Zera Quantidade aprovada

//Se o campo Empresa Destino estiver vazio, zera a quantidade
If Empty(Alltrim(wEMPDEST))
		Msgbox("O campo Empresa Destino está vazio. Favor verificar o Produto e Almoxarifado!","Aviso","INFO")
		wQUANT := 0
 		Return(wQUANT)
EndIf

//Se o Almoxarifado estiver vazio, zera a quantidade
If Empty(Alltrim(wLocal))
		Msgbox("O campo Almoxarifado está vazio. Favor verificar o Produto e Almoxarifado!","Aviso","INFO")
		wQUANT := 0
 		Return(wQUANT)
EndIf

//Localiza a Reserva do Produto
cAliasTmp := GetNextAlias()
If wEMPDEST == "01"
	BeginSql Alias cAliasTmp
		SELECT * FROM SB2010 SB2 WHERE B2_COD = %Exp:wCOD% AND B2_LOCAL = %Exp:wLOCAL% AND %NOTDEL%
	EndSql
ElseIf wEMPDEST == "05"
	BeginSql Alias cAliasTmp
		SELECT * FROM SB2050 SB2 WHERE B2_COD = %Exp:wCOD% AND B2_LOCAL = %Exp:wLOCAL% AND %NOTDEL%
	EndSql
ElseIf wEMPDEST == "14"
	BeginSql Alias cAliasTmp
		SELECT * FROM SB2140 SB2 WHERE B2_COD = %Exp:wCOD% AND B2_LOCAL = %Exp:wLOCAL% AND %NOTDEL%
	EndSql
EndIf

//Calcula o Saldo do Produto por Empresa
If cEmpAnt == wEMPDEST
	//Funcao para calcular o saldo do produto
	aSaldos := CalcEst((cAliasTmp)->B2_COD,(cAliasTmp)->B2_LOCAL,ddatabase+1) //Somado +1 na database, para dar o saldo do dia corrente
Else
  //Armazena a Empresa Original
	cEmpOri := cEmpAnt
	//Altera a "Empresa Original" para "Empresa Destino" - CUIDADO
	cEmpAnt := wEMPDEST
	//Funcao para calcular o saldo do produto
	aSaldos := CalcEst((cAliasTmp)->B2_COD,(cAliasTmp)->B2_LOCAL,ddatabase+1) //Somado +1 na database, para dar o saldo do dia corrente
	//Volta a "Empresa Original" - CUIDADO
	cEmpAnt := cEmpOri
EndIf
	
wSALDO := aSaldos[1] - (cAliasTmp)->B2_RESERVA

DbSelectArea("SBZ")
SBZ->(DbSetOrder(1))
SBZ->(DbSeek(xFilial("SBZ")+wCOD))

/*
DbSelectArea("ZCN")
ZCN->(DbSetOrder(1))
If ZCN->(DbSeek(xFilial("ZCN")+wCod+"2"+wLocal)) .And. ZCN->(DbSeek(xFilial("ZCN")+wCod+"1")) .And. ZCN->ZCN_POLIT $ '1_8' .And. Substr(wcod,1,3) >= '200' .And.  Substr(wcod,1,3) <= '220' //Local Secundário sempre permitirá estoque negativo de requisição
	Do Case
		Case wQuant <= wSaldo
			GdFieldPut("ZJ_QTAPROV",wQuant,n)
		Case wQuant > wSaldo .And. wSaldo > 0
			GdFieldPut("ZJ_QTAPROV",wSaldo,n)
		OtherWise
			GdFieldPut("ZJ_QTAPROV",0,n)
	EndCase
	(cAliasTmp)->(dbCloseArea())
	Return wQuant
EndIf
*/
If wQUANT > wSALDO
	Msgbox("O saldo deste produto é de "+Alltrim(Str(wSALDO))+" "+wUM,"Aviso","INFO")
	aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_VLRTOT'})] := 0
	wQUANT := 0
Else
	GdFieldPut("ZJ_QTAPROV",wQuant,n)
EndIf

(cAliasTmp)->(dbCloseArea())

Return(wQUANT)