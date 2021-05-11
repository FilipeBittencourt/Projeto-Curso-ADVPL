using System;
using System.Linq;
using System.Threading.Tasks;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Model;
using System.ComponentModel.DataAnnotations;
using System.Collections.Generic;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Security;
using Microsoft.EntityFrameworkCore;
using Facile.BusinessPortal.BusinessRules.Boleto;
using Facile.BusinessPortal.BusinessRules.Util;

namespace Facile.BusinessPortal.BusinessRules.DAO
{
    public static class BoletoDAO
    {
        public static async Task<List<SaveDataReturn>> CreateOrUpdateAsync(ContextParams Params, string _siteBaseURL, List<Library.Structs.Post.Boleto> postList)
        {
            var db = Params.Database;
            var result = new List<SaveDataReturn>();

            if (postList == null)
            {
                result.Add(SaveDataReturn.ReturnError("", "BoletoDAO >> POST >>> entrada de dados inválida"));
                return result;
            }

            var listBoleto = new List<Model.Boleto>();
            var listChavesEmail = new List<string>();

            foreach (var boletoPost in postList)
            {
                using (var tran = await db.Database.BeginTransactionAsync())
                {
                    try
                    {
                        var validResults = new List<ValidationResult>();

                        //Verificando/gravando cedente da empresa
                        var qcedente = from Cedente o in db.Cedente.ByParams(Params, true)
                                       where o.Codigo == boletoPost.Cedente_Codigo &&
                                       o.CPFCNPJ == boletoPost.Cedente_CPFCNPJ
                                       select o;

                        if (!qcedente.Any())
                        {
                            tran.Rollback();
                            result.Add(SaveDataReturn.ReturnError(boletoPost.ChaveUnica, "Cedente " + boletoPost.Cedente_Codigo + " Não Encontrado."));
                            continue;
                        }

                        var idCedente = qcedente.First().ID;

                        //Verificando/gravando sacado da empresa
                        var qsacado = from Sacado o in db.Sacado.ByParams(Params, true)
                                      where o.CPFCNPJ == boletoPost.Sacado_CPFCNPJ
                                      select o;

                        if (!qsacado.Any())
                        {
                            tran.Rollback();
                            result.Add(SaveDataReturn.ReturnError(boletoPost.ChaveUnica, "Sacado " + boletoPost.Sacado_CPFCNPJ + " Não Encontrado."));
                            continue;
                        }

                        var idSacado = qsacado.First().ID;

                        //Verificando/gravando banco
                        var qbanco = from Banco o in db.Banco
                                     where o.Codigo == boletoPost.CodigoBanco
                                     select o;

                        if (!qbanco.Any())
                        {
                            tran.Rollback();
                            result.Add(SaveDataReturn.ReturnError(boletoPost.ChaveUnica, "Banco " + boletoPost.CodigoBanco + " Não Implementado."));
                            continue;
                        }

                        var idBanco = qbanco.First().ID;


                        //Procurar Boleto
                        var query = from Model.Boleto o in db.Boleto.ByParams(Params)
                                    where o.CedenteID == idCedente &&
                                    o.NossoNumero == boletoPost.NossoNumero
                                    select o;

                        Model.Boleto boleto;

                        if (query.Any())
                        {
                            boleto = query.First();
                            db.Entry(boleto).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                            if (!boletoPost.DataRecebimento.HasValue)
                                SetEvento(Params, boleto, TipoBoletoEvento.Atualizacao);
                            else
                            {
                                boleto.DataRecebimento = boletoPost.DataRecebimento.Value;
                                SetEvento(Params, boleto, TipoBoletoEvento.Recebimento);
                            }
                        }
                        else
                        {
                            boleto = new BaseDAO<Model.Boleto>().Novo(Params);

                            //campos chave que não podem ser modificados
                            boleto.CodigoBanco = boletoPost.CodigoBanco;
                            boleto.BancoID = idBanco;
                            boleto.CedenteID = idCedente;
                            boleto.SacadoID = idSacado;

                            db.Boleto.Add(boleto);

                            SetEvento(Params, boleto, TipoBoletoEvento.Novo);
                        }

                        boleto.NumeroDocumento = boletoPost.NumeroDocumento;
                        boleto.NumeroControleParticipante = boletoPost.NumeroControleParticipante;
                        boleto.NossoNumero = boletoPost.NossoNumero;
                        boleto.DataEmissao = boletoPost.DataEmissao;
                        boleto.DataVencimento = boletoPost.DataVencimento;

                        //Atualizando titulo recebido pode vir valor zero
                        if (boletoPost.ValorTitulo > 0)
                            boleto.ValorTitulo = boletoPost.ValorTitulo;

                        boleto.ValorOutrosAcrescimos = boletoPost.ValorOutrosAcrescimos;
                        boleto.ValorDesconto = boletoPost.ValorDesconto;
                        boleto.PercentualJurosDia = boletoPost.PercentualJurosDia;
                        boleto.ValorJurosDia = boletoPost.ValorJurosDia;
                        boleto.EspecieDocumento = boletoPost.EspecieDocumento;
                        boleto.MensagemInstrucoesCaixa = boletoPost.MensagemLivreLinha1;
                        boleto.Deletado = boletoPost.Deletado;

                        if (!string.IsNullOrWhiteSpace(boletoPost.MensagemLivreLinha2))
                        {
                            if (!string.IsNullOrWhiteSpace(boleto.MensagemInstrucoesCaixa))
                                boleto.MensagemInstrucoesCaixa += Environment.NewLine;

                            boleto.MensagemInstrucoesCaixa += boletoPost.MensagemLivreLinha2;
                        }

                        if (!string.IsNullOrWhiteSpace(boletoPost.MensagemLivreLinha3))
                        {
                            if (!string.IsNullOrWhiteSpace(boleto.MensagemInstrucoesCaixa))
                                boleto.MensagemInstrucoesCaixa += Environment.NewLine;

                            boleto.MensagemInstrucoesCaixa += boletoPost.MensagemLivreLinha3;
                        }


                        var validation = new ValidationContext(boleto, null, null);
                        Validator.TryValidateObject(boleto, validation, validResults);

                        if (validResults.Count > 0)
                        {
                            tran.Rollback();
                            result.Add(SaveDataReturn.ReturnValidationResults(boletoPost.ChaveUnica, validResults));
                            continue;
                        }

                        await db.SaveChangesAsync();
                        tran.Commit();

                        //Adicionar boletos novos / OU se empresa configurada para enviar atualizacoes - para envio de e-mail
                        var sendMailUpdate = ContextUtil.GetParametroPorChave(Params.Database, "ENVIA_EMAIL_BOLETO_ATUALIZADO", Params.Unidade.EmpresaID) ?? "N";
                        if (!query.Any() || (sendMailUpdate.ToString().Trim() == "S" && query.Any() && !boletoPost.DataRecebimento.HasValue))
                        {
                            if (!boleto.Deletado)
                            {
                                //if (!boletoPost.Cedente_Codigo.Equals("23735111422001"))
                                {
                                    listBoleto.Add(boleto);
                                    listChavesEmail.Add(boletoPost.ChaveUnica);
                                }
                            }
                       }

                        result.Add(SaveDataReturn.ReturnOk(boletoPost.ChaveUnica));
                    }
                    catch (Exception ex)
                    {
                        tran.Rollback();
                        result.Add(SaveDataReturn.ReturnException(boletoPost.ChaveUnica, ex));
                        continue;
                    }
                }
            }

            try
            {
                //ENVIO DE E-MAIL DE BOLETOS APOS API DO PORTAL RECEBER NOVOS POSTS
                if (listBoleto.Count > 0)
                {
                    var sendMail = ContextUtil.GetParametroPorChave(Params.Database, "ENVIA_EMAIL_BOLETO_APOS_SINCRONISMO", Params.Unidade.EmpresaID) ?? "N";
                    if (sendMail.ToString().Trim() == "S")
                    {
                        BoletoMail.BoletoSendMail(db, listBoleto);
                        listBoleto.Clear();
                    }
                }
            }
            catch (Exception ex)
            {
                foreach (var obj in result)
                {
                    obj.Ok = true;

                    if (listChavesEmail.Contains(obj.Identificador.Trim()))
                        obj.Message = "ERRO AO ENVIAR E-MAIL: " + ex.Message;
                }
            }

            return result;
        }

        private static void SetEvento(ContextParams Params, Model.Boleto boleto, TipoBoletoEvento tipoEvento)
        {
            var evento = new BaseDAO<BoletoEvento>().Novo(Params);
            evento.BoletoID = boleto.ID;
            evento.TipoBoletoEvento = tipoEvento;
            Params.Database.BoletoEvento.Add(evento);
        }

        public static async Task<List<BoletoListExport>> ListaPorUsuario(FBContext db, long empresaId, Usuario usuario, string bolIds = "")
        {
            using (var command = db.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    var list = new List<BoletoListExport>();

                    db.Database.OpenConnection();

                    //filtro usuario
                    string queryFiltroUsuario = "";
                    if (usuario.Tipo == TipoUsuario.Cliente)
                    {
                        var listaSacado = SacadoDAO.GetIDListSacadoUsuario(db, usuario);

                        if (listaSacado != null)
                        {
                            var qids = "";
                            foreach (var id in listaSacado)
                            {
                                if (!string.IsNullOrWhiteSpace(qids))
                                    qids += ",";
                                qids += id.ToString();
                            }

                            queryFiltroUsuario += " AND Boleto.SacadoId IN (" + qids + ") ";
                        }
                        else
                        {
                            //erro usuario tipo cliente tem que ter um sacado
                            queryFiltroUsuario = " AND 1 = 2 ";
                        }
                    }

                    //filtro lista de ids
                    if (!string.IsNullOrWhiteSpace(bolIds))
                    {
                        queryFiltroUsuario += " AND Boleto.ID IN (" + bolIds + ") ";
                    }

                    //Campos para filtro e retorno
                    var cqfields = @"Boleto.ID,
                                    NomeUnidade = Unidade.Apelido,
                                    Sacado = Sacado.CPFCNPJ + ' - ' + RTRIM(Sacado.Nome) + ' [' + RTRIM(Sacado.CodigoERP) + ']',
                                    NumeroDocumento, 
                                    Status = CASE WHEN convert(date, GETDATE()) > DataVencimento THEN 'Vencido' ELSE 'Aguardando pagamento' END,
                                    ValorTitulo,
                                    DataEmissao,    
                                    DataVencimento
                                    ";
                    //registros
                    var query = $@"SELECT * FROM ( 
                                select 
                                    {cqfields}
                                    from Boleto
                                    JOIN Unidade ON Unidade.ID = Boleto.UnidadeId
                                    JOIN Sacado ON Sacado.ID = Boleto.SacadoId";

                    query += @" where Boleto.EmpresaId = " + empresaId + " AND DataRecebimento IS NULL";
                    query += queryFiltroUsuario;
                    query += @" ) A";

                    command.CommandText = query;
                    var result = await command.ExecuteReaderAsync();

                    while (result.Read())
                    {
                        var bol = new BoletoListExport()
                        {
                            NomeUnidade = result["NomeUnidade"].ToString(),
                            NumeroDocumento = result["NumeroDocumento"].ToString(),
                            Sacado = result["Sacado"].ToString(),
                            Status = result["Status"].ToString(),
                            ValorTitulo = (decimal)result["ValorTitulo"],
                            DataEmissao = (DateTime)result["DataEmissao"],
                            DataVencimento = (DateTime)result["DataVencimento"]
                        };

                        list.Add(bol);
                    }

                    return list;
                }
                finally
                {
                    if (db.Database.GetDbConnection().State == System.Data.ConnectionState.Open)
                    {
                        db.Database.CloseConnection();
                    }
                }
            }
        }
    }
}
