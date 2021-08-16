#include "protheus.ch"
#Include "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

//U_TSTFIL
User Function TSTFIL()

  Local nVlrTot := 60557.60
  Local nJoker  := 0
  Local nPerc   := 15
  Local vTotal  := 0
  local cText := "0501/0113"





  RpcClearEnv()
  If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  DbSelectArea("SZO")
  X31UPDTABLE('SZO')

  //U_BIA729()
  //U_BAF022()
  //Local cEmp := "0101"
  //cEmp := "SC6"+SUBSTR(cEmp,0,1)+"0"
  //u_Env_Pedido('BJBGJO',,,'01',.T.)
  //u_FROPRT08()
  //TSTFIL001() // biaxfunc.prw  - Teste Email SEND
  //TSTFIL002() // Teste pedidos provisionados
  //TSTFIL003()
  //TSTFIL004()
  //TSTFIL005() //Montar classe de envio de email e enviando
  //TSTFIL006()
  //TSTFIL007()



RETURN


Static Function MSGTXT(cMensagem,cTitulo)

  Local oDlg
  Local oGet
  Local oBtn1
  Local lRet			:= .F.
  Private cTexto 		:= ""

  Default cTitulo := "TESTE MSG"
  Default cMensagem := ""


  //cTexto += 'BLOQUEIO POR REGRAS DE NEGÃ“CIO:' +CRLF + CRLF
  cTexto := cMensagem

  DEFINE MSDIALOG oDlg Title cTitulo From 000,000	To 350,400 Pixel

  @ 005,005 Get oGet VAR cTexto MEMO SIZE 193,150 Of oDlg Pixel READONLY
  oGet:bRClicked := {||AllwaysTrue()}

  //oBtn1     := TButton():New( 020,160,"Cancelar",oDlg,{|| oDlg:End()},040,012,,,,.T.,,"",,,,.F. )

  ACTIVATE MSDIALOG oDlg CENTER

Return lRet
//Teste Email SEND
Static Function  TSTFIL001


  Local  cErro := ""
  Local  cMail := "filipe.bittencourt@facilesistemas.com.br;fsbvieira@gmail.com"

  cErro := " <html>"
  cErro += " <body>"
  cErro += " <div style='margin:0;padding:0;background-color:#ffffff;height:100%'>"

  cErro += " <table border='0' cellpadding='0' cellspacing='0' width='100%' style='background-color:#ffffff;overflow-x:hidden'>"
  cErro += " <tbody>"
  cErro += " <tr>"
  cErro += " <td align='left'>"
  cErro += " <table align='center' border='0' cellpadding='0' cellspacing='0' style='border-collapse:collapse;overflow-x:hidden;font-family:&#39;proxima-nova&#39;,sans-serif;width:100%;max-width:560px'>"


  cErro += " <tbody>"
  cErro += " <tr>"
  cErro += " <td align='center' style='padding:10px 20px 20px 20px;font-family:&#39;proxima-nova&#39;,sans-serif'>"

  cErro += " </td>"
  cErro += " </tr>"
  cErro += " <tr>"
  cErro += " <td align='center'>"
  cErro += " <table align='center' border='0' cellpadding='0' cellspacing='0' style='overflow-x:hidden;margin:0px 20px 0px 20px;border:1px solid #ebebeb'>"


  cErro += " <tbody>"


  cErro += " <tr>"
  cErro += " <td align='center' bgcolor='#3577B0'  style='padding:30px 30px 20px 30px; font-size:50px; color:#ffffff; font-family:&#39;proxima-nova&#39;,sans-serif'>"
  cErro += " EMAIL TESTER"
  cErro += " </td>"
  cErro += " </tr>"


  cErro += " <tr>
  cErro += " <td align='left' bgcolor='#ffffff' style='padding:30px 30px 0px 30px;font-family:&#39;proxima-nova&#39;,sans-serif'>"
  cErro += " <h1 style='margin:0px;padding:0;font-size:22px;color:#333f4c;line-height:32px'>"
  cErro += " Olá, <span style='color:#3577B0'>Nome do user</span> ! Seja bem vindo.</h1>"
  cErro += " </td>"
  cErro += " </tr>"


  cErro += " <tr>"
  cErro += " <td align='left"
  cErro += " ' bgcolor='#ffffff' style='padding:15px 30px 10px 30px;font-family:&#39;proxima-nova&#39;,sans-serif'>"
  cErro += " <p style='padding:0px;color:#333f4c;margin:0;font-size:18px;line-height:28px'>"

  cErro += " Abaixo estão seus dados:"
  cErro += " <br /><br />"
  cErro += " <span style='font-weight:600;color:#3577B0'>Login: </span>Email user<br />"
  cErro += " <span style='font-weight:600;color:#3577B0'>Senha: </span>Senha <br /><br />"

  cErro += " </p>"
  cErro += " </td>"
  cErro += " </tr>"

  cErro += " <tr>"
  cErro += " <td align='center' bgcolor='#ffffff' style='padding:0px 30px 30px 30px;font-family:&#39;proxima-nova&#39;,sans-serif'>"
  cErro += " <a href='#' style= 'text-decoration: none; color: #FFF; background-color: #3577B0; border: solid #3577B0; border-width: 5px 10px; line-height: 2; font-weight: bold; text-align: center; cursor: pointer; display: inline-block; border-radius: 5px;'> Ir para o site &raquo;</a>"
  cErro += " </td>"
  cErro += " </tr>"

  cErro += " <tr>"
  cErro += " <td align='left"
  cErro += " ' bgcolor='#FAFAFA' style='padding:30px 30px 30px 30px;font-family:&#39;proxima-nova&#39;,sans-serif'>"
  cErro += " <p style='padding:0px;color:#333f4c;margin:0;font-size:14px;line-height:22px'>"
  cErro += " Recomendamos após o primeiro acesso mudar a senha."
  cErro += " </p>"
  cErro += " </td>"
  cErro += " </tr>"
  cErro += " </tbody>"
  cErro += " </table>"
  cErro += " </td>"
  cErro += " </tr> "




  cErro += " <tr>
  cErro += " <td align='left' bgcolor='#ffffff' style='padding:20px 20px 0px 20px;font-family:&#39;proxima-nova&#39;,sans-serif'>"
  cErro += " <p style='padding:0px;color:#7e8790;margin:0;font-size:14px;line-height:24px;text-align:center'>"
  cErro += " Enviado por <span style='font-weight:600;color:#3577B0'>TESTER</span>.<br /> <span style='font-weight:600;color:#3577B0'>TESTER SEND</span>"
  cErro += " </p>"
  cErro += " </td>"
  cErro += " </tr>"



  cErro += " </tbody>  "
  cErro += " </table>  "
  cErro += " </td> "
  cErro += " </tr> "
  cErro += " </tbody>  "
  cErro += " </table>  "
  cErro += " </div> "
  cErro += " </body> "
  cErro += " </html>   "




  U_BIAEnvMail(,cMail,'Error Subject',cErro)

Return

Static Function TSTFIL002()


  Local cSQL := ""
  Local cQry := GetNextAlias()
  Local cHtml := ""
  Local  cMail :=  "filipe.bittencourt@facilesistemas.com.br" //"filipe.bittencourt@facilesistemas.com.br;nadine.araujo@biancogres.com.br"
  Local lErro := .F.


  cSQL := " select   " + CRLF
  cSQL += "   'LM COMERCIO' as EMPRESA,  " + CRLF
  cSQL += "   C5_FILIAL,  " + CRLF
  cSQL += "   C5_NUM,  " + CRLF
  cSQL += "   C5_CLIENTE,  " + CRLF
  cSQL += "   C5_YPEDORI ,  " + CRLF
  cSQL += "   C5_YEMPPED AS 'REPLICADO' ,  " + CRLF
  cSQL += "   C5_YLINHA AS 'LINHA DO PRODUTO',   " + CRLF
  cSQL += "   C5_EMISSAO+' '+C5_YHORA as hora,  " + CRLF
  cSQL += "   C5_YENVIO, C5_YFORMA, C5_YCONF,  " + CRLF
  cSQL += "   C5_EMISSAO, C5_CONDPAG, C5_YCONF, C5_YAPROV, C5_YAAPROV, C5_YUSCONF, C5_YHORA, C5_YPEDORI, C5_YENVIO  " + CRLF
  cSQL += "   from SC5070  SC5 with (nolock)   " + CRLF
  cSQL += "   where 1=1   " + CRLF
  cSQL += "   AND C5_FILIAL	  IN ('01','02','03','04','05','06')  " + CRLF
  cSQL += "   AND C5_EMISSAO >= '20200101'  " + CRLF
  cSQL += "   AND D_E_L_E_T_	= ''  " + CRLF
  cSQL += "   AND C5_CONDPAG	IN ('000', '208')  " + CRLF
  cSQL += "   AND C5_TIPO		= 'N'       " + CRLF
  cSQL += "   AND C5_YCONF		= 'S'   " + CRLF
  cSQL += "   AND C5_YENVIO		= 'N'   " + CRLF
  cSQL += "   AND C5_YPEDORI	<> ''       " + CRLF
  cSQL += "   AND C5_YHORA		<> ''   " + CRLF
  cSQL += "   AND C5_NOTA		= ''        " + CRLF
  cSQL += "   AND C5_YAPROV     <> ''   " + CRLF

  cSQL += "   and not exists (SELECT E1_NUM FROM SE1070 (nolock)  " + CRLF
  cSQL += "   	where   " + CRLF
  cSQL += "   	E1_FILIAL IN ('01','02','03','04','05','06') " + CRLF
  cSQL += " 	AND E1_CLIENTE	= C5_CLIENTE   " + CRLF
  cSQL += "   	AND E1_LOJA		= C5_LOJACLI     " + CRLF
  cSQL += " 	AND E1_PREFIXO	=   'PR'+C5_YLINHA   " + CRLF
  cSQL += "   	and E1_PEDIDO = C5_NUM    	     " + CRLF
  cSQL += "   	AND D_E_L_E_T_			= '' )   " + CRLF
  cSQL += "  order by R_E_C_N_O_ DESC              " + CRLF

  TcQuery cSQL New Alias (cQry)

  cHtml := " <html>"
  cHtml += " <body>"

  cHtml += " <div style='margin:0;padding:0;background-color:#ffffff;height:100%'>"

  cHtml += " <table border='1' cellpadding='0' cellspacing='0' width='100%' style='background-color:#ffffff;overflow-x:hidden'>"
  cHtml += " <tr>"
  cHtml += " <td>EMPRESA</td>"
  cHtml += " <td>FILIAL</td>"
  cHtml += " <td>CLIENTE</td>"
  cHtml += " <td>NUM. PV</td>"
  cHtml += " <td>NUM. PV. FABRICA</td>"
  cHtml += " <td>DATA</td>"
  cHtml += " </tr>"

  While (cQry)->(!EOF())
    lErro := .T.
    cHtml += " <tr>"
    cHtml += " <td>"+(cQry)->(EMPRESA)+"</td>"
    cHtml += " <td>"+(cQry)->(C5_FILIAL)+"</td>"
    cHtml += " <td>"+(cQry)->(C5_CLIENTE)+"</td>"
    cHtml += " <td>"+(cQry)->(C5_NUM)+"</td>"
    cHtml += " <td>"+(cQry)->(C5_YPEDORI)+"</td>"
    cHtml += " <td>"+(cQry)->(hora)+"</td>"
    cHtml += " </tr>"

    (cQry)->(DBSkip())

  EndDo

  cHtml += " </table> "
  cHtml += " </div> "
  cHtml += " </body> "
  cHtml += " </html>   "

  if lErro
    U_BIAEnvMail(,cMail,'Erro Geração de Titulos de Pedidos Antecipados',cHtml)
  Endif

Return

Static Function TSTFIL003()

  Local cQuery    := ""
  Local cQry      := GetNextAlias()
  Local lRet      := .F.
  Local c5Num     := "V0339"
  Local c6Item    := "02"

  X31UPDTABLE('SC6')

  cQuery += " SELECT ZZW.ZZW_FILIAL, ZZW.ZZW_PEDIDO, ZZW.ZZW_ITEM , ZZW.ZZW_CCLI,  ZZW.ZZW_LCLI, ZZW.ZZW_CARGA " + CRLF
  cQuery += " FROM  "+RetSQLName("ZZW")+"  ZZW " + CRLF

  cQuery += " INNER JOIN "+RetSQLName("SC6")+" SC6 ON SC6.C6_FILIAL = ZZW.ZZW_FILIAL " + CRLF
  cQuery += " AND SC6.C6_NUM = ZZW.ZZW_PEDIDO " + CRLF
  cQuery += " AND SC6.C6_ITEM = ZZW.ZZW_ITEM " + CRLF
  cQuery += " AND SC6.D_E_L_E_T_ = '' " + CRLF

  cQuery += " WHERE ZZW.ZZW_FILIAL = '"+FWxFilial('SC6')+"' " + CRLF
  cQuery += " AND ZZW.ZZW_PEDIDO = '"+c5Num+"' " + CRLF
  cQuery += " AND ZZW.ZZW_ITEM = '"+c6Item+"' " + CRLF
  cQuery += " AND ZZW.D_E_L_E_T_ = '' " + CRLF

  TcQuery cQuery New Alias (cQry)


  If !EMPTY((cQry)->ZZW_PEDIDO)
    lRet := .T.
  EndIf

  (cQry)->(DbCloseArea())

  if lRet

    MSGTXT("Não será possível eliminar resíduo do pedido <b>"+c5Num+"</b>, pois o item <b>"+c6Item+"</b> se econtra  em carga.","Atenção - MT500ANT")
  EndIf

Return lRet

Static Function TSTFIL004()


  Local nX       := 1
  Local nY       := 1
  Local aArrX    := {1,2}
  Local aArrY    := {1,2,3,4,5,6,7,8,9,10}
  Local cNum := ""

  For nX := 1 TO Len(aArrX)

    For nY := Len(aArrY)  TO 1 STEP -1

      If aArrX[nX] == aArrY[nY]
        alert("Posição do aArrX = "+cValtoChar(nX))
      EndIf

    Next nY

  Next nX

Return

Static Function TSTFIL005()


  Local oServidor := TMailManager():New()
  Local oMensagem := TMailMessage():New()
  Local nErro     := 0
  Local cServidor := SubStr(GetMv("MV_RELSERV"),1,RAT(':',GetMv("MV_RELSERV"))-1)
  Local cSrvPOP	  := SubStr(GetMv("MV_YSRVPOP"),1,RAT(':',GetMv("MV_YSRVPOP"))-1)
  Local cConta 	  := GetMv("MV_YPVCTAP")
  Local cSenha   	:= GetMv("MV_YPVSNAP")
  Local cEmail 	  := GetMv("MV_YPVCTAP")
  Local lUseTLS 	:= GetMv("MV_RELTLS")
  Local lUseSSL 	:= GetMv("MV_RELSSL")
  Local lUseAUT 	:= GetMv("MV_RELAUTH")
  Local cContaRec := GetMv("MV_YPVCTAP")
  Local cSenhaRec := GetMv("MV_YPVSNAP")
  Local cPtSMTP   := Val(SubStr(GetMv("MV_RELSERV"),RAT(':',GetMv("MV_RELSERV"))+1,Len(Alltrim(GetMv("MV_RELSERV")))))
  Local cPtPOP3   := Val(SubStr(GetMv("MV_YSRVPOP"),RAT(':',GetMv("MV_YSRVPOP"))+1,Len(Alltrim(GetMv("MV_YSRVPOP")))))


  Local cNumPed   := "000001"
  Local cKeyEnc   := "Bi@nCoGrEs"
  Local cChave     := Upper(HMAC(cEmpAnt + cFilAnt + cNumPed, cKeyEnc, 1))



  oServidor:SetUseTLS(lUseTLS)
  oServidor:SetUseSSL(lUseSSL)
  oServidor:Init("",cServidor, cConta,cSenha, 0, cPtSMTP)
  oServidor:SetSmtpTimeOut(60)

  If oServidor:SmtpConnect() == 0

    If lUseAUT
      nErro := oServidor:SmtpAuth(::cConta, ::cSenha)
    EndIf

    if nErro == 0

      oMensagem:cFrom		  := cEmail
      oMensagem:cTo 		  := "filipe.bittencourt@facilesistemas.com.br"
      oMensagem:cCc 		  := ""
      oMensagem:cBcc 	  	:= ""
      oMensagem:cSubject	:= "Pedido: " + cNumPed + " TESTE  de ENVIO "
      oMensagem:cBody 		:= TSTFIL005A(cEmail,cNumPed, cChave)

      If oMensagem:Send(oServidor) == 0

        oServidor:SmtpDisconnect()

      EndIf

    Else

      ConOut( "ERRO ao autenticar: " + str(nErro,6), oServidor:GetErrorString( nErro ) )

    EndIf

  EndIf


Return

Static Function TSTFIL005A(cEmail,cNumPed, cChave)

  Local cHtml := ""
  cHtml := " <html> "
  cHtml += "    <body style='font-family: Courier, Arial, Helvetica, sans-serif;'> "
  cHtml += "       <div style='margin:0;padding:0;background-color:#fff;height:100%; '> "
  cHtml += "          <table align='center' border='0' cellpadding='0' cellspacing='0' style='overflow-x:hidden;margin:0px 20px 0px 20px;border:1px solid #ebebeb'> "
  cHtml += "             <tbody> "
  cHtml += "                <tr> "
  cHtml += "                   <td align='center' bgcolor='#919191'  style='font-size:20px; color:#ffffff; font-family: Courier, Arial, Helvetica, sans-serif;'> "
  cHtml += "                      <h1 style='margin:0px; padding:5px; letter-spacing:15px;'>BIANCOGRES</h1> "
  cHtml += " 					 <h4 style='margin:0px; padding:5px;'>Liberação de descontos</h4> "
  cHtml += "                   </td> "
  cHtml += "                </tr> "
  cHtml += "                <tr> "
  cHtml += "                   <td align='left' bgcolor='#ffffff' style='padding:30px 30px 30px 30px;font-family: Courier, Arial, Helvetica, sans-serif;'>  "
  cHtml += " 				  Olá, <b>filipe.bittencourt@facilesistemas.com.br!</b> <br> 	 "
  cHtml += " 				  Existem titulos pendendes de liberação. "
  cHtml += " 				  </td> "
  cHtml += "                </tr>		 "
  cHtml += " 			    <tr> "
  cHtml += "                   <td align='left' bgcolor='#fff' style='padding:3px;'> "
  cHtml += "                      <table align='center' style='width:100%; border-collapse: collapse;  border: 1px solid #e5e5e5;'> "
  cHtml += "                         <tbody> "
  cHtml += "                            <tr> "
  cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Empresa/Filial</th> "
  cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Cliente/Loja</th> "
  cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Titulo/Prefixo/Tipo</th> "
  cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Parcela</th> "
  cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Valor</th> "
  cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Desconto</th> "
  cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Emissão</th> "
  cHtml += "                            </tr> "
  cHtml += " 						    <tr> "
  cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>07/01</td> "
  cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'> 013181/01</td> "
  cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>013974   /1   FT </td> "  "
  cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>A</td> "
  cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>6.528,60</td> "
  cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>182,80</td> "
  cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>22/04/2021</td> "
  cHtml += "                            </tr> "
  cHtml += " 						  </tbody> "
  cHtml += " 						</table> "
  cHtml += " 					</td> "
  cHtml += " 				</tr>		 "
  cHtml += " 			    <tr> "
  cHtml += "                 <td align='center' bgcolor='#ffffff' style='padding:20px;font-family: Courier, Arial, Helvetica, sans-serif;'> 				 						 "
  cHtml += " 					<a  href='mailto:"+cEmail+"?subject=Aprovar desconto:"+cNumPed+" - ACTION:APROVAR - KEY:"+ cChave +"' style= 'width:350px; text-decoration: none; color: #FFF; background-color: #34a853; border: solid #34a853; border-width: 15px; line-height: 4; font-weight: bold; text-align: center; cursor: pointer; display: inline-block; border-radius: 5px;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; APROVAR &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a> "
  cHtml += " 					<a  href='mailto:"+cEmail+"?subject=Recusar desconto:"+cNumPed+" - ACTION:RECUSAR - KEY:"+ cChave +"' style= 'width:350px; text-decoration: none; color: #FFF; background-color: #e94235; border: solid #e94235; border-width: 15px; line-height: 4; font-weight: bold; text-align: center; cursor: pointer; display: inline-block; border-radius: 5px;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; RECUSAR &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a> "
  cHtml += " 				  </td> "
  cHtml += "              </tr>	 "
  cHtml += "              <tr> "
  cHtml += "                 <td align='center' bgcolor='#FAFAFA' style='padding:30px 30px 30px 30px;'> "
  cHtml += "                      <p style='padding:0px;color:#333f4c;margin:0;font-size:11px;line-height:22px'>                         Esta notificação foi enviada por um email configurado para não receber resposta. 						Por favor, não responda esta mensagem.                       </p> "
  cHtml += "                   </td> "
  cHtml += "              </tr>		 "
  cHtml += "             </tbody> "
  cHtml += "          </table> "
  cHtml += "       </div> "
  cHtml += "    </body> "
  cHtml += " </html> "

Return cHtml

Static Function TSTFIL006()

  Local nX       := 1
  Local aArrX    := {}

  AADD(aArrX, 'BD0433B1')
  AADD(aArrX, 'BD0433B2')
  AADD(aArrX, 'BD0433B3')

  ALERT( ASCAN(aArrX, { |x| UPPER(x) == "BD0433B3" }) )

  //if ASCAN(aArrX, { |x| UPPER(AllTrim(x)) == UPPER(AllTrim((cAliasTmp)->COD })))
Return


STATIC Function TSTFIL007()

  Local cCContabil := ""
  Local cHtml      := ""
  Local cMail :=  "filipe.bittencourt@facilesistemas.com.br"
  oContaCont := TContaContabil():New()

  aSA1Query:=array(0)
  //cSA1Filter:="A1_COD $ '014134,024757,031612,017431,024438,026585,021585,028514,025982,031203,024765,027407,027600,026574,021659,029452,031532,022480,032048'"
  cSA1Filter:="A1_COD $ '031107'"
  MsAguarde({||FilBrowse("SA1",@aSA1Query,cSA1Filter)},"Empresas","Obtendo dados no SGBD...")


  WHILE SA1->(!EOF())
    cCContabil :=  oContaCont:SetContContab("C", SA1->A1_COD, SA1->A1_LOJA, "RA")
    If EMPTY(cCContabil)
      cHtml := " <html>"
      cHtml += " <body>"
      cHtml += " Empresa: "+AllTrim(SM0->M0_NOME)+" - "+AllTrim(SM0->M0_CODIGO)+"/"+AllTrim(SM0->M0_CODFIL)+" <br />"
      cHtml += " Titulo: 0123456 , Tipo: RA <br />"
      cHtml += " Cliente: "+SA1->A1_COD+" - "+SA1->A1_LOJA+" <br />"
      cHtml += " Obs.: Conta Contábil não foi criada <br />"
      cHtml += " </body>"
      cHtml += " </html>"
      U_BIAEnvMail(,cMail,'Erro Geração de Titulos de Pedidos Antecipados (FA040GRV)',cHtml)
    EndIf
    SA1->(DBSKIP())
  END DO

Return



User Function TST999X()


  Local dNewDT  := CToD('//')

  Local dDtNCli := CToD("07/07/21")



  RpcClearEnv()
  If Select("SX6") <= 0
    //RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SX5","SF1", "SF2"})
    RpcSetEnv("01",'0'+"01"+'0001',"schedule.rh","Mudar@@123",,GetEnvServer(),{"SB1","SF1", "SF2"})
  EndIf

  dNewDT := DataValida(DaySum(dDtNCli, 7))


return dNewDT