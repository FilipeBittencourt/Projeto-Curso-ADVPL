#include "protheus.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³BFATAPRO  ³ Autor ³ Fernando Rocha        ³ Data ³ 16.05.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³Buscar Aprovador de Pedido - baseado no 410STTS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³BIANCOGRES - NA ROTINA DE PROPOSTA DE ENGENHARIA            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BFATAPRO(cVendedor, nLinha, nTpSeg, cMarca, cCli, cLoja, cVend)
 
Local nCodApro := ""
Local wUsuario := ""
Local cAliasTmp
Local aRet

//Funcao para busca do Aprovaodor de pedido conforme regras da nova politica
//fAprov(cEmp,cTipo,nDesc,nMargem,cCli,cLoja,cVend) => M410STTS.PRW
//Retorno:
//AADD(aRet,lBloq)
//AADD(aRet,nCodAprv)
//AADD(aRet,nNomAprv)
//AADD(aRet,nNivel)
//AADD(aRet,nDescNiv)

aRet := StaticCall(M410STTS, fAprov, cMarca, "3", 0, 0, cCli, cLoja, cVend)

nCodApro := aRet[2]

//VERIFICACAO DE AUSENCIA TEMPORARIA
/*If ( nCodApro <> '')
	
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		SELECT ZM_APROTMP FROM %Table:SZM% WHERE ZM_CODAPRO = %Exp:nCodApro% AND ZM_APROTMP <> ' ' AND %NOTDEL%
	EndSql
	If !(cAliasTmp)->(Eof())
		nCodApro := (cAliasTmp)->ZM_APROTMP
	EndIf
	(cAliasTmp)->(dbCloseArea())
	
Endif*/
 
If ( nCodApro <> '')            
	psworder(1)
	pswseek(nCodApro,.t.)
	wUsuario 	:= pswret(1)[1][2] //NOME DO USUARIO
EndIf                                 

Return { nCodApro, wUsuario }
