#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	   ³ BIA908	    ³ Autor ³ Ranisses A. Corona    | Data ³ 16/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define o valor do campo Empresa Destino (ZJ_EMPDEST)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		   ³ SigaEst														                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function BIA908()
Local cEmpresa	:= cEmpAnt
Local cCod			:= aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_COD'})]
Local cLocal		:= aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_LOCAL'})]

cEmpresa := cEmpAnt//U_EstoqueEmpresa(cCod,cLocal)

If Empty(Alltrim(cEmpresa))
			aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_QUANT'})]		:= 0
			aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_VLRTOT'})]	:= 0
			Msgbox("O produto não possui saldo no almoxarido "+cLocal+". Favor verificar!","Aviso","INFO")			
EndIf

Return(cEmpresa)