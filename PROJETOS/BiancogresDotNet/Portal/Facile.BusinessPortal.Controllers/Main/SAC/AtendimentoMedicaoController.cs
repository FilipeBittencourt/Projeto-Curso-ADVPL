using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using System.Linq;
using System;
using Facile.BusinessPortal.Model;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using Facile.BusinessPortal.BusinessRules.DAO;
using System.Threading.Tasks;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Util;
using Microsoft.AspNetCore.Mvc.Rendering;
using Facile.BusinessPortal.BusinessRules.ResquestToPay.Atendimento;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("SAC")]
    public class AtendimentoMedicaoController : BaseCommonController<AtendimentoMedicao>
    {
        public AtendimentoMedicaoController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }

        public async Task<IActionResult> SalvarStatus(long Id, int Status, string Observacao)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                //  if (usuario.Tipo == TipoUsuario.Fornecedor)
                //  {
                //TUDO valida se do fornecedor logado
                try {
                    var Atendimento = _context.Atendimento.FirstOrDefault(
                       o => o.ID == Id &&
                       o.EmpresaID == usuario.EmpresaID
                    );

                    if (Atendimento == null)
                    {
                        return Json(new { Ok = false, Mensagem = "Id Informado não encontrado." });
                    }
                    else
                    {
                        if (Atendimento.Status == StatusAtendimento.Concluido)
                        {
                            AtendimentoHistorico atendimentoHistorico = new AtendimentoHistorico();
                            atendimentoHistorico.EmpresaID = _empresaId;
                            atendimentoHistorico.UsuarioID = usuario.ID;
                            atendimentoHistorico.DataEvento = DateTime.Now;
                            atendimentoHistorico.EmpresaID = _empresaId;
                            atendimentoHistorico.Observacao = Observacao;
                            atendimentoHistorico.Status = Atendimento.Status;
                            atendimentoHistorico.AtendimentoID = Id;
                            _context.Add<AtendimentoHistorico>(atendimentoHistorico);


                            Atendimento.Status = (Status == 1) ? StatusAtendimento.Aprovada : StatusAtendimento.Aguardando;
                            Atendimento.DataMedicao = DateTime.Now;
                            Atendimento.UsuarioID = usuario.ID;
                            Atendimento.ObservacaoMedicao = Observacao;
                            _context.Entry(Atendimento).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                            await _context.SaveChangesAsync();

                            if (Status == 1)
                            {
                                var ResultMail = AtendimentoMail.AtendimentoAprovadoSendMail(_context, Atendimento.ID);
                                if (!ResultMail.Status)
                                {
                                    return Json(new { Ok = false, Mensagem = "Erro envio do e-mail." });
                                }
                            } else
                            {
                                var ResultMail = AtendimentoMail.AtendimentoReprovadoSendMail(_context, Atendimento.ID);
                                if (!ResultMail.Status)
                                {
                                    return Json(new { Ok = false, Mensagem = "Erro envio do e-mail." });
                                }
                            }
                            

                            return Json(new { Ok = true, Mensagem = "" });
                        }
                        return Json(new { Ok = false, Mensagem = "Atendimento não esta com Status 'Aguardando Serviço'." });
                    }
                } catch(Exception ex)
                {
                    return Json(new { Ok = false, Mensagem = "Erro interno: "+ex.Message });
                 }
                

                //  }
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }

        public IActionResult DataTable()
        {
            var draw = Request.Form["draw"].FirstOrDefault();
            var start = Request.Form["start"].FirstOrDefault();
            var length = Request.Form["length"].FirstOrDefault();
            var sortColumn = Request.Form["order[0][column]"].FirstOrDefault();
            var sortColumnDir = Request.Form["order[0][dir]"].FirstOrDefault();
            var searchValue = Request.Form["search[value]"].FirstOrDefault();
            var fieldSearch = Request.Form["FieldSearch"].FirstOrDefault();


            int pageSize = length != null ? Convert.ToInt32(length) : 0;
            int skip = start != null ? Convert.ToInt32(start) : 0;
            int orderby = sortColumn != null ? Convert.ToInt32(sortColumn) + 1 : 1;

            int recordsTotal = 0;
            int recordsFiltered = 0;
            string query = "";
            List<dynamic> data = new List<dynamic>();

            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);

            string queryFiltroUsuario = "";
            if (usuario.Tipo == TipoUsuario.Fornecedor)
            {
                queryFiltroUsuario = " AND 1 = 1 ";
            }

            using (var command = _context.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    _context.Database.OpenConnection();
                    //total de registro
                    query = @"select COUNT(*)
                                from Atendimento
                                JOIN Unidade ON Unidade.ID = Atendimento.UnidadeId
                                JOIN Fornecedor ON Fornecedor.ID = Atendimento.FornecedorID ";
                    query += @" where Atendimento.EmpresaId = '" + _empresaId + "' AND Atendimento.Deletado = 0";
                    query += queryFiltroUsuario;

                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //Campos para filtro e retorno
                    var cqfields = @"
                                    ID = Atendimento.ID,
                                    Numero = Atendimento.Numero,
                                    NomeFornecedor= Fornecedor.Nome+' - '+Fornecedor.CodigoERP,
                                    NomeReclamante = Atendimento.NomeReclamante,
                                    NomeProduto = Atendimento.NomeProduto,
                                    Quantidade = Atendimento.QuantidadeProduto,
                                    Status = CASE  Status
	                                         WHEN 0 THEN 'Aguardando Serviço' 
	                                        WHEN 1 THEN 'Serviço Realizado' 
	                                        WHEN 2 THEN 'Finalizado' 	 
	                                        ELSE 'Reprovada' 
                                        END
                                    ";

                    //total filtrado
                    query = $@"SELECT COUNT(*) FROM ( 
                                   select {cqfields}
                                     from Atendimento
                                JOIN Unidade ON Unidade.ID = Atendimento.UnidadeId
                                JOIN Fornecedor ON Fornecedor.ID = Atendimento.FornecedorID ";
                    query += @" where Atendimento.EmpresaId = '" + _empresaId + "' AND Atendimento.Deletado = 0 ";
                    query += queryFiltroUsuario;
                    query += @" ) A";

                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";

                    command.CommandText = query;
                    recordsFiltered = Convert.ToInt32(command.ExecuteScalar());

                    //registros
                    query = $@"SELECT * FROM ( 
                                select 
                                    {cqfields}
                                   from Atendimento
                                JOIN Unidade ON Unidade.ID = Atendimento.UnidadeId
                                JOIN Fornecedor ON Fornecedor.ID = Atendimento.FornecedorID  ";

                    query += @" where Atendimento.EmpresaId = '" + _empresaId + "' AND Atendimento.Deletado = 0 ";
                    query += queryFiltroUsuario;
                    query += @" ) A";

                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";
                    query += @" ORDER BY " + orderby + " " + sortColumnDir + ((pageSize != -1) ? " OFFSET " + (skip) + " ROWS FETCH NEXT " + (pageSize) + " ROWS ONLY" : "");

                    command.CommandText = query;
                    var result = command.ExecuteReader();

                    while (result.Read())
                    {
                        data.Add(new
                        {
                            Id = result["ID"],
                            Numero = result["Numero"],
                            NomeFornecedor = result["NomeFornecedor"],
                            NomeReclamante = result["NomeReclamante"],
                            NomeProduto = result["NomeProduto"],
                            Quantidade = result["Quantidade"],
                            Status = result["Status"]
                        });
                    }
                }
                finally
                {
                    if (_context.Database.GetDbConnection().State == System.Data.ConnectionState.Open)
                    {
                        _context.Database.CloseConnection();
                    }
                }

            }

            return Json(new { draw, recordsFiltered, recordsTotal, data });
        }
    }
}
