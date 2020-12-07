#include "rwmake.ch" 
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA60FIL    ³ Autor ³ WLADIMIR ILLIUSHENKO  ³ Data ³ 23/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acrescenta filtro na montagem do bordero                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FA60FIL() 
Local cFiltro := ""

do while .T.
	
	//Permite apenas o tipo "1 Cobranca Simples"	
	If PARAMIXB[4] <> "1" 
		cFiltro := "E1_SITUACA == 'X'" //PARA NAO FILTRAR NENHUM REGISTRO
		MsgBox("Somente é permitido o uso de 1 - Cobrança Simples. Favor realizar o filtro novamente.","FA60FIL","STOP")
		Return(cFiltro)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pergunta se deseja enviar somente os titulos a serem pagos em banco.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("FA60FI", .T.)
	
	cFiltro := "E1_YFORMA <> '0'"
	if MV_PAR01 == 1
		cFiltro := "E1_YFORMA == '1'"
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pergunta se deseja enviar somente os titulos a dos clientes de um ...    ³
	//³ determinado Estado, caso o usuario tenha optado por isto na primeira ... ³
	//³ pergunta.                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if MV_PAR02 == 1
		Pergunte("Y00001", .T.)
		if !MV_PAR01$'ACALAPAMBACEDFESGOMAMTMSMGPAPBPRPEPIRJRNRSRORRSCSPSETO'
			MsgBox("Unidade Federal invalida!","FA60FIL","STOP")
			Loop
		endif
		cFiltro += " .AND. E1_YUFCLI == '"+MV_PAR01+"'"
	endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtro para o prefixo do titulo                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par03 == 1 //Bianco - Linha 01               
	   cFiltro += " .AND. Alltrim(E1_PREFIXO) == 'S1'"
	ElseIf mv_par03 == 2 //Incesa - Linha 02               
	   cFiltro += " .AND. Alltrim(E1_PREFIXO) == 'S2'"
	EndIf   

	If mv_par04 == 1		// FT
		cFiltro += " .AND. Alltrim(E1_TIPO) == 'FT' "
	ElseIf mv_par04 == 2	// NF (considera as NF's e as ST's para o Estado do ES a partir de 10/05/13 
		cFiltro += " .AND. Alltrim(E1_TIPO) == 'NF' .AND. !Alltrim(E1_YCLASSE) $ '1_2' " //Considera as NF, exceto com as Classes de ST e BOL  //desativado em 10/05/13
		//cFiltro += " .AND. ( Alltrim(E1_TIPO) == 'NF' .OR. ( Alltrim(E1_YUFCLI) == 'ES' .AND. Alltrim(E1_YCLASSE) == '1') ) .AND. Alltrim(E1_YCLASSE) <> '2' " //ativado em 10/05/13
	ElseIf mv_par04 == 3	// ST
        cFiltro += " .AND. Alltrim(E1_YCLASSE) == '1' " //Filtra apenas os Titulos de ST
	ElseIf mv_par04 == 4	// BOL
        cFiltro += " .AND. Alltrim(E1_YCLASSE) == '2' " //Filtra apenas os Titulos de tipo = BOL / pre = CT 	        
	ElseIf mv_par04 == 5	// RA (considera os recebimentos antecipados gerados por pedido
		cFiltro += " .AND. Alltrim(E1_YCLASSE) == '6' " //Filtra apenas os Titulos de RA com Boletos
	EndIf

	//Caso o parametro esteja preenchido, fitra clientes aleatoriamente. //OS 1909-12
	If !Empty(Alltrim(MV_PAR06))
        cFiltro += " .AND. E1_CLIENTE $ '"+Alltrim(MV_PAR06)+"' " 
	EndIf

	exit
enddo
Return(cFiltro)