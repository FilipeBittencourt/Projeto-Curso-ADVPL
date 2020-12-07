#Include "TOTVS.CH"
#Include "Protheus.CH"
#Include "TOPCONN.CH"

Class TTicket From LongClassName
	
	//atributos publico
	Data cEmp		as character
	Data cFil		as character
	Data c	
	//metodos publicos	
	Method New() Constructor
	Method Tela()
	
EndClass

Method New () Class TTicket

Return

Method Tela() Class TTicket

Local oDlg 		:= Nil
Local nAltLinha	:= 23
Local nLinha	:= 0

oDlg := MSDialog():New(178,181,650,810,'....: Pesagem de Veículos :....',,,,,CLR_BLACK,CLR_WHITE,,,.T.)

oGroup1:= TGroup():New(02,02, 2*nAltLinha, 313,'',oDlg,,,.T.)


oTSay1 := TSay():New( 4, 10, {|| "Quanto a Mercadoria?"} , oGroup1,,,,,,.T.,,, 60, 12,,,,,,,,.T. )
oTSay1 := TSay():New( 4, 93, {|| "Seqüêncial"} , oGroup1,,,,,,.T.,,, 60, 12,,,,,,,,.T. )
oTSay1 := TSay():New( 4, 165, {|| "Data Cadastro"} , oGroup1,,,,,,.T.,,, 60, 12,,,,,,,,.T. )

cTGet1 := ""

oTGet1 := TGet():New( 10, 10,{||cTGet1},oGroup1, 100,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet1,,,,)
oTGet2 := TGet():New( 10, 93,{||cTGet1},oGroup1, 100,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet1,,,,)
oTGet3 := TGet():New( 10, 165,{||cTGet1},oGroup1, 100,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet1,,,,)
 

//@ C(004),C(010) Say "Quanto a Mercadoria?" Size C(055),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
//@ C(004),C(093) Say "Seqüêncial"           Size C(028),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV
//@ C(004),C(165) Say "Data Cadastro:"       Size C(035),C(008) COLOR CLR_BLACK PIXEL OF _oDlgPV

 
// USANDO CREATE
//oGroup2 := TGroup():Create(oDlg,02,140,130,260,'Objeto TGroup 2',,,.T.)
 
//cTGet4 := "Get dentro do TGroup"
//oTGet5 := TGet():New( 18,150,{||cTGet4},oGroup2,100,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet4,,,,)
//oTGet6 := TGet():New( 36,150,{||cTGet4},oGroup2,100,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet4,,,,)


oDlg:Activate(,,,.T.,{|| },,{||} )

Return