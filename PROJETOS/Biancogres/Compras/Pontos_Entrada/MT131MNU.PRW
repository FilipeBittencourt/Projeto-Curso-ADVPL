#include "protheus.ch"
#include "apwebex.ch"

                                           
user function MT131MNU
	aadd(aRotina, {"Portal WebSC","U_A130WEB",0,6,0,nil})
	//aadd(aRotina, {"Env.Mensagem","U_A130MSG",0,7,0,nil})
return 

user function A130WEB
	local cComando := ""
	local cUserCode:= __cUserId
	
	if isInCallStack("MATA121")
		posicione("SC1",1,xFilial("SC1")+GdFieldGet("C7_NUMSC",n)+GdFieldGet("C7_ITEMSC",n),"found()")
	endif
	
	if posicione("SY1",3,xFilial("SY1")+cUserCode,"found()")
		//cComando := "http://192.168.20.7:8686/websc/u_viewitem.apw?codcom="+SY1->Y1_COD+"&emp="+cEmpAnt+"&fil="+cFilAnt+"&obj="+cValToChar(SC1->(recno()))
		//cComando := "http://srv_web_protheus:8686/websc/u_viewitem.apw?codcom="+SY1->Y1_COD+"&emp="+cEmpAnt+"&fil="+cFilAnt+"&obj="+cValToChar(SC1->(recno()))
		
		If !Empty(SC1->C1_YBIZAGI)
			cComando := "http://ares/AnexosSC/anexos.aspx?NUMSC="+SC1->C1_NUM+"&NUMITEM="+SC1->C1_ITEM+"&EMP="+cEmpAnt+"01"
		Else
			cComando := "http://srv_web_protheus:6969/ws02/u_viewitem.apw?codcom="+SY1->Y1_COD+"&emp="+cEmpAnt+"&fil="+cFilAnt+"&obj="+cValToChar(SC1->(recno()))
		EndIf
		
		ShellExecute("open",cComando,"","",4)
	else
		MsgInfo("Apenas compradores podem usar esta opção.")
	endif
	//aCpoRet[1] := "X"
return .T.

user function viewitem
	local cHTML    := ""
	local cEmp     := httpget->emp
	local cFil     := httpget->fil
	local nRegId   := httpget->obj
	local cCodCom  := httpget->codcom
	
	SetupHeader()
	
	private nRegId    := val(nRegId)
	private cNomeUser := Alltrim(upper(posicione("SY1",1,xFilial("SY1")+cCodCom,"Y1_NOME")))
	private cUserId   := SY1->Y1_USER	

	SC1->(dbgoto(nRegId))
	
	if SC1->(eof())
		return redirpage("http://www.biancogres.com.br")
	endif
	
	web extended init cHTML
		cHTML := execinpage("view_item")
	web extended end
	rpcclearenv()
	
return cHTML

static function SetupHeader
	local cEmp := httpget->emp
	local cFil := httpget->fil
	
	HttpHeadOut->Content_Type   := "text/html; charset=ISO-8859-1"
	HttpHeadOut->Expires 		:= "Mon, 26 Jul 1997 05:00:00 GMT "
	HttpHeadOut->Last_Modified 	:= TransData()
	HttpHeadOut->Cache_Control 	:= "no-store, no-cache, must-revalidate, post-check=0, pre-check=0;"
	HttpHeadOut->pragma 		:= "no-cache"

	rpcclearenv()
	rpcsettype(3)
	wfprepenv(cEmp,cFil)
return

static function TransData()
	cData := DToC( Date() )
	cHora := AllTrim( Str( Val( Substr( Time(), 1, 2 ) ) - 3 ) ) + ":" + Substr( Time(), 4, 2 ) + ":" + Substr( Time(), 7, 2 )
	nDiaSem := Dow( CToD( cData ) )
	cDiaSem := ""
	
	cDia := Substr( cData, 1, 2 )
	cMes := Substr( cData, 4, 2 )
	cAno := Substr( cData, 7, 4 )
	
	Do Case
		Case cMes == "01"
			cMes := "Jan"
		Case cMes == "02"
			cMes := "Feb"
		Case cMes == "03"
			cMes := "Mar"
		Case cMes == "04"
			cMes := "Apr"
		Case cMes == "05"
			cMes := "May"
		Case cMes == "06"
			cMes := "Jun"
		Case cMes == "07"
			cMes := "Jul"
		Case cMes == "08"
			cMes := "Aug"
		Case cMes == "09"
			cMes := "Sep"
		Case cMes == "10"
			cMes := "Oct"
		Case cMes == "11"
			cMes := "Nov"
		Case cMes == "12"
			cMes := "Dec"
	EndCase
	
	Do Case
		Case nDiaSem == 1
			cDiaSem := "Sun"
		Case nDiaSem == 2
			cDiaSem := "Mon"
		Case nDiaSem == 3
			cDiaSem := "Tue"
		Case nDiaSem == 4
			cDiaSem := "Wed"
		Case nDiaSem == 5
			cDiaSem := "Thu"
		Case nDiaSem == 6
			cDiaSem := "Fri"
		Case nDiaSem == 7
			cDiaSem := "Sat"
	EndCase		
	
	cData := cDiaSem + ", " + cDia + " " + cMes + " " + cAno + " " + cHora + " GMT"	
Return cData