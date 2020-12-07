#include "topconn.ch"
#include "rwmake.ch"

User Function Bia906()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CSAVSCR1,CSAVCUR1,CSAVROW1,CSAVCOL1,DDTSAIDA")
SetPrvt("LOK,CDOC,CCOD,CQUERY")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ BIA906	  ³ Autor ³ Ranisses A. Corona    ³ Data ³ 02/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza campo D3_YDS (Data da Saida)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Faturamento.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

dDtSaida := CTOD("")
lOk      := .T.

do while lOk
	@ 0,0 TO 250,450 DIALOG oEntra TITLE "Dados do Movimento"
	
	cDoc    := SPACE(6)
	cCod    := SPACE(15)
	
	@ 25,10 SAY "Documento   "; @25,40 GET cDoc 	  PICT "@!R"
	@ 100,80  BUTTON "_Ok"       SIZE 30,15 ACTION fSubmit()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 		 @ 100,80  BUTTON "_Ok"       SIZE 30,15 ACTION Execute(fSubmit)
	@ 100,120 BUTTON "_Sair"  SIZE 30,15 ACTION fAborta()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 		 @ 100,120 BUTTON "_Abortar"  SIZE 30,15 ACTION Execute(fAborta)
	ACTIVATE DIALOG oEntra CENTERED
enddo
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fSubmit() ³ Autor ³ Ranisses A. Corona                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pega os dados do Documento(SD3).                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSubmit()
SD3->(DbSetOrder(2))
if !SD3->(DbSeek(xFilial("SD3")+cDoc,.T.))
	Alert("Documento nao encontrada!")
	Return
endif

if !RecLock("SD3",.F.)
	Alert("Registro em uso por outra esta‡„o! Aguarde um momento e tente novamente.")
	Return
endif

if (SD3->D3_TM) <> "509"
	Alert("Documento nao e um 509!")
	Return
endif

if Alltrim(SD3->D3_GRUPO) <> "PA"
	Alert("Documento nao e de Produto Acabado!")
	Return
endif

if !Empty(SD3->D3_YDS)
	dDtSaida := SD3->D3_YDS
	Alert("Data de Saida ja atualizada!")
endif

@0,0 TO 250,450 DIALOG oDigit TITLE "Alteracao da Data de Saida"
@015,010 SAY "Documento   "; @015,040 SAY cDoc
//@025,010 SAY "Emissao     "; @015,040 SAY cDoc
@035,010 SAY "Emissao     "   ; @035,040 GET SD3->D3_EMISSAO  Picture "@D"  Size 40,20 When Empty(SD3->D3_EMISSAO)
@065,010 SAY "Dt Saida "   ; @065,040 GET dDtSaida Size 40,20
@100,80  BUTTON "_Ok"      SIZE 30,15 ACTION fGrava()
@100,120 BUTTON "_Voltar"  SIZE 30,15 ACTION gAborta()
ACTIVATE DIALOG oDigit CENTERED



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fGrava   ³ Autor ³ Ranisses A. Corona                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava a data de saida no SD3.                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGrava()

cDoc   := SPACE(6)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a data de saida no SD3.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery  := ""
cQuery  += "UPDATE "+RetSQLName("SD3")+" "
cQuery  += "SET "
cQuery  += " D3_YDS = '"+dtos(dDtSaida)+"' "
cQuery  += "WHERE "
cQuery  += " D3_FILIAL = '"+xFilial("SD3")+"' AND "
cQuery  += " D3_DOC = '"+SD3->D3_DOC+"' AND "
cQuery  += " D_E_L_E_T_ = '' "
TCSQLExec(cQuery)

Close(oDigit)
Close(oEntra)
Return

Static Function fAborta()
lOk := .F.
Close(oEntra)
Return

Static Function gAborta()
Close(oDigit)
Close(oEntra)
Return
